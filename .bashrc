# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
# Corrected to universal POSIX syntax to prevent 'if: command not found' errors.
case "$-" in
    *i*) ;;
      *) return;;
esac

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
# 			echo "Failed to switch to fish shell." >&2
# 		fi
# 	fi
# fi

# --- Path Abbreviation Function (REPLACED BY STARSHIP) ---
# _bash_abbreviate_path() {
# ... (removed function body) ...
# }

# --- Custom Git Prompt Function (for Bash) (REPLACED BY STARSHIP) ---
# _bash_custom_git_prompt() {
# ... (removed function body) ...
# }

# --- Initialize Modern Tools ---

# --- Tmux Auto-Attach Logic ---
if command -v tmux &> /dev/null && [ -z "$TMUX" ];
then
    tmux attach-session -t main || tmux new-session -s main
fi


# --- Bash Git-Aware Prompt (FINAL POSITION) (REPLACED BY STARSHIP) ---

# 1. Function that runs before every prompt displays.
# _update_ps1() {
# 	# PS1 is defined using ASCII codes for color for maximum compatibility.
# 	PS1="\001\e[0;36m\002[$(service_user)@\h$(_bash_abbreviate_path)]\001\e[0m\002\001\e[0;35m\002$(_bash_custom_git_prompt)\001\e[0m\002> "
# }

# 2. PROMPT_COMMAND calls the update function before every new command line.
# # This must be the absolute last command in the file to prevent system overrides.
# PROMPT_COMMAND=_update_ps1

# -------------------- STARSHIP INTEGRATION --------------------
# Initialize Starship prompt if the binary is installed.
# This must be the absolute last command to ensure it takes precedence.
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init bash)"
fi
# --------------------------------------------------------------