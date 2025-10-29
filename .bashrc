# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- Source Common Settings ---
if [ -f "$HOME/.sh_common" ]; then
	. "$HOME/.sh_common"
fi

# --- Fish Shell Auto-Switch ---
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

# --- Path Abbreviation Function ---
_bash_abbreviate_path() {
	local full_path="${PWD/#$HOME/\~}"
	# Handle root edge case
	if [[ "$full_path" == "/" ]]; then echo "/"; return; fi
	# Handle home edge case
	if [[ "$full_path" == "~" ]]; then echo "~"; return; fi

	local prefix=""
	local path_to_process=""
	if [[ "$full_path" == \~* ]]; then
		prefix="~/"
		path_to_process="${full_path#\~/}"
	elif [[ "$full_path" == /* ]]; then
		prefix="/"
		path_to_process="${full_path#/}"
	else
		 echo "$full_path"; return; # Fallback for relative/unexpected paths
	fi

	local IFS='/'
	local -a path_parts
	read -ra path_parts <<< "$path_to_process"

	local result="$prefix"
	local num_parts=${#path_parts[@]}
	local i

	for (( i=0; i < num_parts; i++ )); do
		if (( i < num_parts - 1 )); then # Intermediate directory
			if [[ "${path_parts[i]}" == .* ]]; then
				# Keep dot, take first char after dot, add slash
				result+=".${path_parts[i]:1:1}/"
			elif [ -n "${path_parts[i]}" ]; then # Avoid empty parts creating //
				# Take first char, add slash
				 result+="${path_parts[i]:0:1}/"
			fi
		elif [ -n "${path_parts[i]}" ]; then # Last directory
			result+="${path_parts[i]}"
		fi
	done

	# Remove trailing slash if necessary (e.g. results in ~/a/)
	if [[ "$result" == */ ]] && [[ "$num_parts" -gt 0 ]]; then
		 result="${result%/}"
	fi

	echo "$result"
}

# --- Custom Git Prompt Function (for Bash) ---
# Replaces __git_ps1 to use 'U' for unstaged changes like Zsh/Fish
_bash_custom_git_prompt() {
	local git_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
	if [[ -n "$git_branch" ]]; then # Check if inside a git repo
		local git_status=$(git status --porcelain 2>/dev/null)
		local unstaged=""
		local staged=""

		# Check porcelain output for unstaged/modified/deleted/untracked
		if [[ "$git_status" =~ ( M | \?\? | D ) ]]; then
			unstaged="U" # Use U like Zsh
		fi
		# Check porcelain output for staged adds/mods/deletes
		if [[ "$git_status" =~ ^(M |A |D) ]]; then
			staged="+"
		fi

		# Construct the output string, e.g., "(mainU+)"
		echo "(${git_branch}${unstaged}${staged})"
	fi
}


# --- Bash Git-Aware Prompt ---

# Set the prompt format: [user@host abbr_dir](git-info)>
# Calls _bash_custom_git_prompt for Git status
PS1='\[\e[0;36m\][$(service_user)@\h$(_bash_abbreviate_path)]\[\e[0m\]\[\e[0;35m\]$(_bash_custom_git_prompt)\[\e[0m\]> '


# --- Initialize Modern Tools ---

# Initialize zoxide (smarter cd)
if command -v zoxide > /dev/null 2>&1; then
	eval "$(zoxide init bash)"
fi

# Initialize fzf (fuzzy finder keybindings)
if [ -f ~/.fzf.bash ]; then
	. ~/.fzf.bash
fi

# --- Bash Specific Options ---
shopt -s extglob
shopt -s histappend
shopt -s checkwinsize
export HISTCONTROL=ignoreboth

# --- Bash Completion ---
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

# --- Global Definitions (Optional) ---
# Source global definitions if applicable
#if [ -f /etc/bashrc ]; then
#	. /etc/bashrc
#fi

# --- User Customizations (Optional) ---
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
