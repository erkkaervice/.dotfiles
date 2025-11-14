#!/bin/bash
#
# ~/.dotfiles/.scripts/cleanup.sh
#
# Master "cleanup" script.
# This is the single source of truth, called by wrappers in all shells.
#

echo "--- Disk Usage Cleanup (User Directories) ---"
du -sh ~/.cache ~/.local/share/Trash ~/.thumbnails 2>/dev/null
du -sh ~/.cache.backup ~/.local.backup ~/.config.backup 2>/dev/null

DO_CLEAN=0
DEEP_CLEAN=0
OPT=""

# Parse arguments
while [ "$#" -gt 0 ];
do
	OPT="$1"
	case $OPT in
		-y|--yes)
			DO_CLEAN=1
			shift
			;;
		--deep)
			DEEP_CLEAN=1
			shift
			;;
		*)
			echo "Unknown option: $1" >&2
			exit 1
			;;
	esac
done

if [ "$DO_CLEAN" -eq 0 ];
then
	printf "Clear user cache, thumbnails, trash, and backups? [y/N] "
	read -r response
	if [ "$(echo "$response" | tr '[:upper:]' '[:lower:]')" = "y" ] || [ "$(echo "$response" | tr '[:upper:]' '[:lower:]')" = "yes" ]; then
		DO_CLEAN=1
	fi
fi

if [ "$DO_CLEAN" -eq 1 ];
then
	echo "Clearing user directories (cache, trash, backups)..."
	rm -rf ~/.local/share/Trash ~/.thumbnails
	rm -rf ~/.cache; mkdir -p ~/.cache
	rm -rf ~/.cache.backup ~/.local.backup ~/.config.backup
	
	command -v flatpak >/dev/null 2>&1 && {
		echo "Cleaning Flatpak (unused user runtimes)..."
		flatpak uninstall --user --unused -y
		[ -d "$HOME/.var/app/com.visualstudio.code/cache" ] && {
			echo "Cleaning VS Code (Flatpak) cache..."
			rm -rf "$HOME/.var/app/com.visualstudio.code/cache"
		}
	}
	
	command -v docker >/dev/null 2>&1 && {
		echo "Cleaning Docker (pruning system)..."
		docker system prune -f
	}
	
	command -v dotnet >/dev/null 2>&1 && {
		echo "Cleaning .NET (clearing nuget caches)..."
		dotnet nuget locals all --clear
	}
	
	# Sudo-based cleanup
	if sudo -n true 2>/dev/null;
	then
		echo "--- System-Wide Cleanup (Sudo) ---"
		
		command -v apt-get >/dev/null 2>&1 && {
			echo "Cleaning Debian/Ubuntu/Kali package cache..."
			sudo apt-get autoremove -y && sudo apt-get clean
		}
		
		command -v pacman >/dev/null 2>&1 && {
			if [ "$DEEP_CLEAN" -eq 1 ];
			then
				echo "Cleaning Arch/SteamOS package cache (DEEP: -Scc)..."
				sudo pacman -Scc --noconfirm
			else
				echo "Cleaning Arch/SteamOS package cache (Standard: -Sc)..."
				echo -e "y\n" | sudo pacman -Sc
			fi
		}
		
		command -v zypper >/dev/null 2>&1 && {
			echo "Cleaning OpenSUSE package cache..."
			sudo zypper clean --all
		}
		
		command -v brew >/dev/null 2>&1 && {
			echo "Cleaning macOS/Homebrew cache..."
			brew cleanup -s
		}
		
		command -v apk >/dev/null 2>&1 && {
			echo "Cleaning Alpine package cache..."
			sudo apk cache clean
		}
		
		command -v journalctl >/dev/null 2>&1 && {
			echo "Cleaning system logs (journald, limit to 2GB)..."
			sudo journalctl --vacuum-size=2G
		}
		
		[ -d "/tmp" ] && {
			echo "Cleaning global /tmp (files older than 7 days)..."
			sudo find /tmp -type f -atime +7 -delete 2>/dev/null
		}
		[ -d "/var/tmp" ] && {
			echo "Cleaning global /var/tmp (files older than 7 days)..."
			sudo find /var/tmp -type f -atime +7 -delete 2>/dev/null
		}
	fi
	
	echo "Cleanup finished."
else
	echo "Skipping cleanup."
fi