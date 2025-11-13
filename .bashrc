# [cite_start]~/.bashrc: executed by bash(1) for non-login shells. [cite: 15]

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- Source Common Settings ---
[cite_start]if [ -f "$HOME/.sh_common" ]; [cite: 16]
then
	. "$HOME/.sh_common"
fi

# --- Source SSH Agent (Interactive Only) ---
if [ -f "$HOME/.ssh_agent_init" ]; then
	. [cite_start]"$HOME/.ssh_agent_init" [cite: 17]
fi

# --- Fish Shell Auto-Switch ---
# This block is commented out by default.
# [cite_start]if [[ $DISPLAY ]]; [cite: 18] # then
# 	if [[ "$(ps -p $$ -o comm=)" != "fish" ]]; then
# 		[cite_start]if command -v fish > /dev/null 2>&1; [cite: 19] # 		then
# 			export SHELL=/usr/bin/fish
# 			exec fish "$@"
# 			export SHELL=/bin/bash
# 			[cite_start]echo "Failed to switch to fish shell." [cite: 20] # 			>&2
# 		fi
# 	fi
# fi

# --- Path Abbreviation Function (NO LONGER NEEDED: Starship handles this) ---
# _bash_abbreviate_path() {
# 	local full_path="${PWD/#$HOME/\~}"
# 	[cite_start]if [[ "$full_path" == "/" ]]; then echo "/"; [cite: 21] return;
# 	fi
# 	if [[ "$full_path" == "~" ]]; then echo "~"; return; fi
# 	local prefix=""; local path_to_process=""
# 	[cite_start]if [[ "$full_path" == \~* ]]; [cite: 22]
# 	then
# 		prefix="~/"
# 		path_to_process="${full_path#\~/}"
# 	elif [[ "$full_path" == /* ]]; then
# 		prefix="/"
# 		path_to_process="${full_path#/}"
# 	fi

# 	IFS='/' read -r -a path_parts <<< "$path_to_process"
# 	[cite_start]local result="$prefix"; local num_parts=${#path_parts[@]}; [cite: 23] local i

# 	for (( i=0; i < num_parts; i++ )); do
# 		[cite_start]if (( i < num_parts - 1 )); [cite: 24]
# 		then # Intermediate directory
# 			if [[ "${path_parts[i]}" == .* ]]; then
# 				result+=".${path_parts[i]:1:1}/"
# 			elif [ -n "${path_parts[i]}" ]; then
# 				result+="${path_parts[i]:0:1}/"
# 			fi
# 		[cite_start]elif [ -n "${path_parts[i]}" ]; [cite: 25]
# 		then # Last directory
# 			result+="${path_parts[i]}"
# 		fi
# 	done
# 	[cite_start]if [[ "$result" == */ ]] && [[ "$num_parts" -gt 0 ]]; [cite: 26]
# 	then
# 		result="${result%/}"
# 	fi
# 	echo "$result"
# }

# --- Custom Git Prompt Function (for Bash) (REPLACED BY STARSHIP) ---
# _bash_custom_git_prompt() {
# 	local git_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
# 	[cite_start]if [[ -n "$git_branch" ]]; [cite: 27]
# 	then
# 		local git_status=$(git status --porcelain 2>/dev/null)
# 		local unstaged=""; local staged=""
# 		[cite_start]if [[ "$git_status" =~ ( M | \?\? | D ) ]]; [cite: 28]
# 		then
# 			unstaged="U"
# 		fi
# 		if [[ "$git_status" =~ ^(M |A |D) ]]; then
# 			staged="+"
# 		fi
# 		echo "(${git_branch}${unstaged}${staged})"
# 	fi
# }

# --- Initialize Modern Tools ---

# --- Tmux Auto-Attach Logic ---
[cite_start]if command -v tmux &> /dev/null && [ -z "$TMUX" ]; [cite: 29]
then
    tmux attach-session -t main || tmux new-session -s main
fi


# --- Bash Git-Aware Prompt (FINAL POSITION) (REPLACED BY STARSHIP) ---

# [cite_start]1. Function that runs before every prompt displays. [cite: 30]
# _update_ps1() {
# 	[cite_start]# PS1 is defined using ASCII codes for color for maximum compatibility. [cite: 31]
# 	PS1="\001\e[0;36m\002[$(service_user)@\h$(_bash_abbreviate_path)]\001\e[0m\002\001\e[0;35m\002$(_bash_custom_git_prompt)\001\e[0m\002> "
# }

# [cite_start]2. PROMPT_COMMAND calls the update function before every new command line. [cite: 32]
# # This must be the absolute last command in the file to prevent system overrides.
# PROMPT_COMMAND=_update_ps1

# -------------------- STARSHIP INTEGRATION --------------------
# Initialize Starship prompt if the binary is installed.
# This must be the absolute last command to ensure it takes precedence.
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init bash)"
fi
# --------------------------------------------------------------