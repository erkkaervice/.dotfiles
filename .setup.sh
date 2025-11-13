#!/bin/bash
#
# setup.sh - Installs dependencies, fonts, and links dotfiles.
#

# --- Helper Functions ---
print_info() { echo "[INFO] $1"; }
print_error() { echo "[ERROR] $1" >&2; }

# --- Global Variables ---
CAN_INSTALL_PACKAGES=true # Assume yes initially
IS_TERMUX=false

# Check sudo, set flag if installation isn't possible
check_sudo_and_set_flag() {
	if [ -n "$PREFIX" ] && [ -d "$PREFIX/etc" ]; then
		IS_TERMUX=true; CAN_INSTALL_PACKAGES=true
		print_info "Termux environment detected. Skipping sudo check."
		return
	fi
	if [ "$EUID" -ne 0 ]; then
		if ! command -v sudo > /dev/null 2>&1; then CAN_INSTALL_PACKAGES=false
		elif ! sudo -n true > /dev/null 2>&1; then
			if ! sudo -v 2>/dev/null; then
				print_info "Sudo rights not available. Will skip system package installation."
				CAN_INSTALL_PACKAGES=false
			else
				while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
				SUDO_KEEP_ALIVE_PID=$!; trap 'kill $SUDO_KEEP_ALIVE_PID 2>/dev/null' EXIT
			fi
		else CAN_INSTALL_PACKAGES=true; fi
	fi
}

# --- Main Script ---
print_info "Starting dotfiles setup..."
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Add ~/.local/bin to PATH immediately for this script
# This ensures we can find locally installed Kitty for desktop integration.
export PATH="$HOME/.local/bin:$PATH"

check_sudo_and_set_flag

# --- Basic OS Detection ---
OS_ID="unknown"; if [ "$IS_TERMUX" = true ]; then OS_ID="termux"; elif [ -f /etc/os-release ]; then . /etc/os-release; OS_ID=$ID; elif [ -f /etc/arch-release ]; then OS_ID="arch"; elif [ "$(uname)" == "Darwin" ]; then OS_ID="macos"; fi

# --- System Package Installation (Requires Sudo) ---
if [ "$CAN_INSTALL_PACKAGES" = true ]; then
	print_info "Detected OS: $OS_ID. Attempting system package installation..."
	INSTALL_FAILED=false
	case "$OS_ID" in
		termux)
			print_info "Installing packages for Termux..."
			# Core Fixes: clang (for gcc), bind-utils (for host), jq
			pkg update -y && pkg install -y fish git curl unzip p7zip unrar zstd fzf bat fd ripgrep zoxide nmap gnupg clang bind-utils jq tmux
			if [ $? -ne 0 ]; then INSTALL_FAILED=true; print_error "Termux installation failed."; fi
			;;
		ubuntu|debian|pop|mint|kali)
			print_info "Installing packages for Debian/Ubuntu/Kali based system..."
			# Core Fixes: build-essential (for gcc), dnsutils (for host), libarchive-tools (for bsdtar), jq.
			sudo apt-get update -qq && sudo apt-get install -y fish git curl unzip p7zip-full unrar zstd fzf bat fd-find ripgrep zoxide kitty fonts-inconsolata fontconfig nmap gnupg trivy gitleaks lynis tcpdump build-essential dnsutils libarchive-tools jq tmux
			
			if [ $? -ne 0 ]; then INSTALL_FAILED=true; print_error "Debian/Ubuntu/Kali installation failed."; fi
			;;
		arch|manjaro|steamos)
			print_info "Installing packages for Arch/SteamOS based system..."
			# Core Fixes: bind (for host), jq. base-devel handles gcc and libarchive.
			sudo pacman -Syu --noconfirm --needed fish git base-devel curl bind unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty ttf-inconsolata fontconfig nmap gnupg trivy gitleaks lynis tcpdump bind jq tmux
			if [ $? -ne 0 ]; then INSTALL_FAILED=true; print_error "Arch/SteamOS installation failed."; fi
			;;
		opensuse*|suse)
			print_info "Installing packages for OpenSUSE based system..."
			# Core Fixes: gcc, bind-utils (for host), libarchive-tools (for bsdtar), jq.
			sudo zypper refresh && sudo zypper install -y fish git-core curl unzip p7zip-full unrar zstd fzf bat fd-find ripgrep zoxide kitty google-inconsolata-fonts fontconfig nmap gnupg trivy gitleaks lynis tcpdump gcc bind-utils libarchive-tools jq tmux
			if [ $? -ne 0 ]; then INSTALL_FAILED=true; print_error "OpenSUSE installation failed."; fi
			;;
		alpine)
			print_info "Installing packages for Alpine based system..."
			# Core Fixes: gcc, bind-tools (for host), libarchive (for bsdtar), jq.
			sudo apk update && sudo apk add fish git curl unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty font-inconsolata fontconfig nmap gnupg trivy gitleaks lynis tcpdump gcc bind-tools libarchive jq tmux
			if [ $? -ne 0 ]; then INSTALL_FAILED=true; print_error "Alpine installation failed."; fi
			;;
		macos)
			if command -v brew >/dev/null; then
				print_info "Installing packages for macOS (Homebrew)..."
				# Core Fixes: gcc, bind, libarchive, jq.
				brew update
				brew install fish git curl unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty nmap gnupg trivy gitleaks lynis tcpdump gcc bind libarchive jq tmux
				brew install --cask font-inconsolata 2>/dev/null || true
			else INSTALL_FAILED=true; fi
			[ $? -ne 0 ] && INSTALL_FAILED=true
			[ "$INSTALL_FAILED" = true ] && print_error "Homebrew installation failed or skipped." || print_info "Homebrew installation successful."
			;;
		*) print_error "Unsupported OS: $OS_ID"; INSTALL_FAILED=true ;;
	esac
	[ "$INSTALL_FAILED" = true ] && print_error "System package installation failed."
