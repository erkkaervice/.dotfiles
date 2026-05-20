#!/bin/bash
#
# setup.sh - Installs dependencies, fonts, and links dotfiles.
# Supports: Debian, Ubuntu, Kali, Tails, Arch, SystemRescue, Fedora, OpenSUSE, Alpine, NixOS, macOS, Termux.
#

# --- Helper Functions ---
print_info() { echo "[INFO] $1"; }
print_error() { echo "[ERROR] $1" >&2; }
print_warning() { echo "[WARN] $1" >&2; }

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

echo "$DOTFILES_DIR" > "$HOME/.dotfiles-path"

# Add ~/.local/bin to PATH immediately for this script
export PATH="$PATH:$HOME/.local/bin"

check_sudo_and_set_flag

# --- Basic OS Detection ---
OS_ID="unknown"
if [ "$IS_TERMUX" = true ]; then 
    OS_ID="termux"
elif [ -f /etc/os-release ]; then 
    . /etc/os-release
    OS_ID=$ID
    # Check ID_LIKE for derivatives if specific ID isn't caught later
elif [ -f /etc/arch-release ]; then 
    OS_ID="arch"
elif [ "$(uname)" == "Darwin" ]; then 
    OS_ID="macos"
fi

# --- System Package Installation ---
if [ "$CAN_INSTALL_PACKAGES" = true ]; then
    print_info "Detected OS ID: $OS_ID. Attempting package installation..."
    INSTALL_FAILED=false
    
    case "$OS_ID" in
        termux)
            print_info "Installing packages for Termux..."
            pkg update -y
            for pkg in curl git fish unzip p7zip unrar zstd fzf bat fd ripgrep zoxide nmap gnupg clang dnsutils jq tmux neovim direnv libarchive; do
                pkg install -y "$pkg" || { INSTALL_FAILED=true; print_error "Failed to install $pkg"; }
            done
            ;;
        ubuntu|debian|pop|mint|kali|tails)
            print_info "Installing packages for Debian family (Ubuntu, Kali, Tails)..."
            sudo apt-get update -qq
            for pkg in curl git fish unzip p7zip-full unrar zstd fzf bat fd-find ripgrep zoxide kitty fonts-inconsolata fontconfig nmap gnupg lynis tcpdump build-essential dnsutils libarchive-tools jq tmux neovim direnv; do
                sudo apt-get install -y "$pkg" || { INSTALL_FAILED=true; print_error "Failed to install $pkg"; }
            done
            ;;
        arch|manjaro|steamos|systemrescue)
            print_info "Installing packages for Arch family (SystemRescue, SteamOS)..."
            sudo pacman -Syu --noconfirm
            for pkg in curl git fish base-devel bind-tools unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty ttf-inconsolata fontconfig nmap gnupg trivy gitleaks lynis tcpdump jq tmux neovim direnv libarchive; do
                sudo pacman -S --noconfirm --needed "$pkg" || { INSTALL_FAILED=true; print_error "Failed to install $pkg"; }
            done
            ;;
        fedora|rhel|centos)
            print_info "Installing packages for Fedora family..."
            for pkg in curl git fish unzip p7zip p7zip-plugins unrar zstd fzf bat fd-find ripgrep zoxide kitty levien-inconsolata-fonts fontconfig nmap gnupg lynis tcpdump bind-utils libarchive jq tmux neovim direnv; do
                sudo dnf install -y "$pkg" || { INSTALL_FAILED=true; print_error "Failed to install $pkg"; }
            done
            ;;
        opensuse*|suse)
            print_info "Installing packages for OpenSUSE..."
            sudo zypper refresh
            for pkg in curl git fish unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty google-inconsolata-fonts fontconfig nmap gnupg trivy gitleaks lynis tcpdump gcc bind-utils bsdtar jq tmux neovim direnv; do
                sudo zypper install -y "$pkg" || { INSTALL_FAILED=true; print_error "Failed to install $pkg"; }
            done
            ;;
        alpine)
            print_info "Installing packages for Alpine..."
            sudo apk update
            for pkg in curl git fish unzip p7zip unrar zstd fzf bat fd ripgrep zoxide kitty font-inconsolata fontconfig nmap gnupg trivy gitleaks lynis tcpdump gcc bind-tools libarchive jq tmux neovim direnv zsh-vcs; do
                sudo apk add "$pkg" || { INSTALL_FAILED=true; print_error "Failed to install $pkg"; }
            done
            ;;
        nixos)
            print_info "Installing packages for NixOS (Imperative User Profile)..."
            for pkg in nixos.curl nixos.git nixos.fish nixos.unzip nixos.p7zip nixos.unrar nixos.zstd nixos.fzf nixos.bat nixos.fd nixos.ripgrep nixos.zoxide nixos.kitty nixos.nmap nixos.gnupg nixos.trivy nixos.gitleaks nixos.lynis nixos.tcpdump nixos.bind nixos.libarchive nixos.jq nixos.tmux nixos.neovim nixos.direnv; do
                nix-env -iA "$pkg" || { INSTALL_FAILED=true; print_error "Failed to install $pkg"; }
            done
            ;;
        macos)
            if command -v brew >/dev/null; then
                print_info "Installing packages for macOS (Homebrew)..."
                brew update
                for pkg in curl iproute2mac git fish unzip sevenzip unrar zstd fzf bat fd ripgrep zoxide kitty nmap gnupg trivy gitleaks lynis tcpdump gcc bind libarchive jq tmux neovim direnv; do
                    brew install "$pkg" || { INSTALL_FAILED=true; print_error "Failed to install $pkg"; }
                done
                brew install --cask font-inconsolata 2>/dev/null || { INSTALL_FAILED=true; print_error "Failed to install font-inconsolata"; }
            else 
                INSTALL_FAILED=true
            fi
            
            if [ "$INSTALL_FAILED" = true ]; then
                print_error "One or more Homebrew packages failed, or Homebrew is missing."
            else
                print_info "Homebrew installation successful."
            fi
            ;;
        *) 
            print_error "Unsupported OS ID: $OS_ID. Attempting fallback local install..."
            INSTALL_FAILED=true 
            ;;
    esac
