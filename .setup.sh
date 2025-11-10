#!/bin/bash
#
# setup.sh - Installs dependencies, fonts, and links dotfiles.
#

# --- Helper Functions ---
print_info() {
	echo "[INFO] $1"
}

print_error() {
	echo "[ERROR] $1" >&2
}

# --- Global Variables ---
CAN_INSTALL_PACKAGES=true # Assume yes initially
IS_TERMUX=false

# Check sudo, set flag if installation isn't possible
check_sudo_and_set_flag() {
	# Check for Termux (which doesn't use sudo)
	if [ -n "$PREFIX" ] && [ -d "$PREFIX/etc" ]; then
		IS_TERMUX=true
		CAN_INSTALL_PACKAGES=true
		print_info "Termux environment detected. Skipping sudo check."
		return
	fi

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
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

check_sudo_and_set_flag

# --- Perform Installation ONLY if possible ---
if [ "$CAN_INSTALL_PACKAGES" = true ]; then
	# --- Basic OS Detection ---
	OS_ID=""
	ID_LIKE=""
	
	if [ "$IS_TERMUX" = true ]; then
		OS_ID="termux"
	elif [ -f /etc/os-release ]; then
		. /etc/os-release
		OS_ID=$ID
		ID_LIKE=$ID_LIKE
	elif [ -f /etc/arch-release ]; then
		OS_ID="arch"
	elif type lsb_release >/dev/null 2>&1; then
		OS_ID=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
	elif [ "$(uname)" == "Darwin" ]; then
		OS_ID="macos"
	else
		print_error "Unsupported OS/Distribution. Cannot automatically install packages."
		print_info "Please manually install dependencies for your system."
		INSTALL_CMD="unknown"
	fi

	# Determine Install Command
	if [[ -z "$INSTALL_CMD" ]]; then
		if [ "$OS_ID" == "termux" ]; then INSTALL_CMD="pkg"
		elif [[ "$OS_ID" == "steamos" || "$ID_LIKE" == *"arch"* || "$OS_ID" == "arch" ]]; then INSTALL_CMD="pacman"
		elif [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then INSTALL_CMD="apt"
		elif [[ "$OS_ID" == *"opensuse"* || "$ID_LIKE" == *"suse"* ]]; then INSTALL_CMD="zypper"
		elif [ "$OS_ID" == "alpine" ]; then INSTALL_CMD="apk"
		elif [ "$OS_ID" == "macos" ]; then INSTALL_CMD="brew"
		else INSTALL_CMD="unknown"
		fi
	fi

	print_info "Detected OS: $OS_ID (using $INSTALL_CMD)"

	# --- Install Commands based on Package Manager ---
	INSTALL_FAILED=false
	
	if [ "$INSTALL_CMD" == "pkg" ]; then
		print_info "Updating package list (pkg)..."
		pkg update -y || INSTALL_FAILED=true
		if [ "$INSTALL_FAILED" = false ]; then
			print_info "Installing packages for Termux..."
			pkg install -y \
				fish git build-essential curl dnsutils unzip p7zip unrar libarchive cabextract zstd \
				fzf bat fd ripgrep zoxide \
				|| INSTALL_FAILED=true
		fi
	elif [ "$INSTALL_CMD" == "apt" ]; then
		print_info "Updating package list (apt)..."
		sudo apt-get update -qq || INSTALL_FAILED=true
		if [ "$INSTALL_FAILED" = false ]; then
			print_info "Installing packages for Debian/Ubuntu based system..."
			sudo apt-get install -y \
				fish git build-essential curl dnsutils unzip p7zip-full unrar libarchive-tools cabextract zstd \
				fzf bat fd-find ripgrep zoxide kitty fonts-inconsolata fontconfig \
				|| INSTALL_FAILED=true
		fi
	elif [ "$INSTALL_CMD" == "pacman" ]; then
		print_info "Installing packages for Arch based system (Arch/SteamOS)..."
		sudo pacman -Syu --noconfirm --needed \
			fish git base-devel curl bind unzip p7zip unrar bsdtar cabextract zstd \
			fzf bat fd ripgrep zoxide kitty ttf-inconsolata fontconfig \
			|| INSTALL_FAILED=true
	elif [ "$INSTALL_CMD" == "zypper" ]; then
		print_info "Refreshing repositories (zypper)..."
		sudo zypper refresh || INSTALL_FAILED=true
		if [ "$INSTALL_FAILED" = false ]; then
			print_info "Installing packages for openSUSE..."
			sudo zypper install -y \
				fish git-core patterns-devel-base-devel curl bind-utils unzip p7zip-full unrar libarchive-tools cabextract zstd \
				fzf bat fd-find ripgrep zoxide kitty google-inconsolata-fonts fontconfig \
				|| INSTALL_FAILED=true
		fi
	elif [ "$INSTALL_CMD" == "apk" ]; then
		print_info "Updating package list (apk)..."
		sudo apk update || INSTALL_FAILED=true
		if [ "$INSTALL_FAILED" = false ]; then
			print_info "Installing packages for Alpine..."
			sudo apk add \
				fish git build-base curl bind-tools unzip p7zip unrar libarchive cabextract zstd \
				fzf bat fd ripgrep zoxide kitty font-inconsolata fontconfig \
				|| INSTALL_FAILED=true
		fi
	elif [ "$INSTALL_CMD" == "brew" ]; then
		if command -v brew > /dev/null 2>&1; then
			print_info "Installing packages for macOS (Homebrew)..."
			brew install fish git curl unzip p7zip unrar libarchive cabextract zstd fzf bat fd ripgrep zoxide kitty \
				|| INSTALL_FAILED=true
			brew install --cask font-inconsolata 2>/dev/null || true
		else
			print_error "Homebrew not found on macOS. Skipping package installation."
			INSTALL_FAILED=true
		fi
	else
		print_error "Automatic installation not configured or OS unsupported."
		INSTALL_FAILED=true
	fi

	if [ "$INSTALL_FAILED" = true ]; then
		print_error "Package installation failed or was skipped."
	else
		print_info "Required packages should now be installed."
	fi
else
	print_info "Skipping package installation due to missing sudo privileges."
fi

# --- Custom Font Installation ---
if [ "$IS_TERMUX" = false ]; then
	FONTS_SOURCE_DIR="$DOTFILES_DIR/.fonts"
	if [ "$OS_ID" == "macos" ]; then
		USER_FONT_DIR="$HOME/Library/Fonts"
	else
		USER_FONT_DIR="$HOME/.local/share/fonts"
	fi

	if [ -d "$FONTS_SOURCE_DIR" ] && [ "$(ls -A "$FONTS_SOURCE_DIR"/*.ttf 2>/dev/null)" ]; then
		print_info "Installing custom fonts from $FONTS_SOURCE_DIR..."
		mkdir -p "$USER_FONT_DIR"
		cp -n "$FONTS_SOURCE_DIR"/*.ttf "$USER_FONT_DIR"/ 2>/dev/null
		if [ "$OS_ID" != "macos" ] && command -v fc-cache >/dev/null 2>&1; then
			print_info "Refreshing system font cache..."
			fc-cache -f "$USER_FONT_DIR"
		fi
		print_info "Custom fonts installed."
	fi
fi

# --- Link Dotfiles ---
print_info "Linking dotfiles..."

ln -sf "$DOTFILES_DIR/.sh_common" "$HOME/.sh_common" || print_error "Failed to link .sh_common"
ln -sf "$DOTFILES_DIR/.profile" "$HOME/.profile" || print_error "Failed to link .profile"
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc" || print_error "Failed to link .bashrc"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" || print_error "Failed to link .zshrc"
ln -sf "$DOTFILES_DIR/.bash_logout" "$HOME/.bash_logout" || print_error "Failed to link .bash_logout"

mkdir -p "$HOME/.config/fish" || print_error "Failed to create fish config directory"
ln -sf "$DOTFILES_DIR/.config.fish" "$HOME/.config/fish/config.fish" || print_error "Failed to link config.fish"

if [ "$IS_TERMUX" = false ]; then
	mkdir -p "$HOME/.config/kitty" || print_error "Failed to create kitty config directory"
	ln -sf "$DOTFILES_DIR/.kitty.conf" "$HOME/.config/kitty/kitty.conf" || print_error "Failed to link kitty.conf"
	
	# NEW: Link global font configuration
	mkdir -p "$HOME/.config/fontconfig" || print_error "Failed to create fontconfig directory"
	ln -sf "$DOTFILES_DIR/.fonts.conf" "$HOME/.config/fontconfig/fonts.conf" || print_error "Failed to link fonts.conf"
fi

print_info "Dotfiles linked."
print_info "Setup finished! Restart your shell or run 'refresh'."

if [ -n "$sudo_keep_alive_pid" ] && kill -0 "$sudo_keep_alive_pid" 2>/dev/null; then
	kill "$sudo_keep_alive_pid"
fi

# Attempt to configure desktop (default terminal & fonts)
if [ -f "$DOTFILES_DIR/.configure_desktop.sh" ]; then
    bash "$DOTFILES_DIR/.configure_desktop.sh"
fi

exit 0