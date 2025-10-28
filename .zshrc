# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ ! -o interactive ]] && return

# --- Source Common Settings ---
if [[ -f ~/.sh_common ]]; then
	source ~/.sh_common
fi

# Initialize Zsh Completion System EARLY
autoload -Uz compinit
compinit -u

# --- Zsh Git-Aware Prompt ---

# FIX: Force the displayed username to 'ervice' on all machines (for zsh/termux)
# This overrides the default UID (u0_a...) in non-standard environments.
export USER="ervice"

# Initialize Prompt System (includes colors)
autoload -U promptinit
promptinit

# Tell Zsh to expand variables/substitutions in the prompt
setopt PROMPT_SUBST

# Load version control info
autoload -Uz vcs_info
precmd() { vcs_info }

# Set a format for the vcs_info
# %b = branch, %u = unstaged, %c = staged
# This will show like (main *+): * for unstaged, + for staged
zstyle ':vcs_info:git:*' formats ' \e[0;35m(%b%u%c)\e[0m'
zstyle ':vcs_info:git:*' actionformats ' \e[0;35m(%b|%a%u%c)\e[0m'
zstyle ':vcs_info:git:*' unstagedchars '*'
zstyle ':vcs_info:git:*' stagedchars '+'

# Set the prompt
# Cyan for main, plus git info from vcs_info
# Use service_user function for the fixed username
PROMPT=$'\e[0;36m[$(service_user)@%m %1~]\e[0m${vcs_info_msg_0_}%# '

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
