#!/bin/bash
#
# ~/.dotfiles/.scripts/startfresh.sh
#
# Master "startfresh" (factory reset) script.
# This is the single source of truth, called by wrappers in all shells.
#

# FIX: Removed 'local' - cannot be used at script-level
REPO_ROOT=""

if [ -f "$HOME/.dotfiles-path" ];
then
	REPO_ROOT=$(cat "$HOME/.dotfiles-path")
fi

# Fallback if file is missing
if [ -z "$REPO_ROOT" ];
then
	REPO_ROOT="$HOME/.dotfiles"
fi

echo "--- WARNING: Starting Fresh (Removing all custom dotfile links) ---"
echo "1. Removing config links..."
rm -f ~/.sh_common ~/.profile ~/.bashrc ~/.zshrc ~/.bash_logout
rm -f "$HOME/.ssh_agent_init"
rm -rf ~/.config/fish
rm -rf ~/.config/kitty
rm -rf ~/.config/fontconfig
rm -f "$HOME/.config/shell_secrets"
rm -f "$HOME/.gitconfig" "$HOME/.gitignore_global"

echo "2. Removing local user applications..."
rm -rf ~/.local/kitty.app
rm -rf ~/.fzf
rm -rf ~/.local/share/applications/kitty.desktop

rm -f "$HOME/.dotfiles_initialized_$(id -u)"
rm -f "$HOME/.dotfiles-path" # (C3) Remove path file

echo "3. Creating temporary recovery files to prevent Zsh/Bash wizard..."

# Create a temporary, minimal .bashrc with only the refresh command
cat << EOF > "$HOME/.bashrc"
# --- TEMPORARY RECOVERY SCRIPT ---
echo '---------------------------------------------------'
echo 'RUN: refresh (to rebuild your custom setup)'
echo '---------------------------------------------------'

refresh() {
	echo '--- REFRESHING ENVIRONMENT ---'
	bash "$REPO_ROOT/.setup.sh" || return 1
	echo '--- Environment restored. Please restart your terminal. ---'
	exec \$SHELL --login
}
EOF

# Zsh can use the same recovery file
cp "$HOME/.bashrc" "$HOME/.zshrc"


echo "--- ENVIRONMENT RESET. Starting fresh session. ---"
# FIX: Removed 'local' - cannot be used at script-level
BASH_PATH=/bin/bash
if [ -f /data/data/com.termux/files/usr/bin/bash ];
then
	BASH_PATH=/data/data/com.termux/files/usr/bin/bash
fi
exec $BASH_PATH --login