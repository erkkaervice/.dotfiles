# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ ! -o interactive ]] && return

# --- Source Common Settings ---
if [[ -f ~/.sh_common ]]; then
	source ~/.sh_common
fi

# --- Source SSH Agent (Interactive Only) ---
if [ -f "$HOME/.ssh_agent_init" ]; then
	. "$HOME/.ssh_agent_init"
fi

# --- Fish Shell Auto-Switch ---
# This block is commented out by default.
# Uncomment it if you want Bash/Zsh to *always* try to switch to Fish.
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

	for (( i=1; i <= num_parts; i++ )); do
		if (( i < num_parts )); then # Intermediate directory
			if [[ "${path_parts[i]}" == .* ]]; then
				 result+=".${path_parts[i][2]}/"
			 elif [[ -n "${path_parts[i]}" ]]; then
				result+="${path_parts[i][1]}/"
			fi
		elif [[ -n "${path_parts[i]}" ]]; then # Last directory
			result+="${path_parts[i]}"
		fi
	done

	if [[ "$result" == */ ]] && [[ "$num_parts" -eq 0 && "$prefix" != "/" ]]; then
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
# %b = branch, %u = unstaged, %c = staged
# 'formats' is for when inside a repo, 'actionformats' is for during actions (e.g., rebase)
zstyle ':vcs_info:git:*' formats '%F{magenta}(%b%u%c)%f'
zstyle ':vcs_info:git:*' actionformats '%F{magenta}(%b|%a%u%c)%f'

# This function runs *before* every prompt is drawn
precmd() {
	vcs_info
	local abbreviated_wd=$(_zsh_abbreviate_path_manual)
	# Build the prompt with colors and function calls
	PROMPT="%F{cyan}[$(service_user)@%m${abbreviated_wd}]%f${vcs_info_msg_0_}> "
}

# --- Initialize Modern Tools ---
if command -v zoxide > /dev/null 2>&1; then
	eval "$(zoxide init zsh)"
fi
if [ -f ~/.fzf.zsh ]; then
	. ~/.fzf.zsh
fi

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
SAVEHIST=10000

bindkey -e
