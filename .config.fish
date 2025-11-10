# ~/.config.fish/config.fish - Fish shell configuration

if not status is-interactive; exit; end

# --- Auto-Refresh (Once per session) ---
set -l marker_file "/tmp/dotfiles_initialized_"(id -u)
if not test -f "$marker_file"
	if not command -v kitty >/dev/null 2>&1
		echo "[Auto-Setup] Essential tools missing. Running setup..."
		set -l C_PATH ~/.config/fish/config.fish; set -l D_DIR (dirname (readlink -f $C_PATH)); set -l S_SCRIPT "$D_DIR/.setup.sh"
		if test -f "$S_SCRIPT"; bash "$S_SCRIPT"; else; bash "$HOME/dotfiles/.setup.sh"; end
	end
	touch "$marker_file"
end

set -gx TERMINAL kitty; set -gx EDITOR nvim; set -gx NAVIGATOR brave
set -gx USER ervice; set -gx MAIL erkka@ervice.fi

function fish_greeting; end

if test -d "$HOME/.cargo/bin"; fish_add_path "$HOME/.cargo/bin"; end
if test -d "/var/lib/flatpak/exports/bin"; fish_add_path "/var/lib/flatpak/exports/bin"; end

alias ls='ls --color=auto'; alias grep='grep --color=auto'; alias ip='ip -color=auto'
alias df='df -h'; alias free='free -m'
alias psa="ps auxf"; alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'; alias pscpu='ps auxf | sort -nr -k 3'

alias addup='git add -u'; alias addall='git add .'; alias branch='git branch'
alias checkout='git checkout'; alias clone='git clone'; alias commit='git commit -m'
alias fetch='git fetch'; alias pull='git pull origin'; alias push='git push origin'
alias stat='git status'; alias tag='git tag'; alias newtag='git tag -a'
alias gl='git log --oneline --graph --decorate --all'

if command -v bat > /dev/null; alias cat='bat --paging=never'
else if command -v batcat > /dev/null; alias cat='batcat --paging=never'; end
if command -v fd > /dev/null; alias find='fd'; end
if command -v rg > /dev/null; alias grep='rg'; end
alias code='flatpak run com.visualstudio.code'

function fish_prompt
	set -l user_name ""; if test -f "$HOME/.sh_common"; set user_name (bash -c 'source ~/.sh_common && service_user'); else; set user_name (whoami); end
	set -l c_cyan (set_color cyan); set -l c_magenta (set_color magenta); set -l c_norm (set_color normal)
	echo -n $c_cyan"["$user_name"@" (prompt_hostname) (prompt_pwd) "]"$c_norm
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
	echo "--- Disk Usage Cleanup ---"
	du -sh ~/.cache ~/.local/share/Trash ~/.thumbnails 2>/dev/null
	set -l do_clean false
	if contains -- -y $argv
		set do_clean true
	else
		read -l -P "Clear user cache, thumbnails, and trash? [y/N] " confirm
		if string match -ri "^(y|yes)\$" -- $confirm; set do_clean true; end
	end
	if test "$do_clean" = true
		echo "Clearing..."
		rm -rf ~/.local/share/Trash/* 2>/dev/null
		rm -rf ~/.cache/* 2>/dev/null
		rm -rf ~/.thumbnails/* 2>/dev/null
		if command -v sudo >/dev/null 2>&1; and sudo -n true 2>/dev/null
			echo "Cleaning system package cache (sudo)..."
			if command -v apt-get >/dev/null; sudo apt-get autoremove -y; and sudo apt-get clean; end
			if command -v pacman >/dev/null; echo -e "y\ny\n" | sudo pacman -Sc; end
		end
		echo "Cleanup finished."
	else
		echo "Skipping cleanup."
	end
end

if test -f "$HOME/.ssh_agent_init"; source "$HOME/.ssh_agent_init"; end
if command -v zoxide > /dev/null; zoxide init fish | source; end
if command -v fzf > /dev/null; fzf --fish | source; end

function dotfiles_refresh
	set -l C_PATH ~/.config/fish/config.fish; set -l D_DIR (dirname (readlink -f $C_PATH))
	echo "--- Refreshing Dotfiles ---"
	if type -q git and test -d "$D_DIR/.git"; begin; cd "$D_DIR"; git pull origin main; end; end
	bash "$D_DIR/.setup.sh"; source (status --current-filename); echo "--- Dotfiles Refreshed ---"
end
alias refresh 'dotfiles_refresh'