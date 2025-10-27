#!/bin/bash
#
# setup.sh - Installs dependencies (if sudo available) and links dotfiles.
#

# --- Helper Functions ---
print_info() {
	echo "[INFO] $1"
}

print_error() {
	echo "[ERROR] $1" >&2
}

# --- Global Variable ---
CAN_INSTALL_PACKAGES=true # Assume yes initially
IS_TERMUX=false # --- TERMUX CHANGE ---

# Check sudo, set flag if installation isn't possible
check_sudo_and_set_flag() {
	# --- TERMUX CHANGE ---
	# Check for Termux (which doesn't use sudo)
	if [ -n "$PREFIX" ] && [ -d "$PREFIX/etc" ]; then
		IS_TERMUX=true
		CAN_INSTALL_PACKAGES=true
		print_info "Termux environment detected. Skipping sudo check."
		return
	fi
	# --- END TERMUX CHANGE ---

	if [ "$EUID" -ne 0 ]; then
		if ! command -v sudo > /dev/null 2>&1; then
			print_error "sudo command not found. Skipping package installation."
			CAN_INSTALL_PACKAGES=false
			return
		fi
		# Test if sudo works non-interactively first
		if ! sudo -n true > /dev/null 2>&1; then
			# If non-interactive fails, try interactive
			print_info "Attempting to grant sudo privileges for package installation..."
			if ! sudo -v; then
				print_error "Sudo privileges not granted. Skipping package installation."
				CAN_INSTALL_PACKAGES=false
				return
			fi
		fi
		# Keep sudo session alive only if we can install
		sudo_keep_alive_pid=""
		while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
		sudo_keep_alive_pid=$!
		trap 'if [ -n "$sudo_keep_alive_pid" ] && kill -0 "$sudo_keep_alive_pid" 2>/dev/null; then kill "$sudo_keep_alive_pid"; fi' EXIT
	fi
	# If we got here, we have root or working sudo
	CAN_INSTALL_PACKAGES=true
}

# --- Main Script ---
print_info "Starting dotfiles setup..."

check_sudo_and_set_flag

