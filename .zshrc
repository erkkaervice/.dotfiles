# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ ! -o interactive ]] && return

# --- Source Common Settings ---
if [[ -f ~/.sh_common ]];
then
	source ~/.sh_common
fi

# --- Fish Shell Auto-Switch ---
# Switch to Fish in graphical sessions, fall back to Zsh if not.
# if [[ $DISPLAY ]]; then
# 	if [[ "$(ps -p $$ -o comm=)" != "fish" ]]; then
# 		if command -v fish > /dev/null 2>&1; then
# 			export SHELL=/usr/bin/fish
# 			exec fish "$@"
# 			export SHELL=/bin/zsh
# 			echo "Failed to switch to fish shell." >&2
# 		fi
# 	fi
# fi

# Initialize Zsh Completion System
autoload -Uz compinit
compinit -u

# --- Path Abbreviation Function (FINAL Zsh Fix) ---
_zsh_abbreviate_path_manual() {
	# Use Zsh's built-in parameter expansion to resolve $HOME to ~
	local full_path="${PWD/#$HOME/\~}"
	
	if [[ "$full_path" == "/" ]]; then echo "/"; return; fi
	if [[ "$full_path" == "~" ]]; then echo "~"; return; fi

	local prefix=""; local path_to_process=""
	
	# Determine if we need to keep a prefix (~/ or /)
	if [[ "$full_path" == \~* ]];
	then
		prefix="~/"
		path_to_process="${full_path#\~/}"
	elif [[ "$full_path" == /* ]]; then
		prefix="/"
		path_to_process="${full_path#/}"
	fi

	# Split path into array elements. This method is cleaner in Zsh.
	local path_parts=( ${(s:/:)path_to_process} )
	local result="$prefix"
	local num_parts=${#path_parts[@]};

	# Loop through all but the last part (Zsh arrays are 1-indexed)
	for (( i=1; i < num_parts; i++ )); do
		local part=${path_parts[i]}
		if [[ "$part" == .* ]]; then
			# If dotfile, keep dot and first char: .d/
			result+=".${part:1:1}/" 
		elif [[ -n "$part" ]]; then
			# Otherwise, keep first char: d/
			result+="${part:0:1}/"
		fi
	done
    
	# Append the last part (the full directory name)
	if [[ -n "${path_parts[num_parts]}" ]]; then
		result+="${path_parts[num_parts]}"
	fi

	# Cleanup: The final path should not end in a slash unless it's root
	# This handles the edge case where the loop might leave a trailing slash.
	if [[ "$result" == */ ]] && [[ "$num_parts" -gt 0 ]];
	then
		result="${result%/}"
	fi
	echo "$result"
}

# --- Zsh Git-Aware Prompt ---
autoload -U promptinit
promptinit
setopt PROMPT_SUBST
autoload -Uz vcs_info

# Set vcs_info options
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%F{magenta}(%b%u%c)%f'
zstyle ':vcs_info:git:*' unstagedstr 'U'
zstyle ':vcs_info:git:*' stagedstr '+'

# Pre-prompt function to update vcs_info
precmd() {
	vcs_info
}

# --- Zsh Git-Aware Prompt ---
PROMPT='%F{cyan}[$(service_user)@%m $(_zsh_abbreviate_path_manual)]%f ${vcs_info_msg_0_}> '