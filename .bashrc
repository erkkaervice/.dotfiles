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

# Bash Prompt configuration
PS1='[\u@\h \W]\$ '

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
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
