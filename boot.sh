#!/bin/bash

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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup logging
LOG_DIR="$SCRIPT_DIR/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/nixos_install_${TIMESTAMP}.log"
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
    
    # Use tee to show output and log it
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
    echo -e "\n${RED}${BOLD}Installation failed!${NC} See logs at: ${YELLOW}$LOG_FILE${NC}\n"
    exit 1
}
trap 'error_handler ${LINENO}' ERR

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log ERROR "This script must be run as root for disk operations"
        echo -e "${RED}Please run with: sudo $0${NC}"
        exit 1
    fi
}

# Function to print a separator line
print_separator() {
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
}

# Function to prompt for user input
prompt() {
    local prompt_text="$1"
    local var_name="$2"
    local default="$3"
    
    if [[ -n "$default" ]]; then
        echo -ne "${YELLOW}${prompt_text} [${default}]:${NC} "
    else
        echo -ne "${YELLOW}${prompt_text}:${NC} "
    fi
    
    read -r input
    if [[ -z "$input" && -n "$default" ]]; then
        eval "$var_name='$default'"
    else
        eval "$var_name='$input'"
    fi
    
    log INFO "User input for '$prompt_text': ${!var_name}"
}

# Function to confirm action
confirm() {
    local prompt_text="$1"
    echo -ne "${RED}${BOLD}${prompt_text} (yes/no):${NC} "
    read -r response
    log INFO "User confirmation for '$prompt_text': $response"
    
    if [[ "$response" != "yes" ]]; then
        log WARNING "User cancelled operation"
        echo -e "${YELLOW}Operation cancelled.${NC}"
        exit 0
    fi
}

# Start of script
clear
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     NixOS Installation Script with Disk Partitioning      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

log INFO "Starting NixOS installation script"
log INFO "Script directory: $SCRIPT_DIR"
log INFO "Log file: $LOG_FILE"

# Check if running as root
check_root

# Detect if system is UEFI or BIOS
if [[ -d /sys/firmware/efi ]]; then
    BOOT_MODE="UEFI"
    log INFO "Detected UEFI boot mode"
else
    BOOT_MODE="BIOS"
    log INFO "Detected BIOS boot mode"
fi

# Step 1: Display available disks
log STEP "Step 1: Detecting available disks"
echo ""
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | tee -a "$LOG_FILE"
echo ""
print_separator

# Prompt for disk selection
echo -e "\n${YELLOW}${BOLD}WARNING: All data on the selected disk will be DESTROYED!${NC}"
prompt "Enter the disk to install NixOS on (e.g., /dev/sda, /dev/nvme0n1)" DISK

# Validate disk exists
if [[ ! -b "$DISK" ]]; then
    log ERROR "Disk $DISK does not exist"
    exit 1
fi

log INFO "Selected disk: $DISK"

# Show disk information
echo -e "\n${CYAN}Selected disk information:${NC}"
lsblk "$DISK" -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT | tee -a "$LOG_FILE"
echo ""

# Confirm disk selection
confirm "Are you sure you want to ERASE ALL DATA on $DISK and install NixOS?"

# Step 2: Partition configuration
log STEP "Step 2: Configuring partitions"

prompt "Enter swap size in GB" SWAP_SIZE "8"
prompt "Enter hostname for the system" HOSTNAME "nixos"
prompt "Enter username for the primary user" USERNAME "user"

log INFO "Swap size: ${SWAP_SIZE}GB"
log INFO "Hostname: $HOSTNAME"
log INFO "Username: $USERNAME"

# Step 3: Partitioning disk
log STEP "Step 3: Partitioning disk $DISK"
log WARNING "Wiping disk $DISK"

# Unmount any mounted partitions on this disk
log INFO "Unmounting any mounted partitions"
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true

# Wipe disk
run_cmd "wipefs -af $DISK"
run_cmd "sgdisk -Z $DISK"

