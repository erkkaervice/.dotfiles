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
	# Check for Termux (which doesn't use sudo)
	if [ -n "$PREFIX" ] && [ -d "$PREFIX/etc" ]; then
		IS_TERMUX=true
		CAN_INSTALL_PACKAGES=true
		print_info "Termux environment detected. Skipping sudo check."
		return
	fi

	if [ "$EUID" -ne 0 ]; then
		if ! command -v sudo > /dev/null 2>&1; then
			# sudo not found
			CAN_INSTALL_PACKAGES=false
		elif ! sudo -n true > /dev/null 2>&1; then
			# sudo exists but requires password, try to get it once
			if ! sudo -v 2>/dev/null; then
				print_info "Sudo rights not available. Will skip system package installation."
				CAN_INSTALL_PACKAGES=false
			else
				# Keep sudo alive in background if we got it
				while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
				SUDO_KEEP_ALIVE_PID=$!
				trap 'kill $SUDO_KEEP_ALIVE_PID 2>/dev/null' EXIT
			fi
		else
			# sudo works without password
			CAN_INSTALL_PACKAGES=true
		fi
	fi
}

# --- Main Script ---
print_info "Starting dotfiles setup..."
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# ensure ~/.local/bin is in PATH for this script immediately
export PATH="$HOME/.local/bin:$PATH"

check_sudo_and_set_flag

# --- Basic OS Detection (Needed for both system and local installs) ---
OS_ID="unknown"; ID_LIKE=""
if [ "$IS_TERMUX" = true ]; then OS_ID="termux"
elif [ -f /etc/os-release ]; then . /etc/os-release; OS_ID=$ID;
elif [ -f /etc/arch-release ]; then OS_ID="arch"
elif [ "$(uname)" == "Darwin" ]; then OS_ID="macos"
fi

# --- System Package Installation (Requires Sudo) ---
if [ "$CAN_INSTALL_PACKAGES" = true ]; then
	print_info "Detected OS: $OS_ID. Attempting system package installation..."
	INSTALL_FAILED=false
	case "$OS_ID" in
		termux)
			pkg update -y && pkg install -y fish git curl unzip p7zip unrar zstd fzf bat fd ripgrep zoxide || INSTALL_FAILED=true ;;
		ubuntu|debian|pop|mint)
			sudo apt-get update -qq && sudo apt-get install -y fish git curl unzip p7zip-full unrar zstd fzf bat fd-find ripgrep zoxide kitty fonts-inconsolata fontconfig || INSTALL_FAILED=true ;;
		arch|manjaro|steamos)
			sudo pacman -Syu --noconfirm --needed fish git base-devel curl bind unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty ttf-inconsolata fontconfig || INSTALL_FAILED=true ;;
		opensuse*|suse)
			sudo zypper refresh && sudo zypper install -y fish git-core curl unzip p7zip-full unrar zstd fzf bat fd-find ripgrep zoxide kitty google-inconsolata-fonts fontconfig || INSTALL_FAILED=true ;;
		alpine)
			sudo apk update && sudo apk add fish git curl unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty font-inconsolata fontconfig || INSTALL_FAILED=true ;;
		macos)
			if command -v brew >/dev/null; then
				brew install fish git curl unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty
				brew install --cask font-inconsolata 2>/dev/null || true
			else INSTALL_FAILED=true; fi ;;
		*)
			print_error "Unsupported OS for automated system packages: $OS_ID"
			INSTALL_FAILED=true ;;
	esac
	[ "$INSTALL_FAILED" = true ] && print_error "System package installation failed or skipped." || print_info "System packages installed."
else
	print_info "Skipping system package installation (no sudo rights)."
fi

