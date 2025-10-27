# ~/.config/fish/config.fish - Fish shell configuration

# --- Basic Checks ---
# Only run in interactive shells
if not status is-interactive
	exit
end

# --- Environment Variables (Global, Exported) ---
# Set preferred programs
set -gx EDITOR nvim
set -gx NAVIGATOR brave
set -gx TERM kitty # Ensure kitty terminfo is installed

# --- PATH Modifications ---
# Fish automatically includes ~/.local/bin if it exists
# Add Cargo bin path if it exists
if test -d "$HOME/.cargo/bin"
	fish_add_path "$HOME/.cargo/bin"
end
# Add Flatpak path if it exists
if test -d "/var/lib/flatpak/exports/bin"
	fish_add_path "/var/lib/flatpak/exports/bin"
end

# --- Aliases ---
# Color settings
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'

# Disk usage
alias df='df -h'
alias free='free -m'

# Processes
alias psa="ps auxf"
# Note: Fish doesn't support Bash's -E for psgrep, adjust grep pattern if needed
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Git aliases
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
# User-specific dotfiles alias
# alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# --- Functions ---

# Compiler function
# (Requires: build-essential/base-devel)
function compile --description 'Compile and run a C/C++ file'
	# Check for argument
	if test -z "$argv[1]"
		echo "Missing operand" >&2
		return 1
	end

	# Check if file exists and is readable
	if not test -r "$argv[1]"
		printf "File %s does not exist or is not readable\n" "$argv[1]" >&2
		return 1
	end

	# Get filename without path for output
	set -l filename (basename "$argv[1]")
	set -l output_path "/tmp/$filename.out" # Use simple output name

	# Compile using gcc (can switch to g++ if needed)
	if gcc "$argv[1]" -Wall -Wextra -Werror -o "$output_path"
		# Execute if compilation succeeded
		"$output_path"
		set -l status $status # Save exit status of the program
	else
		# Report compilation failure
		echo "Compilation failed" >&2
		set -l status 1 # Set failure status
	end

	# Clean up executable
	rm -f "$output_path"

	return $status
end

# Extract function (Adapted for Fish syntax)
# (Requires relevant extractors)
function extract --description 'Extract various archive types'
	# Check for arguments
	if test -z "$argv"
		return 0 # No files given, nothing to do
	end

	set -l status 0 # Overall status

	for i in $argv
		set -l cmd
		if not test -r "$i"
			echo "extract: file is unreadable: '$i'" >&2
			set status 1 # Mark failure
			continue
		end

		# Use string match for extensions
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
				set status 1 # Mark failure
				continue
		end

		# Execute the command
		if set -q cmd[1] # Check if cmd was set
			command $cmd "$i"
			if test $status -ne 0
				set status 1 # Mark failure if command failed
			end
		end
	end
	return $status
end
alias extract='extract' # Create alias for the function

# IP information function (Adapted for Fish syntax)
# (Requires: curl, host [dnsutils/bind])
function ipinformation --description 'Get IP info using ipinfo.io'
	# Check if $1 looks like an IP address (simplified regex)
	if string match -qr '^([0-9]{1,3}\.){3}[0-9]{1,3}$' -- "$argv[1]"
		curl "ipinfo.io/$argv[1]"
	# Check if $1 looks like a domain name (simplified regex)
	else if string match -qr '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' -- "$argv[1]"
		set -l ip_address (host "$argv[1]" | command grep 'has address' | awk '{print $NF; exit}')
		if test -n "$ip_address"
			curl "ipinfo.io/$ip_address"
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
alias ipinfo='ipinformation' # Create alias for the function


# --- Fish Specific Settings (Optional) ---
# Example: Use vi keybindings
# fish_vi_key_bindings

# Example: Source Oh My Fish or Fisher plugins if installed
# if status is-interactive
#    source ~/.local/share/omf/init.fish
# end

# Example: Set custom prompt function
# function fish_prompt
#    # Your custom prompt logic here
#    printf '[%s@%s %s]%s ' (whoami) (hostname|cut -d . -f 1) (prompt_pwd) (fish_is_root_user && echo '#' || echo '$')
# end

echo "Fish config loaded." # Optional: Confirmation message