# --- Perform Installation ONLY if possible ---
if [ "$CAN_INSTALL_PACKAGES" = true ]; then
	# --- Basic OS Detection ---
	OS_ID=""
	ID_LIKE=""
	# --- TERMUX CHANGE ---
	if [ "$IS_TERMUX" = true ]; then
		OS_ID="termux"
	# --- END TERMUX CHANGE ---
	elif [ -f /etc/os-release ]; then
		. /etc/os-release
		OS_ID=$ID
		ID_LIKE=$ID_LIKE
	elif [ -f /etc/arch-release ]; then
		OS_ID="arch"
	elif type lsb_release >/dev/null 2>&1; then
		OS_ID=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
	else
		print_error "Unsupported OS/Distribution. Cannot automatically install packages."
		print_info "Please manually install dependencies for your system."
		INSTALL_CMD="unknown"
	fi

	# Determine Install Command
	if [[ -z "$INSTALL_CMD" ]]; then # Check if INSTALL_CMD was already set to unknown
		# --- TERMUX CHANGE ---
		if [ "$OS_ID" == "termux" ]; then
			INSTALL_CMD="pkg"
		# --- END TERMUX CHANGE ---
		elif [[ "$OS_ID" == "steamos" || "$ID_LIKE" == *"arch"* || "$OS_ID" == "arch" ]]; then
			INSTALL_CMD="pacman"
		elif [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
			INSTALL_CMD="apt"
		elif [[ "$OS_ID" == *"opensuse"* || "$ID_LIKE" == *"suse"* ]]; then
			INSTALL_CMD="zypper"
		elif [ "$OS_ID" == "alpine" ]; then
			INSTALL_CMD="apk"
		else
			INSTALL_CMD="unknown"
		fi
	fi

	print_info "Detected OS: $OS_ID (using $INSTALL_CMD)"

	# --- Install Commands based on Package Manager ---
	INSTALL_FAILED=false
	# --- TERMUX CHANGE ---
	if [ "$INSTALL_CMD" == "pkg" ]; then
		print_info "Updating package list (pkg)..."
		pkg update -y || INSTALL_FAILED=true

		if [ "$INSTALL_FAILED" = false ]; then
			print_info "Installing packages for Termux..."
			# Note: No 'sudo'
			pkg install -y \
				fish git build-essential curl dnsutils unzip p7zip unrar libarchive cabextract zstd \
				fzf bat fd ripgrep zoxide \
				|| INSTALL_FAILED=true
		fi
	# --- END TERMUX CHANGE ---
	elif [ "$INSTALL_CMD" == "apt" ]; then
		print_info "Updating package list (apt)..."
		sudo apt-get update -qq || INSTALL_FAILED=true

		if [ "$INSTALL_FAILED" = false ]; then
			print_info "Installing packages for Debian/Ubuntu based system..."
			sudo apt-get install -y \
				fish git build-essential curl dnsutils unzip p7zip-full unrar libarchive-tools cabextract zstd \
				fzf bat fd-find ripgrep zoxide \
				|| INSTALL_FAILED=true
		fi

	elif [ "$INSTALL_CMD" == "pacman" ]; then
		print_info "Installing packages for Arch based system (Arch/SteamOS)..."
		sudo pacman -Syu --noconfirm --needed \
			fish git base-devel curl bind unzip p7zip unrar bsdtar cabextract zstd \
			fzf bat fd ripgrep zoxide \
			|| INSTALL_FAILED=true

	elif [ "$INSTALL_CMD" == "zypper" ]; then
		print_info "Refreshing repositories (zypper)..."
		sudo zypper refresh || INSTALL_FAILED=true

		if [ "$INSTALL_FAILED" = false ]; then
			print_info "Installing packages for openSUSE..."
			sudo zypper install -y \
				fish git-core patterns-devel-base-devel curl bind-utils unzip p7zip-full unrar libarchive-tools cabextract zstd \
				fzf bat fd-find ripgrep zoxide \
				|| INSTALL_FAILED=true
		fi

	elif [ "$INSTALL_CMD" == "apk" ]; then
		print_info "Updating package list (apk)..."
		sudo apk update || INSTALL_FAILED=true

		if [ "$INSTALL_FAILED" = false ]; then
			print_info "Installing packages for Alpine..."
			sudo apk add \
				fish git build-base curl bind-tools unzip p7zip unrar libarchive cabextract zstd \
				fzf bat fd ripgrep zoxide \
				|| INSTALL_FAILED=true
		fi
	else
		print_error "Automatic installation not configured or OS unsupported."
		INSTALL_FAILED=true # Mark as failed to show message below
	fi

	# Report outcome
	if [ "$INSTALL_FAILED" = true ]; then
		print_error "Package installation failed or was skipped."
		print_info "Please install required packages manually."
	else
		print_info "Required packages should now be installed."
	fi
else
	print_info "Skipping package installation due to missing sudo privileges."
fi # End of CAN_INSTALL_PACKAGES check


# --- Link Dotfiles (This section runs regardless) ---
print_info "Linking dotfiles..."
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Create symbolic links in the home directory, overwriting if they exist (-f)
# Add error checking for each link
ln -sf "$DOTFILES_DIR/.sh_common" "$HOME/.sh_common" || print_error "Failed to link .sh_common"
ln -sf "$DOTFILES_DIR/.profile" "$HOME/.profile" || print_error "Failed to link .profile"
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc" || print_error "Failed to link .bashrc"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" || print_error "Failed to link .zshrc"
ln -sf "$DOTFILES_DIR/.bash_logout" "$HOME/.bash_logout" || print_error "Failed to link .bash_logout"

# Add link for Fish config - UPDATED source filename
mkdir -p "$HOME/.config/fish" || print_error "Failed to create fish config directory"
ln -sf "$DOTFILES_DIR/.config.fish" "$HOME/.config/fish/config.fish" || print_error "Failed to link config.fish"

print_info "Dotfiles linked."

print_info "Setup finished!"
print_info "Please restart your shell or run 'source ~/.bashrc' / 'source ~/.zshrc' for changes to take effect."
print_info "(For Fish, changes should apply on next launch)"

# Kill the sudo keep-alive background process explicitly using PID
if [ -n "$sudo_keep_alive_pid" ] && kill -0 "$sudo_keep_alive_pid" 2>/dev/null; then
	kill "$sudo_keep_alive_pid"
fi

exit 0
