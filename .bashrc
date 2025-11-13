# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- Source Common Settings ---
if [ -f "$HOME/.sh_common" ];
then
	. "$HOME/.sh_common"
fi

# --- Source SSH Agent (Interactive Only) ---
if [ -f "$HOME/.ssh_agent_init" ]; then
	. "$HOME/.ssh_agent_init"
fi

# --- Fish Shell Auto-Switch ---
# This block is commented out by default.
# if [[ $DISPLAY ]];
# then
# 	if [[ "$(ps -p $$ -o comm=)" != "fish" ]]; then
# 		if command -v fish > /dev/null 2>&1;
# 		then
# 			export SHELL=/usr/bin/fish
# 			exec fish "$@"
# 			export SHELL=/bin/bash
# 			echo "Failed to switch to fish shell."
# 			>&2
# 		fi
# 	fi
# fi

# --- Path Abbreviation Function ---
_bash_abbreviate_path() {
	local full_path="${PWD/#$HOME/\~}"
	if [[ "$full_path" == "/" ]]; then echo "/"; return;
	fi
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

	IFS='/' read -r -a path_parts <<< "$path_to_process"
	local result="$prefix"; local num_parts=${#path_parts[@]};
	local i

	for (( i=0; i < num_parts; i++ )); do
		if (( i < num_parts - 1 ));
		then # Intermediate directory
			if [[ "${path_parts[i]}" == .* ]]; then
				result+=".${path_parts[i]:1:1}/"
			elif [ -n "${path_parts[i]}" ]; then
				result+="${path_parts[i]:0:1}/"
			fi
		elif [ -n "${path_parts[i]}" ];
		then # Last directory
			result+="${path_parts[i]}"
		fi
	done
	if [[ "$result" == */ ]] && [[ "$num_parts" -gt 0 ]];
	then
		result="${result%/}"
	fi
	echo "$result"
}

# --- Custom Git Prompt Function (for Bash) ---
_bash_custom_git_prompt() {
	local git_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
	if [[ -n "$git_branch" ]];
	then
		local git_status=$(git status --porcelain 2>/dev/null)
		local unstaged=""; local staged=""
		if [[ "$git_status" =~ ( M | \?\? | D ) ]];
		then
			unstaged="U"
		fi
		if [[ "$git_status" =~ ^(M |A |D) ]]; then
			staged="+"
		fi
		echo "(${git_branch}${unstaged}${staged})"
	fi
}

# --- Initialize Modern Tools ---

# --- Tmux Auto-Attach Logic ---
if command -v tmux &> /dev/null && [ -z "$TMUX" ];
then
    tmux attach-session -t main || tmux new-session -s main
fi


# --- Bash Git-Aware Prompt (FINAL POSITION) ---

# 1. Function that runs before every prompt displays.
_update_ps1() {
	# PS1 is defined using ASCII codes for color for maximum compatibility.
	PS1="\001\e[0;36m\002[$(service_user)@\h$(_bash_abbreviate_path)]\001\e[0m\002\001\e[0;35m\002$(_bash_custom_git_prompt)\001\e[0m\002> "
}

# 2. PROMPT_COMMAND calls the update function before every new command line.
# This must be the absolute last command in the file to prevent system overrides.
PROMPT_COMMAND=_update_ps1