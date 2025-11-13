# [cite_start]~/.config.fish/config.fish - Fish shell configuration [cite: 33]

if not status is-interactive; end

# --- Auto-Refresh (Once per session) ---
set -l marker_file "$HOME/.dotfiles_initialized_"(id -u)
if not test -f "$marker_file"
	if not command -v zoxide >/dev/null 2>&1
		echo "[Auto-Setup] Essential tools missing. Running setup..."
		# [FIXED] Corrected path from .config.fish to .config/fish
		[cite_start]set -l C_PATH "$HOME/.config/fish/config.fish"; [cite: 34] set -l D_DIR (dirname (readlink -f $C_PATH 2>/dev/null)); set -l S_SCRIPT "$D_DIR/.setup.sh"
		[cite_start]if test -f "$S_SCRIPT"; bash "$S_SCRIPT"; else; bash "$HOME/.dotfiles/.setup.sh"; [cite: 35] end
	end
	touch "$marker_file"
end

# --- Environment Variables (Global, Exported) ---
[cite_start]set -gx TERMINAL kitty; set -gx EDITOR nvim; [cite: 36] set -gx NAVIGATOR brave
set -gx USER ervice; set -gx MAIL erkka@ervice.fi

# --- Disable Fish Greeting ---
[cite_start]function fish_greeting; [cite: 37] end

# --- PATH Modifications (Secure Append) ---
if test -d "$HOME/.local/bin"; fish_add_path --append "$HOME/.local/bin"; end
[cite_start]if test -d "$HOME/.cargo/bin"; fish_add_path --append "$HOME/.cargo/bin"; [cite: 38] end
if test -d "/var/lib/flatpak/exports/bin"; fish_add_path --append "/var/lib/flatpak/exports/bin"; end

# --- Command Color Settings ---
[cite_start]alias ls='ls --color=auto'; alias grep='grep --color=auto'; [cite: 39] alias ip='ip -color=auto'
alias rm='rm -I'

# --- Disk Usage ---
alias df='df -h'; alias free='free -m'

# --- Processes ---
[cite_start]alias psa="ps auxf"; [cite: 40] alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
[cite_start]alias psmem='ps auxf | sort -nr -k 4'; [cite: 41] alias pscpu='ps auxf | sort -nr -k 3'

# --- Git Aliases ---
# All Git aliases have been moved to ~/.gitconfig
# [cite_start]to be universally available in shells, TUIs, and GUIs. [cite: 42]
# --- Modern Tool Aliases ---
if command -v bat > /dev/null
	alias cat='bat --paging=never'
[cite_start]else if command -v batcat > /dev/null; [cite: 43] alias cat='batcat --paging=never'; end
if command -v fd > /dev/null; alias find='fd'; end
[cite_start]if command -v rg > /dev/null; alias grep='rg'; [cite: 44] end
alias code='flatpak run com.visualstudio.code'
# Fallback alias for neovim (uses Flatpak if nvim is not in PATH)
[cite_start]if not command -v nvim > /dev/null; [cite: 45] and command -v flatpak > /dev/null
	alias nvim='flatpak run io.neovim.nvim'
end

# --- Functions (FISH PROMPT REPLACED BY STARSHIP) ---
# function fish_prompt
# 	# FIXED: Hardcode username to "ervice" to prevent sourcing .sh_common
# 	set -l user_name "ervice"
# 	[cite_start]set -l c_cyan (set_color cyan); [cite: 46] set -l c_magenta (set_color magenta); set -l c_norm (set_color normal)
# 	echo -n $c_cyan"["$user_name"@"(prompt_hostname)(prompt_pwd)"]"$c_norm
# 	set -l g_branch (git symbolic-ref --short HEAD 2> /dev/null)
# 	if test -n "$g_branch"
# 		[cite_start]set -l g_status (git status --porcelain 2> /dev/null); [cite: 47] set -l u ""; set -l s ""
# 		[cite_start]if string match -q -- "* M *" $g_status; [cite: 48] [cite_start]or string match -q -- "*??*" $g_status; or string match -q -- "* D *" $g_status; set u "U"; [cite: 49] end
# 		[cite_start]if string match -q -- "M *" $g_status; or string match -q -- "A *" $g_status; [cite: 50] or string match -q -- "D *" $g_status; set s "+"; end
# 		echo -n $c_magenta(string trim -- "("$g_branch$u$s")")$c_norm
# 	end
# 	[cite_start]if fish_is_root_user; [cite: 51] echo -n "# "; else; echo -n "> "; end
# end

