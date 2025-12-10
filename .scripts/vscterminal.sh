#!/bin/sh

# Check if we are running inside a Flatpak sandbox
if [ -f "/.flatpak-info" ]; then
	# Flatpak: Break out to the host
	exec /usr/bin/flatpak-spawn --host --env=TERM=xterm-256color bash -l
else
	# Native: Just run bash as a login shell
	exec bash -l
fi