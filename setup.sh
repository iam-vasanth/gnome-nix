#!/usr/bin/env bash

# Exit on error and inherit ERR trap
set -e
set -E
set -o pipefail

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup logging
LOG_DIR="$SCRIPT_DIR/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/nixos_setup_${TIMESTAMP}.log"
LATEST_LOG="$LOG_DIR/latest.log"

# Create log directory
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    # Format for log file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    # Format for terminal with colors
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
        *)
            echo -e "${BOLD}[$timestamp]${NC} $message"
            ;;
    esac
}

# Function to run command with logging
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

# Function to run command with visible output
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

# Error handler
error_handler() {
    local line_num=$1
    log ERROR "Script failed at line $line_num"
    log ERROR "Check log file for details: $LOG_FILE"
    echo -e "\n${RED}${BOLD}Setup failed!${NC} See logs at: ${YELLOW}$LOG_FILE${NC}\n"
    exit 1
}

# Set error trap
trap 'error_handler ${LINENO}' ERR

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log WARNING "This script should not be run as root directly"
        log WARNING "It will use sudo when needed"
        exit 1
    fi
}

# Function to check if home-manager is installed
check_home_manager() {
    if command -v home-manager >/dev/null 2>&1; then
        return 0
    fi
    # Fallback check Nix profile
    if nix profile list 2>/dev/null | grep -q home-manager; then
        return 0
    fi
    return 1
}


# Start of script
clear
echo -e "${CYAN}${BOLD}"
echo "╔════════════════════════════╗"
echo "║     NixOS Setup Script     ║"
echo "╚════════════════════════════╝"
echo -e "${NC}\n"

log INFO "Starting NixOS setup script"
log INFO "Script directory: $SCRIPT_DIR"
log INFO "Log file: $LOG_FILE"

# Check if running as root
check_root

# Setup Pictures directory
log STEP "Step 1: Setting up Pictures directory"
if [[ ! -d "$HOME/Pictures" ]]; then
    run_cmd "mkdir -p $HOME/Pictures/Wallpapers"
else
    log INFO "Pictures directory already exists. Creating Wallpapers subdirectory if needed."
fi

# Copy wallpapers
if [[ -d "$SCRIPT_DIR/assets/Wallpapers" ]]; then
    log INFO "Copying wallpapers to Pictures directory"
    run_cmd "cp -r $SCRIPT_DIR/assets/Wallpapers* $HOME/Pictures/Wallpapers/"
else
    log WARNING "Wallpapers directory not found at $SCRIPT_DIR/assets/Wallpapers"
fi

# Install home-manager (only if needed)
log STEP "Step 2: Checking home-manager installation"

if check_home_manager; then
    log INFO "Skipping home-manager installation"
else
    log INFO "Installing home-manager (this may take several minutes)..."
    
    # Add the channel (safe to run multiple times, but we can skip if already added)
    if ! nix-channel --list | grep -q "^home-manager "; then
        run_cmd "nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager"
        log INFO "Updating nix channels"
        run_cmd_visible "nix-channel --update"
    else
        log INFO "home-manager channel already added"
    fi
    # Verify it worked
    if check_home_manager; then
        log SUCCESS "home-manager installed successfully"
    else
        log ERROR "home-manager installation failed"
        exit 1
    fi
fi

# Rebuild NixOS configuration
log STEP "Step 3: Rebuilding NixOS configuration"
log INFO "Running nixos-rebuild switch (this may take a while)"
run_cmd_visible "sudo nixos-rebuild switch --impure --flake $SCRIPT_DIR"

# Update flake
log STEP "Step 4: Updating flake inputs"
run_cmd_visible "nix flake update --flake $SCRIPT_DIR"

# Apply home-manager configuration
log STEP "Step 5: Applying home-manager configuration"
log INFO "Running home-manager switch"
run_cmd_visible "home-manager switch --impure --flake $SCRIPT_DIR"

# Create symlink to latest log
rm -f "$LATEST_LOG" && ln -s "$LOG_FILE" "$LATEST_LOG"

# Success message
echo -e "\n${GREEN}${BOLD}"
echo "╔═══════════════════════════════════════╗"
echo "║     Setup Completed Successfully!     ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}\n"

log SUCCESS "NixOS setup completed successfully!"
log INFO "Log saved to: $LOG_FILE"
log INFO "Latest log symlink: $LATEST_LOG"

# Summary
echo -e "${CYAN}${BOLD}Summary:${NC}"
echo -e "  ${GREEN}✓${NC} Pictures directory setup"
echo -e "  ${GREEN}✓${NC} Home-manager installed"
echo -e "  ${GREEN}✓${NC} NixOS configuration applied"
echo -e "  ${GREEN}✓${NC} Flake inputs updated"
echo -e "  ${GREEN}✓${NC} Home-manager configuration applied"
echo -e "\n${YELLOW}Log files location:${NC} $LOG_DIR"
echo -e "${YELLOW}Latest log:${NC} $LATEST_LOG\n"