if [[ "$BOOT_MODE" == "UEFI" ]]; then
    log INFO "Creating GPT partition table for UEFI"
    
    # Create partitions for UEFI
    run_cmd "parted $DISK --script mklabel gpt"
    run_cmd "parted $DISK --script mkpart ESP fat32 1MiB 512MiB"
    run_cmd "parted $DISK --script set 1 esp on"
    run_cmd "parted $DISK --script mkpart primary linux-swap 512MiB $((512 + SWAP_SIZE * 1024))MiB"
    run_cmd "parted $DISK --script mkpart primary ext4 $((512 + SWAP_SIZE * 1024))MiB 100%"
    
    # Set partition variables
    if [[ "$DISK" =~ "nvme" ]]; then
        BOOT_PART="${DISK}p1"
        SWAP_PART="${DISK}p2"
        ROOT_PART="${DISK}p3"
    else
        BOOT_PART="${DISK}1"
        SWAP_PART="${DISK}2"
        ROOT_PART="${DISK}3"
    fi
else
    log INFO "Creating MBR partition table for BIOS"
    
    # Create partitions for BIOS
    run_cmd "parted $DISK --script mklabel msdos"
    run_cmd "parted $DISK --script mkpart primary linux-swap 1MiB $((1 + SWAP_SIZE * 1024))MiB"
    run_cmd "parted $DISK --script mkpart primary ext4 $((1 + SWAP_SIZE * 1024))MiB 100%"
    run_cmd "parted $DISK --script set 2 boot on"
    
    # Set partition variables
    if [[ "$DISK" =~ "nvme" ]]; then
        SWAP_PART="${DISK}p1"
        ROOT_PART="${DISK}p2"
    else
        SWAP_PART="${DISK}1"
        ROOT_PART="${DISK}2"
    fi
fi

# Wait for partitions to be ready
sleep 2
run_cmd "partprobe $DISK"
sleep 2

log SUCCESS "Disk partitioning completed"
lsblk "$DISK" | tee -a "$LOG_FILE"

# Step 4: Formatting partitions
log STEP "Step 4: Formatting partitions"

if [[ "$BOOT_MODE" == "UEFI" ]]; then
    log INFO "Formatting EFI partition: $BOOT_PART"
    run_cmd "mkfs.fat -F 32 -n BOOT $BOOT_PART"
fi

log INFO "Formatting root partition: $ROOT_PART"
run_cmd "mkfs.ext4 -L nixos $ROOT_PART"

log INFO "Setting up swap partition: $SWAP_PART"
run_cmd "mkswap -L swap $SWAP_PART"

log SUCCESS "All partitions formatted"

# Step 5: Mounting filesystems
log STEP "Step 5: Mounting filesystems"

log INFO "Mounting root partition"
run_cmd "mount $ROOT_PART /mnt"

if [[ "$BOOT_MODE" == "UEFI" ]]; then
    log INFO "Creating and mounting boot directory"
    run_cmd "mkdir -p /mnt/boot"
    run_cmd "mount $BOOT_PART /mnt/boot"
fi

log INFO "Enabling swap"
run_cmd "swapon $SWAP_PART"

log SUCCESS "Filesystems mounted"
df -h /mnt | tee -a "$LOG_FILE"

# Step 6: Generate NixOS configuration
log STEP "Step 6: Generating NixOS configuration"

run_cmd "nixos-generate-config --root /mnt"
log SUCCESS "Configuration generated at /mnt/etc/nixos"

# Check if user has custom configuration
if [[ -f "$SCRIPT_DIR/configuration.nix" ]]; then
    log INFO "Found custom configuration.nix, copying to /mnt/etc/nixos/"
    run_cmd "cp $SCRIPT_DIR/configuration.nix /mnt/etc/nixos/configuration.nix"
fi

if [[ -d "$SCRIPT_DIR/flake.nix" ]] || [[ -f "$SCRIPT_DIR/flake.nix" ]]; then
    log INFO "Found flake configuration, copying to /mnt/etc/nixos/"
    run_cmd "cp -r $SCRIPT_DIR/* /mnt/etc/nixos/ 2>/dev/null || true"
