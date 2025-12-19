#!/bin/bash

set -e
set -E
set -o pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Get script directory or use default
if [[ -d "$HOME/.config/nixos" ]]; then
    SCRIPT_DIR="$HOME/.config/nixos"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Setup logging
LOG_DIR="$SCRIPT_DIR/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/post_install_${TIMESTAMP}.log"
LATEST_LOG="$LOG_DIR/latest.log"

mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        INFO)
            echo -e "${BLUE}ℹ${NC} ${BOLD}[$timestamp]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}✓${NC} ${BOLD}[$timestamp]${NC} $message"
            ;;
        WARNING)
            echo -e "${YELLOW}⚠${NC} ${BOLD}[$timestamp]${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}✗${NC} ${BOLD}[$timestamp]${NC} $message"
            ;;
        STEP)
            echo -e "\n${MAGENTA}▶${NC} ${BOLD}[$timestamp]${NC} ${CYAN}$message${NC}"
            ;;
    esac
}

run_cmd() {
    local cmd="$@"
    log INFO "Executing: $cmd"
    
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        log SUCCESS "Command completed: $cmd"
        return 0
    else
        local exit_code=$?
        log ERROR "Command failed with exit code $exit_code: $cmd"
        return $exit_code
    fi
}

run_cmd_visible() {
    local cmd="$@"
    log INFO "Executing: $cmd"
    
    if eval "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "Command completed: $cmd"
        return 0
    else
        local exit_code=$?
        log ERROR "Command failed with exit code $exit_code: $cmd"
        return $exit_code
    fi
}

error_handler() {
    local line_num=$1
    log ERROR "Script failed at line $line_num"
    log ERROR "Check log file: $LOG_FILE"
    echo -e "\n${RED}${BOLD}Setup failed!${NC} See: ${YELLOW}$LOG_FILE${NC}\n"
    exit 1
}

trap 'error_handler ${LINENO}' ERR

# Header
clear
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          NixOS Post-Installation Setup Script            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

log INFO "Starting post-installation setup"
log INFO "Script directory: $SCRIPT_DIR"
log INFO "Log file: $LOG_FILE"

# Notify user
echo -e "${CYAN}This will set up your NixOS system with home-manager and apply your configurations.${NC}"
echo -e "${CYAN}This process may take several minutes...${NC}\n"
sleep 2

# Check if flake.nix exists
HAS_FLAKE=false
if [[ -f "$SCRIPT_DIR/flake.nix" ]]; then
    HAS_FLAKE=true
    log INFO "Detected flake configuration"
fi

# Step 1: Update system
log STEP "Step 1: Updating NixOS channels"
run_cmd_visible "sudo nix-channel --update"

# Step 2: Setup home-manager if flake exists
if [[ "$HAS_FLAKE" == true ]]; then
    log STEP "Step 2: Setting up home-manager"
    
    # Add home-manager channel if not already added
    if ! nix-channel --list | grep -q home-manager; then
        log INFO "Adding home-manager channel"
        run_cmd "nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager"
        run_cmd "nix-channel --update"
    else
        log INFO "Home-manager channel already exists"
    fi
    
    # Install home-manager if not installed
    if ! command -v home-manager &> /dev/null; then
        log INFO "Installing home-manager"
        run_cmd_visible "nix-shell '<home-manager>' -A install"
    else
        log INFO "Home-manager already installed"
    fi
fi

# Step 3: Rebuild NixOS configuration
log STEP "Step 3: Rebuilding NixOS configuration"
if [[ "$HAS_FLAKE" == true ]]; then
    log INFO "Using flake configuration"
    run_cmd_visible "sudo nixos-rebuild switch --flake $SCRIPT_DIR#"
else
    log INFO "Using traditional configuration"
    run_cmd_visible "sudo nixos-rebuild switch"
fi

# Step 4: Update flake inputs if using flakes
if [[ "$HAS_FLAKE" == true ]]; then
    log STEP "Step 4: Updating flake inputs"
    run_cmd_visible "nix flake update --flake $SCRIPT_DIR"
fi

# Step 5: Apply home-manager configuration
if [[ "$HAS_FLAKE" == true ]] && command -v home-manager &> /dev/null; then
    log STEP "Step 5: Applying home-manager configuration"
    
    if [[ -f "$SCRIPT_DIR/flake.nix" ]]; then
        log INFO "Using flake-based home-manager"
        run_cmd_visible "home-manager switch --flake $SCRIPT_DIR#"
    else
        log INFO "Using standalone home-manager"
        run_cmd_visible "home-manager switch"
    fi
fi

# Step 6: Verify installation
log STEP "Step 6: Verifying installation"

echo -e "\n${CYAN}${BOLD}System Information:${NC}"
nixos-version | tee -a "$LOG_FILE"
echo ""

if command -v home-manager &> /dev/null; then
    echo -e "${CYAN}Home Manager:${NC} $(home-manager --version)" | tee -a "$LOG_FILE"
fi

# Create symlink to latest log
ln -sf "$LOG_FILE" "$LATEST_LOG"

# Step 7: Cleanup first-boot automation
log STEP "Step 7: Cleaning up first-boot automation"

# Disable and remove the systemd service
if systemctl --user is-enabled nixos-first-boot.service &>/dev/null; then
    log INFO "Disabling first-boot service"
    systemctl --user disable nixos-first-boot.service 2>/dev/null || true
    systemctl --user stop nixos-first-boot.service 2>/dev/null || true
fi

# Remove the service file
if [[ -f "$HOME/.config/systemd/user/nixos-first-boot.service" ]]; then
    log INFO "Removing first-boot service file"
    rm -f "$HOME/.config/systemd/user/nixos-first-boot.service"
fi

# Reload systemd user daemon
systemctl --user daemon-reload 2>/dev/null || true

log SUCCESS "First-boot automation cleaned up"

# Success
echo -e "\n${GREEN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          Post-Installation Setup Completed!               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

log SUCCESS "Post-installation setup completed!"

# Summary
echo -e "${CYAN}${BOLD}Summary:${NC}"
echo -e "  ${GREEN}✓${NC} System channels updated"
if [[ "$HAS_FLAKE" == true ]]; then
    echo -e "  ${GREEN}✓${NC} Home-manager installed and configured"
    echo -e "  ${GREEN}✓${NC} Flake inputs updated"
fi
echo -e "  ${GREEN}✓${NC} NixOS configuration applied"
echo -e "  ${GREEN}✓${NC} System verified"
echo -e "  ${GREEN}✓${NC} First-boot automation cleaned up"
echo ""
echo -e "${YELLOW}Logs:${NC} $LOG_FILE"
echo -e "${YELLOW}Latest:${NC} $LATEST_LOG"
echo ""
echo -e "${GREEN}${BOLD}Your NixOS system is now fully configured and ready to use!${NC}"
echo -e "${CYAN}You may need to reboot for all changes to take effect.${NC}\n"