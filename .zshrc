# ~/.zshrc: executed by zsh(1) for interactive shells.

# FIX: Use POSIX-compliant method to check for interactive shell
case $- in
	*i*) ;;
	*) return;;
esac

# --- Source Common Settings ---
if [[ -f ~/.sh_common ]];
then
	source ~/.sh_common
fi

# --- Fish Shell Auto-Switch ---
# This block is commented out by default.
# Uncomment it if you want Bash/Zsh to *always* try to switch to Fish.
# if [[ $DISPLAY ]];
# then
# 	if [[ "$(ps -p $$ -o comm=)" != "fish" ]]; then
# 		if command -v fish > /dev/null 2>&1;
# then
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

# --- Path Abbreviation Function (CLEANED) ---
_zsh_abbreviate_path_manual() {
	# NOTE: Logic reverted to working original with reliable syntax.
	local pwd_relative_to_home=${PWD/#$HOME/\~}
	[[ "$pwd_relative_to_home" == "/" ]] && { echo "/"; return }
	[[ "$pwd_relative_to_home" == "~" ]] && { echo "~"; return }

	local prefix=""; local path_to_process=""
	if [[ "$pwd_relative_to_home" == \~* ]]; then
		prefix="~/"
		path_to_process=${pwd_relative_to_home#\~/}
	elif [[ "$pwd_relative_to_home" == /* ]]; then
		prefix="/"
		path_to_process=${pwd_relative_to_home#/}
	else
		echo "$pwd_relative_to_home"; return
	fi

	local -a path_parts
	path_parts=( ${(s:/:)path_to_process} )
	local result="$prefix"; local num_parts=${#path_parts[@]}; local i

	for (( i=1; i <= num_parts; i++ ));
	do
		if (( i < num_parts )); then # Intermediate directory
			local part=${path_parts[i]}
			if [[ "$part" == .* ]];
			then
				 # FIX: Use reliable slice syntax to fix the original bug in the path logic
				 result+=".${part:1:1}/"
			 elif [[ -n "$part" ]];
			then
				result+="${part:0:1}/"
			fi
		elif [[ -n "${path_parts[i]}" ]]; then # Last directory
			result+="${path_parts[i]}"
		fi
	done

	if [[ "$result" == */ ]] && [[ "$num_parts" -eq 0 && "$prefix" != "/" ]];
	then
		result="${result%/}"
	fi
	echo "$result"
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
	# 1. Execute function and store the path result (e.g., '~/h/cpp')
	local abbreviated_wd=$(_zsh_abbreviate_path_manual)
    
	# 2. Set the final PROMPT.
	PROMPT="%F{cyan}[$(service_user)@%m${abbreviated_wd}]%f${vcs_info_msg_0_}> "
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