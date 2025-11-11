#!/bin/bash
#
# .configure_desktop.sh - Configures default terminal and system fonts for DEs.
#

# --- Helper Functions ---
print_info() { echo "[INFO] $1"; }
print_warning() { echo "[WARN] $1" >&2; }
print_error() { echo "[ERROR] $1" >&2; }

# --- Detect Desktop Environment ---
detect_de() {
	if [ -n "$XDG_CURRENT_DESKTOP" ]; then echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]'; return; fi
	if [ -n "$GNOME_DESKTOP_SESSION_ID" ]; then echo "gnome"
	elif [ -n "$KDE_FULL_SESSION" ]; then echo "kde"
	elif [ -f /usr/bin/xfce4-session ]; then echo "xfce"
	else echo "unknown"; fi
}

# --- Main Logic ---
if ! command -v kitty >/dev/null 2>&1; then print_error "Kitty not found. Cannot set defaults."; KITTY_AVAILABLE=false; else KITTY_AVAILABLE=true; fi
CURRENT_DE=$(detect_de); print_info "Detected Desktop Environment: $CURRENT_DE"

case "$CURRENT_DE" in
	*gnome*|*unity*)
		print_info "Configuring GNOME..."
		if command -v gsettings >/dev/null 2>&1; then
			if [ "$KITTY_AVAILABLE" = true ]; then gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'; gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''; fi
			gsettings set org.gnome.desktop.interface font-name 'Candara 11'
			gsettings set org.gnome.desktop.interface document-font-name 'Candara 11'
			gsettings set org.gnome.desktop.interface monospace-font-name 'Inconsolata 12'
			print_info "GNOME settings updated."
		else print_warning "gsettings not found."; fi ;;
	*kde*|*plasma*)
		print_info "Configuring KDE..."
		if command -v kwriteconfig5 >/dev/null 2>&1; then
			if [ "$KITTY_AVAILABLE" = true ]; then kwriteconfig5 --file kdeglobals --group General --key TerminalApplication kitty; kwriteconfig5 --file ~/.config/kdedefaults/kdeglobals --group General --key TerminalApplication kitty; fi
			print_info "KDE settings updated."
		else print_warning "kwriteconfig5 not found."; fi ;;
	*xfce*)
		print_info "Configuring XFCE..."
		if command -v xfconf-query >/dev/null 2>&1; then
			if [ "$KITTY_AVAILABLE" = true ]; then
				xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -s "kitty" --create
				if command -v exo-open >/dev/null 2>&1; then
					mkdir -p ~/.config/xfce4/helpers
					echo -e "[Desktop Entry]\nNoDisplay=true\nVersion=1.0\nEncoding=UTF-8\nType=X-XFCE-Helper\nX-XFCE-Category=TerminalEmulator\nX-XFCE-CommandsWithParameter=kitty \"%s\"\nX-XFCE-Commands=kitty\nIcon=kitty\nName=kitty\nStartupNotify=true" > ~/.config/xfce4/helpers/kitty.desktop
					xfconf-query -c xfce4-session -p /general/TerminalEmulator -s kitty --create -t string
				fi
			fi
			xfconf-query -c xsettings -p /Gtk/FontName -s 'Candara 11' --create
			xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s 'Inconsolata 12' --create
			print_info "XFCE settings updated."
		else print_warning "xfconf-query not found."; fi ;;
	*) print_warning "Unknown DE: $CURRENT_DE.";;
esac

if [ -f /etc/debian_version ] && command -v update-alternatives >/dev/null 2>&1; then
	if [ "$EUID" -ne 0 ] && ! sudo -n true >/dev/null 2>&1; then print_warning "Not root. Skipping update-alternatives."
	elif [ "$KITTY_AVAILABLE" = true ]; then print_info "Setting Debian alternatives priority..."; sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(which kitty)" 50 2>/dev/null; fi
fi
exit 0
