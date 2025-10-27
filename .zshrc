# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ ! -o interactive ]] && return

# Source common settings FIRST (might define functions/aliases needed later)
if [[ -f ~/.sh_common ]]; then
	source ~/.sh_common
fi

# Initialize Zsh Completion System EARLY
autoload -Uz compinit
compinit -u

# Initialize Prompt System (includes colors) - Keep for other prompt features
autoload -U promptinit
promptinit

# Zsh prompt configuration using ANSI escape codes
# \e[0;36m sets color to cyan
# \e[0m resets color
PROMPT=$'\e[0;36m[%n@%m %1~]\e[0m%# '

# Zsh specific options
setopt EXTENDED_GLOB
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt CORRECT
setopt COMPLETE_IN_WORD
# setopt NO_BEEP

# Zsh history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Keybindings (Example: Use emacs mode)
bindkey -e

# Source global Zsh config if it exists
#if [[ -f /etc/zshrc ]]; then
#  source /etc/zshrc
#fi
