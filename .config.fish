# ~/.config.fish/config.fish - Fish shell configuration

if not status is-interactive; end

# --- Auto-Refresh (Once per session) ---
set -l marker_file "$HOME/.dotfiles_initialized_"(id -u)
if not test -f "$marker_file"
	if not command -v zoxide >/dev/null 2>&1
		echo "[Auto-Setup] Essential tools missing. Running setup..."
		# [FIXED] Corrected path from .config.fish to .config/fish
		set -l C_PATH "$HOME/.config/fish/config.fish"; set -l D_DIR (dirname (readlink -f $C_PATH 2>/dev/null)); set -l S_SCRIPT "$D_DIR/.setup.sh"
		if test -f "$S_SCRIPT"; bash "$S_SCRIPT"; else; bash "$HOME/.dotfiles/.setup.sh"; end
	end
	touch "$marker_file"
end

# --- Environment Variables (Global, Exported) ---
set -gx TERMINAL kitty; set -gx EDITOR nvim; set -gx NAVIGATOR brave
set -gx USER ervice; set -gx MAIL erkka@ervice.fi

# --- Disable Fish Greeting ---
function fish_greeting; end

# --- PATH Modifications (Secure Append) ---
if test -d "$HOME/.local/bin"; fish_add_path --append "$HOME/.local/bin"; end
if test -d "$HOME/.cargo/bin"; fish_add_path --append "$HOME/.cargo/bin"; end
if test -d "/var/lib/flatpak/exports/bin"; fish_add_path --append "/var/lib/flatpak/exports/bin"; end

# --- Command Color Settings ---
alias ls='ls --color=auto'; alias grep='grep --color=auto'; alias ip='ip -color=auto'
alias rm='rm -I'

# --- Disk Usage ---
alias df='df -h'; alias free='free -m'

# --- Processes ---
alias psa="ps auxf"; alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'; alias pscpu='ps auxf | sort -nr -k 3'

# --- Git Aliases ---
# All Git aliases have been moved to ~/.gitconfig
# to be universally available in shells, TUIs, and GUIs.

# --- Modern Tool Aliases ---
if command -v bat > /dev/null
	alias cat='bat --paging=never'
else if command -v batcat > /dev/null; alias cat='batcat --paging=never'; end
if command -v fd > /dev/null; alias find='fd'; end
if command -v rg > /dev/null; alias grep='rg'; end
alias code='flatpak run com.visualstudio.code'
# Fallback alias for neovim (uses Flatpak if nvim is not in PATH)
if not command -v nvim > /dev/null; and command -v flatpak > /dev/null
	alias nvim='flatpak run io.neovim.nvim'
end

# --- Functions ---
function fish_prompt
	# FIXED: Hardcode username to "ervice" to prevent sourcing .sh_common
	set -l user_name "ervice"
	set -l c_cyan (set_color cyan); set -l c_magenta (set_color magenta); set -l c_norm (set_color normal)
	echo -n $c_cyan"["$user_name"@"(prompt_hostname)(prompt_pwd)"]"$c_norm
	set -l g_branch (git symbolic-ref --short HEAD 2> /dev/null)
	if test -n "$g_branch"
		set -l g_status (git status --porcelain 2> /dev/null); set -l u ""; set -l s ""
		if string match -q -- "* M *" $g_status; or string match -q -- "*??*" $g_status; or string match -q -- "* D *" $g_status; set u "U"; end
		if string match -q -- "M *" $g_status; or string match -q -- "A *" $g_status; or string match -q -- "D *" $g_status; set s "+"; end
		echo -n $c_magenta(string trim -- "("$g_branch$u$s")")$c_norm
	end
	if fish_is_root_user; echo -n "# "; else; echo -n "> "; end
end

function compile; if test -z "$argv[1]"; return 1; end; set -l f (basename "$argv[1]"); set -l o "/tmp/$f.out"; if gcc "$argv[1]" -Wall -Wextra -Werror -o "$o"; "$o"; else; return 1; end; rm -f "$o"; end
function extract; for i in $argv; switch "$i"; case '*.tar.bz2' '*.tar.gz' '*.tar.xz' '*.tbz2' '*.tgz' '*.txz' '*.tar'; bsdtar xvf "$i"; case '*.zip'; unzip "$i"; case '*.rar'; unrar x "$i"; case '*.7z'; 7z x "$i"; case '*.gz'; gunzip "$i"; case '*.xz'; unxz "$i"; case '*.zst'; unzstd "$i"; end; end; end
alias ipinfo='ipinformation'
function ipinformation; if test -z "$argv[1]"; curl ipinfo.io | grep -v '"readme":'; else; curl "ipinfo.io/$argv[1]" | grep -v '"readme":'; end; echo; end

