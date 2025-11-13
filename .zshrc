# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ ! -o interactive ]] && return

# --- Source Common Settings ---
if [[ -f ~/.sh_common ]];
then
	source ~/.sh_common
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
# 			export SHELL=/bin/zsh
# 			echo "Failed to switch to fish shell." >&2
# 		fi
# 	fi
# fi

# Initialize Zsh Completion System
autoload -Uz compinit
compinit -u

# --- Path Abbreviation Function (REPLACED BY STARSHIP) ---
# _zsh_abbreviate_path_manual() {
# ... (removed function body) ...
# }


# --- Zsh Git-Aware Prompt (REPLACED BY STARSHIP) ---
# autoload -U promptinit
# promptinit
# setopt PROMPT_SUBST
# autoload -Uz vcs_info
# zstyle ':vcs_info:*' enable git
# zstyle ':vcs_info:*' check-for-changes true
# zstyle ':vcs_info:git:*' formats '%F{magenta}(%b%u%c)%f'
# zstyle ':vcs_info:git:*' actionformats '%F{magenta}(%b|%a%u%c)%f'

# precmd() {
# 	vcs_info
# 	local abbreviated_wd=$(_zsh_abbreviate_path_manual)
# 	PROMPT="%F{cyan}[$(service_user)@%m${abbreviated_wd}]%f${vcs_info_msg_0_}> "
# }

# --- Tmux Auto-Attach Logic ---
if command -v tmux &> /dev/null && [ -z "$TMUX" ];
then
    tmux attach-session -t main || tmux new-session -s main
fi

# -------------------- STARSHIP INTEGRATION --------------------
# Initialize Starship prompt if the binary is installed.
# This must be the absolute last command to ensure it takes precedence.
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init zsh)"
fi
# --------------------------------------------------------------