fi

# Set hostname in configuration
log INFO "Setting hostname to: $HOSTNAME"
sed -i "s/networking.hostName = .*/networking.hostName = \"$HOSTNAME\";/" /mnt/etc/nixos/configuration.nix

# Step 7: Install NixOS
log STEP "Step 7: Installing NixOS (this will take a while)"
run_cmd_visible "nixos-install --no-root-passwd"

log SUCCESS "NixOS base installation completed"

# Step 8: Post-installation setup
log STEP "Step 8: Post-installation configuration"

# Copy wallpapers if they exist
if [[ -d "$SCRIPT_DIR/assets/Wallpapers" ]]; then
    log INFO "Copying wallpapers"
    run_cmd "mkdir -p /mnt/home/$USERNAME/Pictures"
    run_cmd "cp -r $SCRIPT_DIR/assets/Wallpapers/* /mnt/home/$USERNAME/Pictures/"
fi

# Copy flake and configuration to user's home
if [[ -d "$SCRIPT_DIR" ]]; then
    log INFO "Copying configuration files to user home directory"
    run_cmd "mkdir -p /mnt/home/$USERNAME/.config/nixos"
    run_cmd "cp -r $SCRIPT_DIR/* /mnt/home/$USERNAME/.config/nixos/ 2>/dev/null || true"
fi

# Set proper ownership
run_cmd "chown -R 1000:100 /mnt/home/$USERNAME 2>/dev/null || true"

# Step 9: Setup home-manager (if flake exists)
if [[ -f "$SCRIPT_DIR/flake.nix" ]]; then
    log STEP "Step 9: Setting up home-manager"
    
    log INFO "Installing home-manager in the new system"
    nixos-enter --root /mnt -c "
        nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
        nix-channel --update
    " 2>&1 | tee -a "$LOG_FILE"
    
    log SUCCESS "Home-manager channels configured"
fi

# Create symlink to latest log
ln -sf "$LOG_FILE" "$LATEST_LOG"

# Step 10: Set passwords
log STEP "Step 10: Setting up user passwords"

echo ""
log INFO "Setting root password"
echo -e "${YELLOW}Enter password for root:${NC}"
nixos-enter --root /mnt -c 'passwd' 2>&1 | tee -a "$LOG_FILE"

echo ""
log INFO "Setting password for user: $USERNAME"
echo -e "${YELLOW}Enter password for $USERNAME:${NC}"
nixos-enter --root /mnt -c "passwd $USERNAME" 2>&1 | tee -a "$LOG_FILE"

log SUCCESS "Passwords configured"

# Step 11: Setup automatic post-installation
log STEP "Step 11: Setting up automatic post-installation"

# Copy post-install script to user's home
if [[ -f "$SCRIPT_DIR/post-install.sh" ]]; then
    log INFO "Copying post-install script to new system"
    run_cmd "cp $SCRIPT_DIR/post-install.sh /mnt/home/$USERNAME/"
    run_cmd "chmod +x /mnt/home/$USERNAME/post-install.sh"
    
    # Create systemd user service for first boot
    log INFO "Creating first-boot service for post-installation"
    
    mkdir -p /mnt/home/$USERNAME/.config/systemd/user
    
    cat > /mnt/home/$USERNAME/.config/systemd/user/nixos-first-boot.service << 'EOF'
[Unit]
Description=NixOS First Boot Post-Installation Setup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/USERNAME/post-install.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

    # Replace USERNAME placeholder
    sed -i "s|/home/USERNAME|/home/$USERNAME|g" /mnt/home/$USERNAME/.config/systemd/user/nixos-first-boot.service
    
    # Create a script to enable the service on first login
    cat > /mnt/home/$USERNAME/.first-boot-setup << 'EOF'