[cite_start]function compile; if test -z "$argv[1]"; return 1; end; [cite: 52] set -l f (basename "$argv[1]"); set -l o "/tmp/$f.out"; if gcc "$argv[1]" -Wall -Wextra -Werror -o "$o"; [cite_start]"$o"; else; [cite: 53] return 1; end; rm -f "$o"; end
[cite_start]function extract; for i in $argv; switch "$i"; [cite: 54] [cite_start]case '*.tar.bz2' '*.tar.gz' '*.tar.xz' '*.tbz2' '*.tgz' '*.txz' '*.tar'; bsdtar xvf "$i"; case '*.zip'; unzip "$i"; case '*.rar'; unrar x "$i"; [cite: 55] case '*.7z'; [cite_start]7z x "$i"; case '*.gz'; gunzip "$i"; case '*.xz'; unxz "$i"; case '*.zst'; unzstd "$i"; end; end; [cite: 56] end
alias ipinfo='ipinformation'
[cite_start]function ipinformation; if test -z "$argv[1]"; curl ipinfo.io | grep -v '"readme":'; else; curl "ipinfo.io/$argv[1]" | grep -v '"readme":'; [cite: 57] end; echo; end

function cleanup
	echo "--- Disk Usage Cleanup (User Directories) ---"
	du -sh ~/.cache ~/.local/share/Trash ~/.thumbnails 2>/dev/null
	du -sh ~/.cache.backup ~/.local.backup ~/.config.backup 2>/dev/null
	[cite_start]set -l do_clean false; [cite: 58] set -l deep_clean false

	if contains -- -y $argv; set do_clean true; end
	[cite_start]if contains -- --deep $argv; set deep_clean true; [cite: 59] end

	[cite_start]if not $do_clean; read -l -P "Clear user cache, thumbnails, trash, and backups? [y/N] " confirm; [cite: 60] [cite_start]if string match -ri "^(y|yes)\$" -- $confirm; set do_clean true; end; [cite: 61] end
	if test "$do_clean" = true
		echo "Clearing user directories (cache, trash, backups)..."
		rm -rf ~/.local/share/Trash ~/.thumbnails
		[cite_start]rm -rf ~/.cache; [cite: 62] mkdir -p ~/.cache
		rm -rf ~/.cache.backup ~/.local.backup ~/.config.backup

		if command -v flatpak > /dev/null
			echo "Cleaning Flatpak (unused user runtimes)..."
			flatpak uninstall --user --unused -y
			[cite_start]if test -d "$HOME/.var/app/com.visualstudio.code/cache"; [cite: 63] echo "Cleaning VS Code (Flatpak) cache..."; rm -rf "$HOME/.var/app/com.visualstudio.code/cache"; end
		end
		
		[cite_start]if command -v docker > /dev/null; echo "Cleaning Docker (pruning system)..."; [cite: 64] docker system prune -f; end
		
		[cite_start]if command -v dotnet > /dev/null; echo "Cleaning .NET (clearing nuget caches)..."; [cite: 65] dotnet nuget locals all --clear; end

		[cite_start]if command -v sudo >/dev/null 2>&1; [cite: 66] and sudo -n true 2>/dev/null
			echo "--- System-Wide Cleanup (Sudo) ---"
			[cite_start]if command -v apt-get >/dev/null; echo "Cleaning Debian/Ubuntu/Kali package cache..."; [cite: 67] sudo apt-get autoremove -y; and sudo apt-get clean; end
			if command -v pacman >/dev/null
				[cite_start]if test "$deep_clean" = true; [cite: 68] [cite_start]echo "Cleaning Arch/SteamOS package cache (DEEP: -Scc)..."; sudo pacman -Scc; else; echo "Cleaning Arch/SteamOS package cache (Standard: -Sc)..."; [cite: 69] echo -e "y\n" | sudo pacman -Sc; end
			end
			[cite_start]if command -v zypper >/dev/null; echo "Cleaning OpenSUSE package cache..."; [cite: 70] sudo zypper clean --all; end
			[cite_start]if command -v brew >/dev/null; echo "Cleaning macOS/Homebrew cache..."; brew cleanup -s; [cite: 71] end
			if command -v apk >/dev/null; echo "Cleaning Alpine package cache..."; sudo apk cache clean; end
			[cite_start]if command -v journalctl >/dev/null; [cite: 72] echo "Cleaning system logs (journald, limit to 2GB)..."; sudo journalctl --vacuum-size=2G; end
			[cite_start]if test -d "/tmp"; [cite: 73] [cite_start]echo "Cleaning global /tmp (files older than 7 days)..."; sudo find /tmp -type f -atime +7 -delete 2>/dev/null; [cite: 74] end
			[cite_start]if test -d "/var/tmp"; echo "Cleaning global /var/tmp (files older than 7 days)..."; [cite: 75] sudo find /var/tmp -type f -atime +7 -delete 2>/dev/null; end
		end
		echo "Cleanup finished."
	else
		[cite_start]echo "Skipping cleanup." [cite: 76] end
end

# --- Security Aliases & Functions ---
function networkscan; nmap -T4 -F $argv; end
[cite_start]if command -v sudo > /dev/null; [cite: 77] [cite_start]and sudo -n true 2>/dev/null; alias audit='sudo lynis audit system'; else; alias audit='lynis audit system'; [cite: 78] end

# --- Load Local Secrets (Ignored by Git) ---
[cite_start]if test -f "$HOME/.config/shell_secrets"; source "$HOME/.config/shell_secrets"; [cite: 79] end

