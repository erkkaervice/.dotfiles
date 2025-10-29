# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ ! -o interactive ]] && return

# --- Source Common Settings ---
# Source common settings FIRST (might define functions/aliases needed later)
if [[ -f ~/.sh_common ]]; then
	source ~/.sh_common
fi

# --- Fish Shell Auto-Switch ---
# Enter fish for graphical sessions
# (Requires: fish)
if [[ $DISPLAY ]]; then
	# Check if current shell is already fish to avoid loops
	if [[ "$(ps -p $$ -o comm=)" != "fish" ]]; then
		if command -v fish > /dev/null 2>&1; then
			export SHELL=/usr/bin/fish
			exec fish "$@"
			# If exec fails, reset SHELL and print error
			export SHELL=/bin/zsh
			echo "Failed to switch to fish shell." >&2
		fi
	fi
fi

# Initialize Zsh Completion System EARLY
autoload -Uz compinit
compinit -u

# --- Path Abbreviation Function ---
_zsh_abbreviate_path_manual() {
	# Get path relative to home, substituting ~
	local pwd_relative_to_home=${PWD/#$HOME/\~}
	# Handle root and home directories explicitly
	[[ "$pwd_relative_to_home" == "/" ]] && { echo "/"; return }
	[[ "$pwd_relative_to_home" == "~" ]] && { echo "~"; return }

	local prefix=""
	local path_to_process=""
	# Determine prefix (~/ or /) and the rest of the path
	if [[ "$pwd_relative_to_home" == \~* ]]; then
		prefix="~/"
		path_to_process=${pwd_relative_to_home#\~/}
	elif [[ "$pwd_relative_to_home" == /* ]]; then
		prefix="/"
		path_to_process=${pwd_relative_to_home#/}
	else
		echo "$pwd_relative_to_home"; return # Fallback for unexpected paths
	fi

	# Split the path components using Zsh's =(s:/:) syntax
	local -a path_parts
	path_parts=( ${(s:/:)path_to_process} )

	local result="$prefix"
	local num_parts=${#path_parts[@]}
	local i

	# Loop through components (Zsh arrays are 1-based)
	for (( i=1; i <= num_parts; i++ )); do
		if (( i < num_parts )); then # Intermediate directory
			if [[ "${path_parts[i]}" == .* ]]; then
				 # Keep dot, take first char after dot (index 2), add slash
				result+=".${path_parts[i][2]}/"
			 elif [[ -n "${path_parts[i]}" ]]; then
				 # Take first char (index 1), add slash
				result+="${path_parts[i][1]}/"
			fi
		elif [[ -n "${path_parts[i]}" ]]; then # Last directory
			result+="${path_parts[i]}"
		fi
	done

	# Remove potential trailing slash if needed (e.g., if result is just prefix/)
	if [[ "$result" == */ ]] && [[ "$num_parts" -eq 0 && "$prefix" != "/" ]]; then
		result="${result%/}"
	fi

	echo "$result"
}


# --- Zsh Git-Aware Prompt ---

# Initialize Prompt System (includes colors)
autoload -U promptinit
promptinit

# Tell Zsh to expand variables/substitutions in the prompt (required for vcs_info, service_user)
setopt PROMPT_SUBST

# Load version control info
autoload -Uz vcs_info

# Enable Git backend explicitly (Crucial for status to appear)
zstyle ':vcs_info:*' enable git

# Tell vcs_info to check for staged/unstaged changes (Set early)
zstyle ':vcs_info:*' check-for-changes true

# 1. Global reset: Set the default format to empty to ensure the status disappears outside a repo.
zstyle ':vcs_info:*' formats ''
zstyle ':vcs_info:*' actionformats ''

# 2. Define the specific Git format (this overrides the global format when a Git repo is found)
# %b = branch, %u = unstaged (default 'U'), %c = staged (default '+')
zstyle ':vcs_info:git:*' formats '%F{magenta}(%b%u%c)%f'
zstyle ':vcs_info:git:*' actionformats '%F{magenta}(%b|%a%u%c)%f'

# Execute vcs_info and build the prompt *before* each prompt render
precmd() {
	# Run vcs_info to populate the status variable
	vcs_info
	
	# Get the abbreviated path using the manual function
	local abbreviated_wd=$(_zsh_abbreviate_path_manual)
	
	# Build the main prompt part with the abbreviated path (NO space after %m)
	local main_prompt="%F{cyan}[$(service_user)@%m${abbreviated_wd}]%f"
	
	# Combine main prompt and Git status into the final PROMPT variable
	PROMPT="${main_prompt}${vcs_info_msg_0_}> "
}

# Set an initial basic prompt (will be overridden by precmd)
PROMPT="> "

# --- Initialize Modern Tools ---

# Initialize zoxide (smarter cd)
if command -v zoxide > /dev/null 2>&1; then
	eval "$(zoxide init zsh)"
fi

# Initialize fzf (fuzzy finder keybindings)
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

# --- Zsh History Settings ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# --- Keybindings ---
# Keybindings (Example: Use emacs mode)
bindkey -e

# --- Global Definitions (Optional) ---
# Source global Zsh config if it exists
#if [[ -f /etc/zshrc ]]; then
#  source /etc/zshrc
#fi
