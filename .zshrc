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

# --- Path Abbreviation Function ---
_zsh_abbreviate_path_manual() {
	local full_path="${PWD/#$HOME/\~}"
	
	if [[ "$full_path" == "/" ]]; then echo "/"; return; fi
	if [[ "$full_path" == "~" ]]; then echo "~"; return; fi

	local prefix=""; local path_to_process=""
	if [[ "$full_path" == \~* ]];
	then
		prefix="~/"
		path_to_process="${full_path#\~/}"
	elif [[ "$full_path" == /* ]]; then
		prefix="/"
		path_to_process="${full_path#/}"
	fi

	local path_parts=( ${(s:/:)path_to_process} )
	local result="$prefix"; 
	local num_parts=${#path_parts[@]};
	local i

	for (( i=1; i <= num_parts; i++ )); do
		if (( i < num_parts ));
		then # Intermediate directory
			local part=${path_parts[i]}
			if [[ "$part" == .* ]]; then
				result+=".${part:1:1}/"
			elif [[ -n "$part" ]]; then
				result+="${part:0:1}/"
			fi
		elif [[ -n "${path_parts[i]}" ]]; then # Last directory
			result+="${path_parts[i]}"
		fi
	done

	if [[ "$result" == */ ]] && [[ "$num_parts" -gt 0 && "$prefix" != "/" ]];
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