else 
    print_info "Skipping system packages (no sudo or non-root)."
fi

# --- Fallback: Local Tool Installation (No Sudo Required) ---
if [ "$IS_TERMUX" = false ]; then
    mkdir -p "$HOME/.local/bin"
    
    if ! command -v curl >/dev/null 2>&1; then
        print_warning "curl not found. Skipping local fallbacks for Kitty, Zoxide, and Direnv."
    else
        # 1. Kitty Fallback
        if ! command -v kitty >/dev/null 2>&1 && [ "$OS_ID" != "macos" ]; then
            print_info "Fallback: Installing Kitty locally..."
            curl -fSL --proto '=https' https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n dest="$HOME/.local"
            ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
            ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"
        fi
        # 3. Zoxide, and Direnv Fallbacks
        if ! command -v zoxide >/dev/null 2>&1; then print_info "Fallback: Zoxide..."; curl -sSf --proto '=https' https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; fi
        if ! command -v direnv >/dev/null 2>&1; then print_info "Fallback: direnv..."; curl -sfL https://direnv.net/install.sh | bash; fi
    fi
    
    if ! command -v git >/dev/null 2>&1; then
        print_warning "git not found. Skipping local fallback for FZF."
    else
        # 2. FZF Fallback
        if ! command -v fzf >/dev/null 2>&1; then print_info "Fallback: FZF..."; git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; ~/.fzf/install --all --no-bash --no-zsh --no-fish; ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"; fi
    fi

    # 2. Kitty Desktop Integration
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
fi

