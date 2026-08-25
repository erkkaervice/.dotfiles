#!/bin/sh

# Use the user's preferred shell, default to bash if not set
TARGET_SHELL="${SHELL:-bash}"

# Check if we are running inside a Flatpak sandbox
if [ -f "/.flatpak-info" ]; then
	# Flatpak: Break out to the host
	exec /usr/bin/flatpak-spawn --host --env=TERM=xterm-256color "$TARGET_SHELL" -l
else
	# Native: Just run the target shell as a login shell
	exec "$TARGET_SHELL" -l
fi