#!/bin/bash
# Enable and start the first-boot service
if [[ -f "$HOME/.config/systemd/user/nixos-first-boot.service" ]]; then
    systemctl --user daemon-reload
    systemctl --user enable nixos-first-boot.service
    systemctl --user start nixos-first-boot.service
    
    # Wait for service to complete
    echo "Running post-installation setup..."
    sleep 2
    
    # Check if service completed
    if systemctl --user is-active --quiet nixos-first-boot.service; then
        echo "Post-installation is running in the background."
        echo "Check status with: systemctl --user status nixos-first-boot.service"
        echo "View logs with: journalctl --user -u nixos-first-boot.service -f"
    fi
    
    # Remove this script after first run
    rm -f "$HOME/.first-boot-setup"
fi
EOF
    
    chmod +x /mnt/home/$USERNAME/.first-boot-setup
    
    # Add to .bashrc to run on first login
    echo "" >> /mnt/home/$USERNAME/.bashrc
    echo "# First boot setup" >> /mnt/home/$USERNAME/.bashrc
    echo '[[ -f "$HOME/.first-boot-setup" ]] && "$HOME/.first-boot-setup"' >> /mnt/home/$USERNAME/.bashrc
    
    # Set proper ownership
    run_cmd "chown -R 1000:100 /mnt/home/$USERNAME/.config 2>/dev/null || true"
    run_cmd "chown 1000:100 /mnt/home/$USERNAME/.first-boot-setup 2>/dev/null || true"
    run_cmd "chown 1000:100 /mnt/home/$USERNAME/.bashrc 2>/dev/null || true"
    run_cmd "chown 1000:100 /mnt/home/$USERNAME/post-install.sh 2>/dev/null || true"
    
    log SUCCESS "Post-installation automation configured"
else
    log WARNING "post-install.sh not found, skipping automatic setup"
fi

# Copy logs to installed system
log INFO "Copying installation logs to new system"
run_cmd "mkdir -p /mnt/var/log/nixos-install"
run_cmd "cp -r $LOG_DIR/* /mnt/var/log/nixos-install/"

# Create symlink to latest log
ln -sf "$LOG_FILE" "$LATEST_LOG"

# Success message
echo -e "\n${GREEN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║        NixOS Installation Completed Successfully!         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

log SUCCESS "NixOS installation completed successfully!"

# Summary
echo -e "${CYAN}${BOLD}Installation Summary:${NC}"
echo -e "  ${GREEN}✓${NC} Disk: $DISK"
echo -e "  ${GREEN}✓${NC} Boot mode: $BOOT_MODE"
echo -e "  ${GREEN}✓${NC} Hostname: $HOSTNAME"
echo -e "  ${GREEN}✓${NC} Username: $USERNAME"
echo -e "  ${GREEN}✓${NC} Swap size: ${SWAP_SIZE}GB"
if [[ "$BOOT_MODE" == "UEFI" ]]; then
    echo -e "  ${GREEN}✓${NC} Boot partition: $BOOT_PART"
fi
echo -e "  ${GREEN}✓${NC} Root partition: $ROOT_PART"
echo -e "  ${GREEN}✓${NC} Swap partition: $SWAP_PART"
echo -e "  ${GREEN}✓${NC} Root password: Set"
echo -e "  ${GREEN}✓${NC} User password: Set"
echo -e "  ${GREEN}✓${NC} Post-install: Auto-configured"
echo ""
echo -e "${YELLOW}${BOLD}Next Steps:${NC}"
echo -e "  1. Reboot into your new system: ${CYAN}reboot${NC}"
echo -e "  2. Post-installation will run automatically on first login"
echo -e "  3. Enjoy your NixOS system! 🎉"
echo ""
echo -e "${YELLOW}Installation logs:${NC} $LOG_FILE"
echo -e "${YELLOW}Logs copied to:${NC} /var/log/nixos-install/ (in new system)"
echo ""
print_separator
echo ""