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
            
			# 1. Stash changes, capturing both exit code AND text output
			STASH_OUTPUT=$(git stash push -u -m "Auto-stashed by dotfiles refresh script" 2>&1)
			STASHED=$?
            
			# 2. Check if a stash was *actually* created
			# FIX: Removed 'local' keyword, as this is a subshell, not a function.
			DID_STASH=1 # 1 = false (no stash created)
			if [ $STASHED -eq 0 ] && ! echo "$STASH_OUTPUT" | grep -q "No local changes to save"; then
				DID_STASH=0 # 0 = true (stash was created)
			fi

			# 3. Pull updates
			git pull origin main || print_error "Git pull failed. Manual intervention may be required."
				
			# 4. Apply stash back IF AND ONLY IF a stash was created (DID_STASH=0)
			if [ $DID_STASH -eq 0 ]; then
				print_info "Re-applying stashed local changes..."
				# --index tries to restore staged files back to staged
				if ! git stash pop --index; then 
					print_warning "Conflict detected when popping stash. Please resolve manually and run setup again."
				fi
			else
				print_info "No local changes were stashed."
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