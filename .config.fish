# ~/.config.fish/config.fish - Fish shell configuration

# --- Basic Checks ---
if not status is-interactive
	exit
end

# --- Environment Variables (Global, Exported) ---
set -gx TERMINAL kitty
set -gx EDITOR nvim
set -gx NAVIGATOR brave
set -gx USER ervice
set -gx MAIL erkka@ervice.fi
# TERM is usually best left for the terminal emulator to set

# --- Disable Fish Greeting ---
function fish_greeting
	# Intentionally empty to suppress the welcome message
end

# --- PATH Modifications ---
# Fish automatically includes ~/.local.bin if it exists
if test -d "$HOME/.cargo/bin"
	fish_add_path "$HOME/.cargo/bin"
end
if test -d "/var/lib/flatpak/exports/bin"
	fish_add_path "/var/lib/flatpak/exports/bin"
end

# --- Fish Git Prompt Configuration ---
# Note: We manually add indicators below, so these are less critical now
# set -g fish_git_prompt_char_dirtystate '*'
# set -g fish_git_prompt_char_stagedstate '+'

# --- Aliases ---

# --- Command Color Settings ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'

# --- Disk Usage ---
alias df='df -h'
alias free='free -m'

# --- Processes ---
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# --- Git Aliases ---
# (Requires: git)
alias addup='git add -u'
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias stat='git status'
alias tag='git tag'
alias newtag='git tag -a'
alias gl='git log --oneline --graph --decorate --all'

# User-specific dotfiles alias
# alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Alias for VS Code Flatpak
# (Requires: flatpak run com.visualstudio.code)
alias code='flatpak run com.visualstudio.code'

# --- Modern Tool Aliases ---
# (Requires: bat, fd-find, ripgrep)

# Use bat as a cat replacement
if command -v bat > /dev/null
	alias cat='bat --paging=never'
# Handle Ubuntu's batcat naming
else if command -v batcat > /dev/null
	alias cat='batcat --paging=never'
end

# Use fd as a find replacement
if command -v fd > /dev/null
	alias find='fd'
end

# Use ripgrep as a grep replacement
if command -v rg > /dev/null
	alias grep='rg'
end

# --- Functions ---

# --- Custom Prompt Function ---
# Overrides default Fish prompt to match Bash/Zsh (Cyan/Magenta)
function fish_prompt
	# Use the 'service_user' function from .sh_common for the username
	set -l user_name ""
	if test -f "$HOME/.sh_common"
		set user_name (bash -c 'source ~/.sh_common && service_user')
	else
		set user_name (whoami) # Fallback if .sh_common isn't found
	end

	# Define colors using Fish's set_color
	set -l color_cyan (set_color cyan)
	set -l color_magenta (set_color magenta)
	set -l color_normal (set_color normal)

	# --- CORRECTED SPACING LOGIC ---
	# 1. Main prompt part: [user@hostdir] in Cyan - NO trailing space
	echo -n $color_cyan"["$user_name"@"
	echo -n (prompt_hostname)
	echo -n (prompt_pwd)
	echo -n "]"$color_normal

	# 2. Git status part: (branchU+) in Magenta - NO leading space
	set -l git_branch (git symbolic-ref --short HEAD 2> /dev/null)
	if test -n "$git_branch" # Check if we are inside a git repo
		set -l git_status (git status --porcelain 2> /dev/null)
		set -l unstaged ""
		set -l staged ""

		# Use 'U' for unstaged to match Zsh default
		if string match -q -- "* M *" $git_status; or string match -q -- "*??*" $git_status; or string match -q -- "* D *" $git_status
			set unstaged "U"
		end
		if string match -q -- "M *" $git_status; or string match -q -- "A *" $git_status; or string match -q -- "D *" $git_status
			set staged "+"
		end
		set -l vcs_indicator "("$git_branch$unstaged$staged")"
		# Print *only* the colored status
		echo -n $color_magenta(string trim -- $vcs_indicator)$color_normal
	end

	# 3. Prompt ending character - Add the SINGLE separator space HERE
	if fish_is_root_user
		echo -n "#" # Space before #
	else
		echo -n ">" # Space before >
	end
	# Add the final space *after* the prompt character for typing
	echo -n " "
end


# Compiler function
# (Requires: build-essential/base-devel)
function compile --description 'Compile and run a C/C++ file'
	if test -z "$argv[1]"
		echo "Missing operand" >&2
		return 1
	end
	if not test -r "$argv[1]"
		printf "File %s does not exist or is not readable\n" "$argv[1]" >&2
		return 1
	end
	set -l filename (basename "$argv[1]")
	set -l output_path "/tmp/$filename.out"
	if gcc "$argv[1]" -Wall -Wextra -Werror -o "$output_path"
		"$output_path"
		set -l status $status
	else
		echo "Compilation failed" >&2
		set -l status 1
	end
	rm -f "$output_path"
	return $status