function cleanup
	echo "--- Disk Usage Cleanup (User Directories) ---"
	du -sh ~/.cache ~/.local/share/Trash ~/.thumbnails 2>/dev/null
	du -sh ~/.cache.backup ~/.local.backup ~/.config.backup 2>/dev/null
	set -l do_clean false; set -l deep_clean false

	if contains -- -y $argv; set do_clean true; end
	if contains -- --deep $argv; set deep_clean true; end

	if not $do_clean; read -l -P "Clear user cache, thumbnails, trash, and backups? [y/N] " confirm; if string match -ri "^(y|yes)\$" -- $confirm; set do_clean true; end; end
	if test "$do_clean" = true
		echo "Clearing user directories (cache, trash, backups)..."
		rm -rf ~/.local/share/Trash ~/.thumbnails
		rm -rf ~/.cache; mkdir -p ~/.cache
		rm -rf ~/.cache.backup ~/.local.backup ~/.config.backup

		if command -v flatpak > /dev/null
			echo "Cleaning Flatpak (unused user runtimes)..."
			flatpak uninstall --user --unused -y
			if test -d "$HOME/.var/app/com.visualstudio.code/cache"; echo "Cleaning VS Code (Flatpak) cache..."; rm -rf "$HOME/.var/app/com.visualstudio.code/cache"; end
		end
		
		if command -v docker > /dev/null; echo "Cleaning Docker (pruning system)..."; docker system prune -f; end
		
		if command -v dotnet > /dev/null; echo "Cleaning .NET (clearing nuget caches)..."; dotnet nuget locals all --clear; end

		if command -v sudo >/dev/null 2>&1; and sudo -n true 2>/dev/null
			echo "--- System-Wide Cleanup (Sudo) ---"
			if command -v apt-get >/dev/null; echo "Cleaning Debian/Ubuntu/Kali package cache..."; sudo apt-get autoremove -y; and sudo apt-get clean; end
			if command -v pacman >/dev/null
				if test "$deep_clean" = true; echo "Cleaning Arch/SteamOS package cache (DEEP: -Scc)..."; sudo pacman -Scc; else; echo "Cleaning Arch/SteamOS package cache (Standard: -Sc)..."; echo -e "y\n" | sudo pacman -Sc; end
			end
			if command -v zypper >/dev/null; echo "Cleaning OpenSUSE package cache..."; sudo zypper clean --all; end
			if command -v brew >/dev/null; echo "Cleaning macOS/Homebrew cache..."; brew cleanup -s; end
			if command -v apk >/dev/null; echo "Cleaning Alpine package cache..."; sudo apk cache clean; end
			if command -v journalctl >/dev/null; echo "Cleaning system logs (journald, limit to 2GB)..."; sudo journalctl --vacuum-size=2G; end
			if test -d "/tmp"; echo "Cleaning global /tmp (files older than 7 days)..."; sudo find /tmp -type f -atime +7 -delete 2>/dev/null; end
			if test -d "/var/tmp"; echo "Cleaning global /var/tmp (files older than 7 days)..."; sudo find /var/tmp -type f -atime +7 -delete 2>/dev/null; end
		end
		echo "Cleanup finished."
	else
		echo "Skipping cleanup."
	end
end

# --- Security Aliases & Functions ---
function networkscan; nmap -T4 -F $argv; end
if command -v sudo > /dev/null; and sudo -n true 2>/dev/null; alias audit='sudo lynis audit system'; else; alias audit='lynis audit system'; end

# --- Load Local Secrets (Ignored by Git) ---
if test -f "$HOME/.config/shell_secrets"; source "$HOME/.config/shell_secrets"; end

# --- Init Integrations ---
# Tmux Auto-Attach Logic
if command -v tmux > /dev/null; and not set -q TMUX
	tmux attach-session -t main; or tmux new-session -s main
end

# --- [FIXED] Fish SSH Agent (Native Implementation) ---
# This block provides the same logic as .ssh_agent_init for Bash/Zsh
set -l SSH_ENV_FISH "$HOME/.ssh/agent-info-"(hostname)".fish"

# Function to start a new agent and create both Fish and POSIX files
function __start_agent_fish
	echo "Initializing new SSH agent (Fish)..."
	set -l SSH_ENV_POSIX "$HOME/.ssh/agent-info-"(hostname)".posix"
	
	# Create Fish (csh-style) agent file (for Termux)
	ssh-agent -c | sed 's/^echo/#echo/' > "$SSH_ENV_FISH"
	# Create POSIX (sh/bash/zsh) agent file
	ssh-agent -s | sed 's/^echo/#echo/' > "$SSH_ENV_POSIX"
	
	chmod 600 "$SSH_ENV_FISH"
	chmod 600 "$SSH_ENV_POSIX"
	
	# Source the new Fish file
	source "$SSH_ENV_FISH"
	ssh-add
end

# Main agent check logic for Fish
if test -f "$SSH_ENV_FISH"
	source "$SSH_ENV_FISH"
	# [THE REAL FIX] Use 'kill -0' which is reliable, instead of 'ps | grep'
	if not kill -0 $SSH_AGENT_PID > /dev/null 2>&1
		# Agent died, start a new one.
		__start_agent_fish
	end
else
	# Environment file doesn't exist yet, start agent for the first time.
	__start_agent_fish
