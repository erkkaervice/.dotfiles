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
		path_to_process="${pwd_relative_to_home#\~/}"
	elif [[ "$pwd_relative_to_home" == /* ]]; then
		prefix="/"
		path_to_process="${pwd_relative_to_home#/}"
	fi

	local path_parts=( ${(s:/:)path_to_process} )
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

	if [[ "$result" == */ ]] && [[ "$num_parts" -gt 0 && "$prefix" != "/" ]]; then
		result="${result%/}"
	fi
	echo "$result"
}


# --- Zsh Git-Aware Prompt ---
autoload -U promptinit
promptinit
setopt PROMPT_SUBST
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%F{magenta}(%b%u%c)%f'
zstyle ':vcs_info:git:*' actionformats '%F{magenta}(%b|%a%u%c)%f'

precmd() {
	vcs_info
	local abbreviated_wd=$(_zsh_abbreviate_path_manual)
	PROMPT="%F{cyan}[$(service_user)@%m${abbreviated_wd}]%f${vcs_info_msg_0_}> "
}

# --- Tmux Auto-Attach Logic ---
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach-session -t main || tmux new-session -s main
fi