else print_info "Skipping system packages (no sudo)."; fi

# --- Update Flatpak/Snap Packages ---
# MOVED TO HUB: This task is now performed manually via the planned 'hub' script for better control and speed.
# The stub remains here to delineate the location.

# --- Fallback: Local Tool Installation (No Sudo Required) ---
if [ "$IS_TERMUX" = false ]; then
	mkdir -p "$HOME/.local/bin"
	# 1. Kitty Fallback
	if ! command -v kitty >/dev/null 2>&1 && [ "$OS_ID" != "macos" ]; then
		if command -v curl >/dev/null 2>&1; then
			print_info "Fallback: Installing Kitty locally..."
			curl -fSL --proto '=https' https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n dest="$HOME/.local"
			ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
			ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"
		fi
	fi
	# 2. Kitty Desktop Integration (Always check, even if installed)
	if [ -d "$HOME/.local/kitty.app" ]; then
		mkdir -p "$HOME/.local/share/applications"; DESKTOP_FILE="$HOME/.local/share/applications/kitty.desktop"
		if [ ! -f "$DESKTOP_FILE" ] || ! grep -q "Exec=$HOME/.local/bin/kitty" "$DESKTOP_FILE"; then
			print_info "Updating local Kitty desktop integration..."
			cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$DESKTOP_FILE"
			sed -i "s|^Exec=kitty|Exec=$HOME/.local/bin/kitty|g" "$DESKTOP_FILE"
			sed -i "s|^TryExec=kitty|TryExec=$HOME/.local/bin/kitty|g" "$DESKTOP_FILE"
			sed -i "s|^Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$DESKTOP_FILE"
			command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$HOME/.local/share/applications"
		fi
	fi
	# 3. Zoxide & FZF Fallbacks
	if ! command -v zoxide >/dev/null 2>&1 && command -v curl >/dev/null 2>&1; then print_info "Fallback: Zoxide..."; curl -sSf --proto '=https' httpss://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; fi
	if ! command -v fzf >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then print_info "Fallback: FZF..."; git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; ~/.fzf/install --all --no-bash --no-zsh --no-fish; ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"; fi
fi

# --- Fallback: Security Tools (Always run) ---
# FIXED: Removed the Trivy fallback, as it downloads a binary
# incompatible with Termux (non-PIE executable).
if command -v curl >/dev/null 2>&1; then
	: # All fallbacks removed
fi

# --- Custom Font Installation ---
if [ "$IS_TERMUX" = false ]; then
	FONTS_DIR="$DOTFILES_DIR/.fonts"; [ "$OS_ID" == "macos" ] && UFD="$HOME/Library/Fonts" || UFD="$HOME/.local/share/fonts"
	if [ -d "$FONTS_DIR" ] && [ "$(ls -A "$FONTS_DIR"/*.ttf 2>/dev/null)" ]; then
		print_info "Installing custom fonts..."; mkdir -p "$UFD"; cp -n "$FONTS_DIR"/*.ttf "$UFD"/ 2>/dev/null
		[ "$OS_ID" != "macos" ] && command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$UFD"
	fi
fi

# --- Security Hardening ---
if [ "$IS_TERMUX" = false ]; then
	if [ -d "$HOME/.ssh" ]; then
		print_info "Hardening SSH key permissions..."
		chmod 700 "$HOME/.ssh"
		chmod 600 "$HOME/.ssh/id_"* 2>/dev/null || true
		chmod 644 "$HOME/.ssh/id_"*.pub 2>/dev/null || true
		chmod 644 "$HOME/.ssh/known_hosts" 2>/dev/null || true
	fi
fi

# --- Link Dotfiles ---
print_info "Linking dotfiles..."
# Loop through all core dotfiles and link them
for f in .sh_common .profile .bashrc .zshrc .bash_logout .ssh_agent_init .gitconfig; do ln -sf "$DOTFILES_DIR/$f" "$HOME/$f"; done
# Link config directories
mkdir -p "$HOME/.config/fish"; ln -sf "$DOTFILES_DIR/.config.fish" "$HOME/.config/fish/config.fish"
mkdir -p "$HOME/.config/nvim"; ln -sf "$DOTFILES_DIR/.init.vim" "$HOME/.config/nvim/init.vim"
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

if [ "$IS_TERMUX" = false ]; then
	mkdir -p "$HOME/.config/kitty" "$HOME/.config/fontconfig"
	ln -sf "$DOTFILES_DIR/.kitty.conf" "$HOME/.config/kitty/kitty.conf"
	ln -sf "$DOTFILES_DIR/.fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
fi
print_info "Dotfiles linked. Setup finished!"

# Run desktop configuration last
[ -f "$DOTFILES_DIR/.configure_desktop.sh" ] && bash "$DOTFILES_DIR/.configure_desktop.sh"
exit 0