# --- Custom Font Installation ---
if [ "$IS_TERMUX" = false ]; then
    [ "$OS_ID" == "macos" ] && UFD="$HOME/Library/Fonts" || UFD="$HOME/.local/share/fonts"
    mkdir -p "$UFD"
    FONTS_DIR="$DOTFILES_DIR/.fonts"
    if [ -d "$FONTS_DIR" ] && [ "$(ls -A "$FONTS_DIR"/*.ttf 2>/dev/null)" ]; then
        print_info "Installing all custom TTF fonts from .fonts/ directory...";
        cp -f "$FONTS_DIR"/*.ttf "$UFD"/ 2>/dev/null
    else
        print_warning "No TTF fonts found in .fonts/ directory. Skipping font installation."
    fi
    [ "$OS_ID" != "macos" ] && command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$UFD"

elif [ "$IS_TERMUX" = true ]; then
    print_info "Installing Inconsolata Nerd Font (Termux)..."
    mkdir -p "$HOME/.termux"
    LOCAL_FONT="$DOTFILES_DIR/.fonts/InconsolataNerdFont-Regular.ttf"
    TERMUX_FONT="$HOME/.termux/font.ttf"
    if [ -f "$LOCAL_FONT" ]; then
        print_info "Copying local Inconsolata Nerd Font to ~/.termux/font.ttf"
        cp "$LOCAL_FONT" "$TERMUX_FONT"
        if [ -f "$TERMUX_FONT" ]; then
            print_info "Applying font changes..."
            command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings
        fi
    else
        print_error "Could not find InconsolataNerdFont-Regular.ttf in .fonts/. Please ensure it is downloaded and placed there."
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
for f in .sh_common .profile .bashrc .zshrc .bash_logout .ssh_agent_init; do ln -sf "$DOTFILES_DIR/$f" "$HOME/$f"; done

# Safely transition from symlink to include.path without infinite loops
if [ -L "$HOME/.gitconfig" ]; then
    rm -f "$HOME/.gitconfig"
fi
git config --global --unset-all include.path "$DOTFILES_DIR/.gitconfig" 2>/dev/null || true
git config --global --add include.path "$DOTFILES_DIR/.gitconfig"

ln -sf "$DOTFILES_DIR/.gitignore" "$HOME/.gitignore_global"
print_info "Linked .gitconfig and .gitignore_global."

mkdir -p "$HOME/.config/fish"; ln -sf "$DOTFILES_DIR/.config.fish" "$HOME/.config/fish/config.fish"
mkdir -p "$HOME/.config/nvim"; ln -sf "$DOTFILES_DIR/.init.vim" "$HOME/.config/nvim/init.vim"
mkdir -p "$HOME/.var/app/io.neovim.nvim/config/nvim"; ln -sf "$DOTFILES_DIR/.init.vim" "$HOME/.var/app/io.neovim.nvim/config/nvim/init.vim"
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

touch "$HOME/.gitconfig_local"

if [ "$IS_TERMUX" = false ]; then
    mkdir -p "$HOME/.config/kitty" "$HOME/.config/fontconfig"
    ln -sf "$DOTFILES_DIR/.kitty.conf" "$HOME/.config/kitty/kitty.conf"
    ln -sf "$DOTFILES_DIR/.fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
fi
print_info "Dotfiles linked. Setup finished!"

print_info "Ensuring dotfiles scripts are executable..."
chmod +x "$HOME/.ssh_agent_init"
chmod +x "$DOTFILES_DIR/.setup.sh"
chmod +x "$DOTFILES_DIR/.scripts/refresh.sh"
chmod +x "$DOTFILES_DIR/.scripts/cleanup.sh"
chmod +x "$DOTFILES_DIR/.scripts/startfresh.sh"
[ -f "$DOTFILES_DIR/.configure_desktop.sh" ] && chmod +x "$DOTFILES_DIR/.configure_desktop.sh"

[ -f "$DOTFILES_DIR/.configure_desktop.sh" ] && bash "$DOTFILES_DIR/.configure_desktop.sh"
exit 0
