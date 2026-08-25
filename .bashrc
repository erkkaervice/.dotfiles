# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- Source Common Settings ---
if [ -f "$HOME/.sh_common" ]; then
	. "$HOME/.sh_common"
fi

# --- Fish Shell Auto-Switch ---
# This block is commented out by default.
# Uncomment it if you want Bash/Zsh to *always* try to switch to Fish.
# if [[ $DISPLAY ]]; then
# 	if [[ "$(ps -p $$ -o comm=)" != "fish" ]]; then
# 		if command -v fish > /dev/null 2>&1; then
# 			export SHELL=/usr/bin/fish
# 			exec fish "$@"
# 			export SHELL=/bin/bash
# 			echo "Failed to switch to fish shell." >&2
# 		fi
# 	fi
# fi

# --- Path Abbreviation Function ---
_bash_abbreviate_path() {
	local full_path="${PWD/#$HOME/\~}"
	if [[ "$full_path" == "/" ]]; then echo "/"; return; fi
	if [[ "$full_path" == "~" ]]; then echo "~"; return; fi

	local prefix=""; local path_to_process=""
	if [[ "$full_path" == \~* ]]; then
		prefix="~/"
		path_to_process="${full_path#\~/}"
	elif [[ "$full_path" == /* ]]; then
		prefix="/"
		path_to_process="${full_path#/}"
	else
		 echo "$full_path"; return;
	fi

	local IFS='/'; local -a path_parts
	read -ra path_parts <<< "$path_to_process"
	local result="$prefix"; local num_parts=${#path_parts[@]}; local i

	for (( i=0; i < num_parts; i++ )); do
		if (( i < num_parts - 1 )); then # Intermediate directory
			if [[ "${path_parts[i]}" == .* ]]; then
				result+=".${path_parts[i]:1:1}/"
			elif [ -n "${path_parts[i]}" ]; then
				 result+="${path_parts[i]:0:1}/"
			fi
		elif [ -n "${path_parts[i]}" ]; then # Last directory
			result+="${path_parts[i]}"
		fi
	done

	if [[ "$result" == */ ]] && [[ "$num_parts" -gt 0 ]]; then
		 result="${result%/}"
	fi
	echo "$result"
}

# --- Custom Git Prompt Function (for Bash) ---
_bash_custom_git_prompt() {
	local git_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
	if [[ -n "$git_branch" ]]; then
		local git_status=$(git status --porcelain 2>/dev/null)
		local unstaged=""; local staged=""
		# Check for unstaged/modified/deleted/untracked
		if [[ "$git_status" =~ \?\? ]] || [[ "$git_status" =~ " M " ]] || [[ "$git_status" =~ " D " ]]; then
			unstaged="U"
		fi
		# Check for staged adds/mods/deletes
		if [[ "$git_status" =~ ^(M |A |D) ]]; then
			staged="+"
		fi
		echo "(${git_branch}${unstaged}${staged})"
	fi
}

# --- Bash Git-Aware Prompt ---
# Fetch service user once at initialization to save CPU cycles
SERVICE_USER=$(service_user 2>/dev/null || echo "ervice")

_bash_prompt_command() {
	local abbr_path=$(_bash_abbreviate_path)
	local git_info=$(_bash_custom_git_prompt)
	
	# Wrap ANSI color codes in \[ \] to prevent visual line-wrapping bugs
	PS1="\[\e[0;36m\][${SERVICE_USER}@\h${abbr_path}]\[\e[0m\]\[\e[0;35m\]${git_info}\[\e[0m\]> "
}

# Use PROMPT_COMMAND to evaluate the prompt variables before drawing,
# safely prepending to preserve OS-level VTE or title integrations.
PROMPT_COMMAND="_bash_prompt_command${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- Bash Specific Options ---
shopt -s extglob
shopt -s histappend
shopt -s checkwinsize
export HISTCONTROL=ignoreboth

# --- Bash Completion ---
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi
complete -c man which
complete -cf sudo