end

# Extract function (Adapted for Fish syntax)
# (Requires relevant extractors)
function extract --description 'Extract various archive types'
	if test -z "$argv"
		return 0
	end
	set -l status 0
	for i in $argv
		set -l cmd
		if not test -r "$i"
			echo "extract: file is unreadable: '$i'" >&2
			set status 1
			continue
		end
		switch "$i"
			case '*.tar.bz2' '*.tar.gz' '*.tar.lz' '*.tar.xz' '*.tbz2' '*.tgz' '*.tlz' '*.txz' '*.tar'
				set cmd bsdtar xvf
			case '*.7z'
				set cmd 7z x
			case '*.Z'
				set cmd uncompress
			case '*.bz2'
				set cmd bunzip2
			case '*.exe'
				set cmd cabextract
			case '*.gz'
				set cmd gunzip
			case '*.rar'
				set cmd unrar x
			case '*.xz'
				set cmd unxz
			case '*.zip'
				set cmd unzip
			case '*.zst'
				set cmd unzstd
			case '*'
				echo "extract: unrecognized file extension: '$i'" >&2
				set status 1
				continue
		end
		if set -q cmd[1]
			command $cmd "$i"
			if test $status -ne 0
				set status 1
			end
		end
	end
	return $status
end
alias extract='extract'

# IP information function (Adapted for Fish syntax)
# (Requires: curl, host [dnsutils/bind])
function ipinformation --description 'Get IP info using ipinfo.io'
	# If no argument is given, show own IP info
	if test -z "$argv[1]"
		curl ipinfo.io | grep -v '"readme":'
	else if string match -qr '^([0-9]{1,3}\.){3}[0-9]{1,3}$' -- "$argv[1]"
		curl "ipinfo.io/$argv[1]" | grep -v '"readme":'
	else if string match -qr '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' -- "$argv[1]"
		set -l ip_address (host "$argv[1]" | command grep 'has address' | awk '{print $NF; exit}')
		if test -n "$ip_address"
			curl "ipinfo.io/$ip_address" | grep -v '"readme":'
		else
			echo "Could not resolve IP for $argv[1]" >&2
			return 1
		end
	else
		echo "Input does not look like an IP address or domain name: $argv[1]" >&2
		return 1
	end
	echo
end
alias ipinfo='ipinformation'

# --- SSH Agent Management ---
# Source the agent manager script (needed for Termux/non-graphical sessions)
if test -f "$HOME/.ssh_agent_init"
	source "$HOME/.ssh_agent_init"
end

# --- Initialize Modern Tools ---

# Initialize zoxide (smarter cd)
if command -v zoxide > /dev/null
	zoxide init fish | source
end

# Initialize fzf (fuzzy finder keybindings)
if command -v fzf > /dev/null
	fzf --fish | source
end

# --- Dotfiles Management Function ---
# Alias: refresh
# Pulls latest changes, runs setup.sh to re-link, and sources the Fish config.
function dotfiles_refresh --description 'Pull, re-link, and source dotfiles config'
	# Use readlink -f on the symlinked config file to reliably find the actual repository directory.
	set -l CONFIG_PATH ~/.config/fish/config.fish
	set -l DOTFILES_DIR (dirname (readlink -f $CONFIG_PATH))

	echo "--- Refreshing Dotfiles ---"

	# 1. Pull the latest repository changes
	if type -q git
		echo "1. Pulling latest changes..."
		# Check if the directory is a git repository
		if test -d "$DOTFILES_DIR/.git"
			begin
				cd "$DOTFILES_DIR"
				git pull origin main
			end
			if test $status -ne 0
				echo "Git pull failed." >&2
				return 1
			end
		else
			echo "Warning: Dotfiles directory is not a Git repository. Skipping pull."
		end
	else
		echo "Warning: Git not found. Skipping pull."
	end

	# 2. Re-run the setup script to ensure correct links and install new tools
	echo "2. Running setup script..."
	# Execute the bash script from the correctly resolved DOTFILES_DIR
	bash "$DOTFILES_DIR/.setup.sh"
	if test $status -ne 0
		echo "Setup script failed." >&2
		return 1
	end

	# 3. Source the Fish config to apply changes immediately
	echo "3. Sourcing Fish config..."
	source (status --current-filename)

	echo "--- Dotfiles Refreshed ---"
end
alias refresh 'dotfiles_refresh'
