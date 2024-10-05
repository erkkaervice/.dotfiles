#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Enter fish for graphical sessions
if [[ $DISPLAY ]]; then
	export SHELL=/usr/bin/fish
	[ -x $SHELL ] && exec $SHELL "$@"
	echo "Switching shell failed"
	export SHELL=/bin/bash
fi

# Prompt configuration
PS1='[\u@\h \W]\$ '

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/var/lib/flatpak/exports/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
source /usr/share/doc/pkgfile/command-not-found.bash

# Enable extended pattern matching
shopt -s extglob

# Autocomplete
complete -c man which
complete -cf sudo

# Command color settings
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'

# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Disk usage
alias df='df -h'         # Human-readable sizes
alias free='free -m'     # Show sizes in MB

# Processes
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -E"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Git
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
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Pacman cleanup
alias cpac='sudo pacman -Rns $(pacman -Qdtq)'

# Bash cleanup
alias bashwipe='wipe_history'
wipe_history() {
    wipe -i -l2 -x4 -p4 "$HISTFILE" && ln -sv /dev/null "$HISTFILE"
}

# Compiler function
alias compile='compiler'
compiler() {
    [[ $1 ]] || { echo "Missing operand" >&2; return 1; }
    [[ -r $1 ]] || { printf "File %s does not exist or is not readable\n" "$1" >&2; return 1; }
    local output_path=${TMPDIR:-/tmp}/${1##*/};
    gcc "$1" -Wall -Wextra -Werror -o "$output_path" && "$output_path";
    rm "$output_path";
    return 0;
}

# Extract function
alias extract='extractor'
extractor() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz|zst)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *.zst) c=(unzstd);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}

# IP information function
alias ipinfo='ipinformation'
ipinformation() { 
    if grep -P "(([1-9]\d{0,2})\.){3}(?2)" <<< "$1"; then
	curl ipinfo.io/"$1"
    else
	ipawk=($(host "$1" | awk '/address/ { print $NF }'))
	curl ipinfo.io/${ipawk[1]}
    fi
    echo
}
