# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ ! -o interactive ]] && return

# --- Source Common Settings ---
if [[ -f ~/.sh_common ]];
then
	source ~/.sh_common
fi

# --- Fish Shell Auto-Switch ---
# This block is commented out by default.
# Uncomment it if you want Bash/Zsh to *always* try to switch to Fish.
# if [[ $DISPLAY ]]; then
# 	if [[ "$(ps -p $$ -o comm=)" != "fish" ]];
# then
# 		if command -v fish > /dev/null 2>&1; then
# 			export SHELL=/usr/bin/fish
# 			exec fish "$@"
# 			export SHELL=/bin/zsh
# 			echo "Failed to switch to fish shell."
# >&2
# 		fi
# 	fi
# fi

# Initialize Zsh Completion System
autoload -Uz compinit
compinit -u

# --- Path Abbreviation Function (FINAL SYNTAX FIX) ---
_zsh_abbreviate_path_manual() {
	local full_path="${PWD/#$HOME/\~}"
	
	# FIX: Correct single-line syntax using 'fi'
	if [[ "$full_path" == "/" ]]; then echo "/"; return; fi
	if [[ "$full_path" == "~" ]]; then echo "~"; return; fi

	local path_to_process=""
	local prefix=""

	# 1. Determine prefix and remove it from path for processing
	if [[ "$full_path" == \~* ]];
	then
		prefix="~/"
		path_to_process="${full_path#\~/}"
	elif [[ "$full_path" == /* ]]; then
		prefix="/"
		path_to_process="${full_path#/}"
	fi

	# 2. Split path into array elements
	local path_parts=( ${(s:/:)path_to_process} )
	local num_parts=${#path_parts[@]};
	local result_parts=()
	local i

	# 3. Process all but the last part (abbreviate intermediate directories)
	for (( i=1; i < num_parts; i++ )); do
		local part=${path_parts[i]}
		if [[ "$part" == .* ]]; then
			result_parts+=( ".${part:1:1}" ) 
		elif [[ -n "$part" ]]; then
			result_parts+=( "${part:0:1}" )
		fi
	done
    
	# 4. Append the last part (the full directory name)
	if [[ -n "${path_parts[num_parts]}" ]]; then
		result_parts+=( "${path_parts[num_parts]}" )
	fi

	# 5. Join the parts and prepend the prefix (~/ or /)
    local joined_path="${(j:/:)result_parts}"
    
	# Handle the edge case where the path is just home (kept for safety)
	if [[ -z "$joined_path" && "$prefix" == "~/" ]]; then
		echo "~"
		return
	fi
    
	echo "${prefix}${joined_path}"
}

# --- Zsh Git-Aware Prompt ---
autoload -U promptinit
promptinit
# Allow substitutions (like function calls) in the prompt
setopt PROMPT_SUBST

# Load version control info
autoload -Uz vcs_info
# Enable Git backend and check for changes
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true

# Set formats:
zstyle ':vcs_info:git:*' formats '%F{magenta}(%b%u%c)%f'
zstyle ':vcs_info:git:*' actionformats '%F{magenta}(%b|%a%u%c)%f'

# This function runs *before* every prompt is drawn
precmd() {
	vcs_info
	local abbreviated_wd=$(_zsh_abbreviate_path_manual)
	
	PROMPT="%F{cyan}[$(service_user)@%m ${abbreviated_wd}]%f${vcs_info_msg_0_}> "
}

# --- Zsh Specific Options ---
setopt EXTENDED_GLOB
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt CORRECT
setopt COMPLETE_IN_WORD
# setopt NO_BEEP

HISTFILE=~/.zsh_history
HISTSIZE=10000