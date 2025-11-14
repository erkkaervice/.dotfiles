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

# --- Path Abbreviation Function (FINAL FIXED VERSION using Zsh array joining) ---
_zsh_abbreviate_path_manual() {
	local full_path="${PWD/#$HOME/\~}"
	
	if [[ "$full_path" == "/" ]]; then echo "/"; return; fi
	if [[ "$full_path" == "~" ]]; then echo "~"; return; } # Changed to { } block
    
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

	# 2. Split path into array elements (Zsh arrays are 1-indexed)
	local path_parts=( ${(s:/:)path_to_process} )
	local num_parts=${#path_parts[@]};
	local result_parts=()
	local i

	# 3. Process all but the last part (abbreviate intermediate directories)
	for (( i=1; i < num_parts; i++ )); do
		local part=${path_parts[i]}
		if [[ "$part" == .* ]]; then
			# If dotfile, keep dot and first char: .d/
			result_parts+=( ".${part:1:1}" ) 
		elif [[ -n "$part" ]]; then
			# Otherwise, keep first char: d/
			result_parts+=( "${part:0:1}" )
		fi
	done
    
	# 4. Append the last part (the full directory name)
	if [[ -n "${path_parts[num_parts]}" ]]; then
		result_parts+=( "${path_parts[num_parts]}" )
	fi

	# 5. Join the parts with '/' and prepend the prefix (~/ or /)
    # ${(j:/:)array} is Zsh's highly reliable array join syntax.
    local joined_path="${(j:/:)result_parts}"
    
    # Handle the special case where the path is just a single dot or nothing
    if [[ -z "$joined_path" && "$prefix" == "~/" ]]; then
        echo "~"
        return
    fi
    
	echo "${prefix}${joined_path}"
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

# PROMPT: [user@host path](git) >
PROMPT='%F{cyan}[$(service_user)@%m $(_zsh_abbreviate_path_manual)]%f ${vcs_info_msg_0_}> '