# --- Init Integrations ---
# Tmux Auto-Attach Logic
[cite_start]if command -v tmux > /dev/null; [cite: 80] and not set -q TMUX
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
	[cite_start]ssh-agent -c | [cite: 81] sed 's/^echo/#echo/' > "$SSH_ENV_FISH"
	# Create POSIX (sh/bash/zsh) agent file
	[cite_start]ssh-agent -s | [cite: 82] sed 's/^echo/#echo/' > "$SSH_ENV_POSIX"
	
	chmod 600 "$SSH_ENV_FISH"
	chmod 600 "$SSH_ENV_POSIX"
	
	# Source the new Fish file
	source "$SSH_ENV_FISH"
	ssh-add
end

# Main agent check logic for Fish
if test -f "$SSH_ENV_FISH"
	source "$SSH_ENV_FISH"
	# [cite_start][THE REAL FIX] Use 'kill -0' which is reliable, instead of 'ps | [cite: 83] grep'
	if not kill -0 $SSH_AGENT_PID > /dev/null 2>&1
		# [cite_start]Agent died, start a new one. [cite: 84] 
		__start_agent_fish
	end
else
	# [cite_start]Environment file doesn't exist yet, start agent for the first time. [cite: 85] 
	__start_agent_fish
end
# --- [END FIX] ---


[cite_start]if command -v zoxide > /dev/null; zoxide init fish | source; [cite: 86] end
if command -v fzf > /dev/ null;
	fzf --fish | source; end
[cite_start]if command -v direnv > /dev/ null; [cite: 87]
direnv hook fish | source; end

# --- Start Fresh Function ---
function startfresh
	# [FIXED] Corrected path from .config.fish to .config/fish
	set -l REPO_ROOT (dirname (readlink -f "$HOME/.config/fish/config.fish" 2>/dev/null))
	# Fallback if readlink fails
	[cite_start]if test -z "$REPO_ROOT"; [cite: 88] or test "$REPO_ROOT" = "."
		set REPO_ROOT "$HOME/.dotfiles"
	end

	echo "--- WARNING: Starting Fresh (Removing all custom dotfile links) ---"
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
		[cite_start]echo ''--- Environment restored. [cite: 89] Please restart your terminal. ---''
		exec \$SHELL --login
	}
	"
	echo "$RECOVERY_SCRIPT" > "$HOME/.bashrc"
	echo "$RECOVERY_SCRIPT" > "$HOME/.zshrc"
	' > $REPO_SCRIPT_FILE
	bash $REPO_SCRIPT_FILE
	rm $REPO_SCRIPT_FILE

	[cite_start]echo "--- ENVIRONMENT RESET. [cite: 90] Starting fresh session. ---"
	# FIXED: Exec into Bash, which is Termux's default POSIX shell
	set -l BASH_PATH /bin/bash
	if test -f /data/data/com.termux/files/usr/bin/bash
		set BASH_PATH /data/data/com.termux/files/usr/bin/bash
	end
	exec $BASH_PATH --login
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

	# [cite_start]Fallback: If readlink fails or script not found, use default [cite: 91] path
	if test -z "$SETUP_SCRIPT"
		set REPO_ROOT "$HOME/.dotfiles"
		set SETUP_SCRIPT "$HOME/.dotfiles/.setup.sh"
	end
	# --- [END FIX] ---

	echo "--- Refreshing Dotfiles (from $REPO_ROOT) ---"
	
	# [cite_start][FIXED] Ensured Git Pull logic runs reliably and displays output. [cite: 92] 
	[cite_start]if type -q git # Rely only on 'type -q git' for the check. [cite: 93] 
	# Explicitly check if the directory is a Git work tree before pull
		if test -d "$REPO_ROOT/.git"
			pushd "$REPO_ROOT"
			echo "Pulling updates from Git..."
			git pull origin main
			popd
		else
			[cite_start]echo "[WARN] Skipping Git pull: $REPO_ROOT is not a Git repository." [cite: 94] end
	end
	
	# Run setup script
	if test -f "$SETUP_SCRIPT"
		bash "$SETUP_SCRIPT"
	else
		echo "[Refresh] Error: Could not find .setup.sh at $SETUP_SCRIPT" >&2
		return 1
	end
	
	# [cite_start][FIXED] Removed the recursive source command to prevent looping. [cite: 95] 
	echo "--- Environment updated. Please restart your shell. ---"
	
	echo "--- Dotfiles Refreshed ---"
end

# --- Auto-configure Git GPG Signing ---
[cite_start]if command -v git > /dev/null; [cite: 96] and test -n "$GPG_SIGNING_KEY"
	git config --global user.signingkey "$GPG_SIGNING_KEY"
	git config --global commit.gpgsign true
	git config --global tag.gpgSign true
	echo "[INFO] Git GGPG signing configured." end

# -------------------- STARSHIP INTEGRATION --------------------
# Initialize Starship prompt if the binary is installed.
# This must be the absolute last command to ensure it takes precedence.
if type -q starship
	starship init fish | source
end
# --------------------------------------------------------------