end
# --- [END FIX] ---


if command -v zoxide > /dev/null; zoxide init fish | source; end
if command -v fzf > /dev/ null;
	fzf --fish | source; end
if command -v direnv > /dev/null;
	direnv hook fish | source; end

# --- Start Fresh Function ---
function startfresh
	# [FIXED] Corrected path from .config.fish to .config/fish
	set -l REPO_ROOT (dirname (readlink -f "$HOME/.config/fish/config.fish" 2>/dev/null))
	# Fallback if readlink fails
	if test -z "$REPO_ROOT"; or test "$REPO_ROOT" = "."
		set REPO_ROOT "$HOME/.dotfiles"
	end

	echo "--- WARNING: Starting Fresh (Removing all custom dotfile links) ---"
	echo "1. Removing config links..."
	rm -f ~/.sh_common ~/.profile ~/.bashrc ~/.zshrc ~/.bash_logout
	rm -f "$HOME/.ssh_agent_init"
	rm -rf ~/.config.fish
	rm -rf ~/.config/kitty
	rm -rf ~/.config/fontconfig
	rm -f "$HOME/.config/shell_secrets"

	echo "2. Removing local user applications..."
	rm -rf ~/.local/kitty.app
	rm -rf ~/.fzf
	rm -rf ~/.local/share/applications/kitty.desktop

	rm -f "$HOME/.dotfiles_initialized_"(id -u)

	echo "3. Creating temporary recovery files to prevent Zsh wizard..."
	set -l REPO_SCRIPT_FILE (mktemp)
	echo '
	RECOVERY_SCRIPT="
	# --- TEMPORARY RECOVERY SCRIPT ---
	echo ''---------------------------------------------------''
	echo ''RUN: refresh (to rebuild your custom setup)''
	echo ''---------------------------------------------------''

	refresh() {
		echo ''--- REFRESHING ENVIRONMENT ---''
		bash \"'$REPO_ROOT/.setup.sh'\" || return 1
		echo ''--- Environment restored. Please restart your terminal. ---''
		exec \$SHELL --login
	}
	"
	echo "$RECOVERY_SCRIPT" > "$HOME/.bashrc"
	echo "$RECOVERY_SCRIPT" > "$HOME/.zshrc"
	' > $REPO_SCRIPT_FILE
	bash $REPO_SCRIPT_FILE
	rm $REPO_SCRIPT_FILE

	echo "--- ENVIRONMENT RESET. Starting fresh session. ---"
	# FIXED: Exec into Bash, which is Termux's default POSIX shell
	set -l BASH_PATH /bin/bash
	if test -f /data/data/com.termux/files/usr/bin/bash
		set BASH_PATH /data/data/com.termux/files/usr/bin/bash
	end
	exec $B_PATH --login
end

# --- Dotfiles Management Function ---
function refresh
	# --- [FIXED] Robust path detection for Termux ---
	set -l REPO_ROOT ""
	set -l SETUP_SCRIPT ""

	# Try to find the repo root using readlink
	# [FIXED] Corrected path from .config.fish to .config/fish
	set -l C_PATH "$HOME/.config/fish/config.fish"
	if command -v readlink > /dev/null
		set -l D_DIR (dirname (readlink -f $C_PATH 2>/dev/null))
		if test -n "$D_DIR"; and test "$D_DIR" != "/"; and test -f "$D_DIR/.setup.sh"
			set REPO_ROOT "$D_DIR"
			set SETUP_SCRIPT "$D_DIR/.setup.sh"
		end
	end

	# Fallback: If readlink fails or script not found, use default path
	if test -z "$SETUP_SCRIPT"
		set REPO_ROOT "$HOME/.dotfiles"
		set SETUP_SCRIPT "$HOME/.dotfiles/.setup.sh"
	end
	# --- [END FIX] ---

	echo "--- Refreshing Dotfiles (from $REPO_ROOT) ---"
	
	# [FIXED] Ensured Git Pull logic runs reliably and displays output.
	if type -q git; and test -d "$REPO_ROOT/.git"
		pushd "$REPO_ROOT"
		echo "Pulling updates from Git..."
		git pull origin main
		popd
	else if not type -q git
		echo "[WARN] Git command not found. Skipping repository update."
	end
	
	# Run setup script
	if test -f "$SETUP_SCRIPT"
		bash "$SETUP_SCRIPT"
	else
		echo "[Refresh] Error: Could not find .setup.sh at $SETUP_SCRIPT" >&2
		return 1
	end
	
	# Reload fish config
	# [FIXED] Removed the recursive source command to prevent looping.
	echo "--- Environment updated. Please restart your shell. ---"
	
	echo "--- Dotfiles Refreshed ---"
end

# --- Auto-configure Git GPG Signing ---
if command -v git > /dev/null; and test -n "$GPG_SIGNING_KEY"
	git config --global user.signingkey "$GPG_SIGNING_KEY"
	git config --global commit.gpgsign true
	git config --global tag.gpgSign true
	echo "[INFO] Git GGPG signing configured."
end