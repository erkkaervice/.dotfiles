# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ ! -o interactive ]] && return

# Source common settings
if [[ -f ~/.sh_common ]]; then
	source ~/.sh_common
fi

# Zsh prompt configuration (Example - customize or use a framework like Oh My Zsh)
autoload -U colors && colors
PROMPT='%{$fg[cyan]%}[%n@%m %1~]%{$reset_color%}%# '

# Zsh specific options
setopt EXTENDED_GLOB        # Equivalent to shopt -s extglob
setopt HIST_IGNORE_DUPS     # Don't store duplicate commands
setopt HIST_IGNORE_SPACE    # Don't store commands starting with space
setopt APPEND_HISTORY       # Append history, don't overwrite
setopt SHARE_HISTORY        # Share history between terminals immediately
setopt INC_APPEND_HISTORY   # Add commands immediately, don't wait for shell exit
setopt CORRECT              # Auto-correct commands
setopt COMPLETE_IN_WORD     # Allow completion from within words
# setopt NO_BEEP            # Uncomment to disable terminal beep

# Zsh history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Keybindings (Example: Use emacs mode)
bindkey -e

# Zsh completion system
# Consider installing 'zsh-completions' package
autoload -Uz compinit
compinit -u # Use insecure directories if needed, consider 'compinit -i' first

# Source global Zsh config if it exists
#if [[ -f /etc/zshrc ]]; then
#  source /etc/zshrc
#fi

# User specific Zsh config directory (Zsh convention)
#ZDOTDIR=${ZDOTDIR:-$HOME}
#if [[ -d $ZDOTDIR/.zshrc.d ]]; then
#  for rc_file in $ZDOTDIR/.zshrc.d/*; do
#    if [[ -f $rc_file ]]; then
#      source $rc_file
#    fi
#  done
#  unset rc_file
#fi
