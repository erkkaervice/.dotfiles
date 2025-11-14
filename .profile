# ~/.profile: executed by compatible login shells.

# --- Set PATH Early ---
# Set PATH early if needed (optional, could rely on /etc/profile)
# export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# --- Source Common Settings ---

# --- Clear Temp Directory ---
# Clear temp directory on login (if it exists)
# Be cautious with automated rm -rf commands
# [[ -d $HOME/tmp ]] && rm -rf $HOME/tmp/*

# --- Source Shell-Specific RC File ---
# Source shell-specific rc file if login shell is also interactive
if [ -n "$BASH_VERSION" ];
then
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi
if [ -n "$ZSH_VERSION" ];
then
	# include .zshrc if it
	if [ -f "$HOME/.zshrc" ];
	then
		# Zsh should automatically source .zshrc for interactive login shells
		# but explicitly sourcing doesn't hurt if needed.
		# .
		# "$HOME/.zshrc"
		: # Zsh usually handles this
	fi
fi