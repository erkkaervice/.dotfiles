# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source common settings
if [ -f "$HOME/.sh_common" ]; then
	. "$HOME/.sh_common"
fi

# Enter fish for graphical sessions
# (Requires: fish)
if [[ $DISPLAY ]]; then
	# Check if current shell is already fish to avoid loops
	if [[ "$(ps -p $$ -o comm=)" != "fish" ]]; then
		if command -v fish > /dev/null 2>&1; then
			export SHELL=/usr/bin/fish
			exec fish "$@"
			# If exec fails, reset SHELL and print error
			export SHELL=/bin/bash
			echo "Failed to switch to fish shell." >&2
		fi
	fi
fi

# --- Bash Git-Aware Prompt ---

# Source the git-prompt script (locations vary)
if [ -n "$PREFIX" ] && [ -f "$PREFIX/share/git/contrib/completion/git-prompt.sh" ]; then
	# TERMUX-SPECIFIC PATH: Check for git-prompt.sh in Termux's $PREFIX
	. "$PREFIX/share/git/contrib/completion/git-prompt.sh"
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
	. /usr/share/git-core/contrib/completion/git-prompt.sh
elif [ -f /usr/lib/git-core/git-prompt.sh ]; then
	. /usr/lib/git-core/git-prompt.sh
elif [ -f /etc/bash_completion.d/git-prompt ]; then
	. /etc/bash_completion.d/git-prompt
fi

# Enable features: %s = branch, * = unstaged, + = staged
if command -v __git_ps1 > /dev/null; then
	export GIT_PS1_SHOWDIRTYSTATE=1
	export GIT_PS1_SHOWUNTRACKEDFILES=
	export GIT_PS1_SHOWSTASHSTATE=
	export GIT_PS1_SHOWUPSTREAM=

	# Set the prompt format: [user@host dir] (git-info)$
	# Use cyan for main prompt, magenta for git
	# Use $PS1_USER instead of \u for custom display name
	PS1='\[\e[0;36m\][$PS1_USER@\h \W]\[\e[0m\]\[\e[0;35m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
else
	# Fallback to original prompt if git-prompt.sh wasn't found
	PS1='[\u@\h \W]\$ '
fi

# --- Initialize Modern Tools ---

# Initialize zoxide (smarter cd)
if command -v zoxide > /dev/null 2>&1; then
	eval "$(zoxide init bash)"
fi

# Initialize fzf (fuzzy finder keybindings)
if [ -f ~/.fzf.bash ]; then
	. ~/.fzf.bash
fi

# Bash specific options
shopt -s extglob
shopt -s histappend
shopt -s checkwinsize
export HISTCONTROL=ignoreboth

# Bash completion
# Ensure bash-completion package is installed
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi
complete -c man which
complete -cf sudo

# Source global definitions if applicable
#if [ -f /etc/bashrc ]; then
#	. /etc/bashrc
#fi

# User specific aliases and functions directory (Bash convention)
#if [ -d ~/.bashrc.d ]; then
#	for rc in ~/.bashrc.d/*; do
#		if [ -f "$rc" ]; then
#			. "$rc"
#		fi
#	done
#fi
#unset rc

# Example lesspipe setup (often default on Ubuntu)
#[ -x /usr/bin/lesspipe ] && eval