# --- Fallback: Local Tool Installation (No Sudo Required) ---
# Only run if NOT Termux (Termux uses 'pkg' without sudo anyway)
if [ "$IS_TERMUX" = false ]; then
	mkdir -p "$HOME/.local/bin"

	# 1. Kitty Fallback (Linux only, skip on macOS as it usually needs standard install)
	if ! command -v kitty >/dev/null 2>&1 && [ "$OS_ID" != "macos" ]; then
		if command -v curl >/dev/null 2>&1; then
			print_info "Fallback: Installing Kitty locally..."
			# Use official installer but tell it NOT to integrate, we will do it manually better
			curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n dest="$HOME/.local"
			
			# Create symlinks
			ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
			ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"
			
			# --- Desktop Integration (Robust Version) ---
			print_info "Integrating local Kitty with desktop environment..."
			mkdir -p "$HOME/.local/share/applications"
			DESKTOP_FILE="$HOME/.local/share/applications/kitty.desktop"
			
			# Copy template
			cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$DESKTOP_FILE"
			
			# Define exact paths for stability
			KITTY_BIN="$HOME/.local/bin/kitty"
			KITTY_ICON="$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png"

			# Use safer regex anchors (^) to only replace standard lines
			sed -i "s|^Exec=kitty|Exec=$KITTY_BIN|g" "$DESKTOP_FILE"
			sed -i "s|^TryExec=kitty|TryExec=$KITTY_BIN|g" "$DESKTOP_FILE"
			sed -i "s|^Icon=kitty|Icon=$KITTY_ICON|g" "$DESKTOP_FILE"

			# Force desktop database refresh if possible
			if command -v update-desktop-database >/dev/null 2>&1; then
				print_info "Refreshing desktop database..."
				update-desktop-database "$HOME/.local/share/applications"
			fi
		else
			print_error "curl missing. Cannot install Kitty fallback."
		fi
	fi

	# 2. Zoxide Fallback
	if ! command -v zoxide >/dev/null 2>&1; then
		if command -v curl >/dev/null 2>&1; then
			print_info "Fallback: Installing Zoxide locally..."
			curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
		else
			print_error "curl missing. Cannot install Zoxide fallback."
		fi
	fi

	# 3. FZF Fallback
	if ! command -v fzf >/dev/null 2>&1; then
		if command -v git >/dev/null 2>&1; then
			print_info "Fallback: Installing FZF locally..."
			git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
			~/.fzf/install --all --no-bash --no-zsh --no-fish  # We handle shell integration ourselves
			ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
		else
			print_error "git missing. Cannot install FZF fallback."
		fi
	fi
fi

# --- Custom Font Installation ---
if [ "$IS_TERMUX" = false ]; then
	FONTS_SOURCE_DIR="$DOTFILES_DIR/.fonts"
	[ "$OS_ID" == "macos" ] && USER_FONT_DIR="$HOME/Library/Fonts" || USER_FONT_DIR="$HOME/.local/share/fonts"

	if [ -d "$FONTS_SOURCE_DIR" ] && [ "$(ls -A "$FONTS_SOURCE_DIR"/*.ttf 2>/dev/null)" ]; then
		print_info "Installing custom fonts from $FONTS_SOURCE_DIR..."
		mkdir -p "$USER_FONT_DIR"
		cp -n "$FONTS_SOURCE_DIR"/*.ttf "$USER_FONT_DIR"/ 2>/dev/null
		if [ "$OS_ID" != "macos" ] && command -v fc-cache >/dev/null 2>&1; then
			fc-cache -f "$USER_FONT_DIR"
		fi
		print_info "Custom fonts installed."
	fi
fi

# --- Link Dotfiles ---
print_info "Linking dotfiles..."
for file in .sh_common .profile .bashrc .zshrc .bash_logout; do
	ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
done

mkdir -p "$HOME/.config/fish"
ln -sf "$DOTFILES_DIR/.config.fish" "$HOME/.config/fish/config.fish"

if [ "$IS_TERMUX" = false ]; then
	mkdir -p "$HOME/.config/kitty" "$HOME/.config/fontconfig"
	ln -sf "$DOTFILES_DIR/.kitty.conf" "$HOME/.config/kitty/kitty.conf"
	ln -sf "$DOTFILES_DIR/.fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
fi

print_info "Dotfiles linked."
print_info "Setup finished! Restart your shell or run 'refresh'."

# Attempt desktop configuration (best effort)
if [ -f "$DOTFILES_DIR/.configure_desktop.sh" ]; then
    bash "$DOTFILES_DIR/.configure_desktop.sh"
fi

exit 0