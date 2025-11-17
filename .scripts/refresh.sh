#!/bin/bash
#
# ~/.dotfiles/.scripts/refresh.sh
#
# Master "refresh" script. Pulls git updates and re-runs the setup script.
# This is the single source of truth, called by wrappers in all shells.
#

# --- Helper Functions ---
print_info() { echo "[INFO] $1"; }
print_error() { echo "[ERROR] $1" >&2; }
print_warning() { echo "[WARN] $1" >&2; }

# --- Find Repo Root ---
REPO_ROOT=""
SETUP_SCRIPT=""

if [ -f "$HOME/.dotfiles-path" ];
then
	REPO_ROOT=$(cat "$HOME/.dotfiles-path")
else
	# Fallback: Assume standard path
	REPO_ROOT="$HOME/.dotfiles"
fi
SETUP_SCRIPT="$REPO_ROOT/.setup.sh"

print_info "--- Refreshing Dotfiles (from $REPO_ROOT) ---"

if command -v git >/dev/null 2>&1;
then
	if [ -d "$REPO_ROOT/.git" ]; then
		(
			print_info "Pulling updates from Git..."
			cd "$REPO_ROOT"
            
			# --- FIX: Implement Stash/Pop to handle local uncommitted changes ---
            
			# 1. Stash changes, suppress output
			# -u includes untracked files. STASHED=0 means stashed successfully.
			STASH_OUTPUT=$(git stash push -u -m "Auto-stashed by dotfiles refresh script" 2>&1)
			STASHED=$?
            
			# Check if stashing was successful (0) or if there were no changes (1)
			if [ $STASHED -eq 0 ] || [ $STASHED -eq 1 ]; then
				
				# 2. Pull updates (will rebase due to .gitconfig)
				git pull origin main || print_error "Git pull failed. Manual intervention may be required."
				
				# 3. Apply stash back IF AND ONLY IF changes were stashed (STASHED=0)
				if [ $STASHED -eq 0 ]; then
					print_info "Re-applying stashed local changes..."
					# --index tries to restore staged files back to staged
					# Check return code of pop command to detect conflicts
					if ! git stash pop --index; then 
						print_warning "Conflict detected when popping stash. Please resolve manually and run setup again."
					fi
				else
					# STASHED = 1 (No local changes, no need to pop)
					print_info "No local changes were stashed."
				fi
			else
				print_error "Git stash failed: $STASH_OUTPUT"
			fi
		)
	else
		print_warning "Skipping Git pull: $REPO_ROOT is not a Git repository."
	fi
fi

# Run setup script
if [ -f "$SETUP_SCRIPT" ];
then
	bash "$SETUP_SCRIPT"
else
	print_error "[Refresh] Error: Could not find setup script at $SETUP_SCRIPT"
	exit 1
fi

print_info "--- Dotfiles Refreshed. Please source your RC file or restart your shell. ---"