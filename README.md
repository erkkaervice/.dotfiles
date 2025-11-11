# dotfiles
Personal shell configuration files for creating a consistent, powerful, and secure environment across various Linux distributions, macOS, and Termux.

This repository provides synchronized setups for Bash, Zsh, and Fish. It standardizes not just the shell, but the entire terminal experience by including configurations for the **Kitty** terminal emulator and bundled system-wide font preferences. It features automated setup scripts that handle everything from package installation (with non-root fallbacks) to desktop environment integration and security hardening.

---

## Table of Contents

- [Features](#features)
- [Supported Systems](#supported-systems)
- [Installation](#installation)
- [Usage](#usage)
- [Structure](#structure)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Features

This configuration provides:

### Core Terminal Experience
* **Universal Terminal**: Standardizes on **Kitty** across all desktop systems for a consistent rendering experience with no title bar.
* **Consistent Fonts**:
    * **Terminal**: Automatically installs and configures **Inconsolata** as the default monospace font.
    * **UI/Desktop**: Includes and installs **Candara** as the default UI font via a bundled `.fonts` directory.
* **Desktop Integration**: A specialized script (`.configure_desktop.sh`) automatically sets Kitty as the default terminal and applies font settings on GNOME, KDE Plasma, and XFCE.

### Multi-Shell Support
* **Bash & Zsh**: Share a common core configuration (`.sh_common`) for identical aliases, exports, and functions.
* **Fish**: A feature-rich, standalone configuration (`.config.fish`) that mirrors all POSIX functionality.
* **Auto-Switch**: (Currently disabled) Logic exists to automatically switch to Fish in graphical sessions.

### Custom Prompts
* **Unified Look**: All three shells feature a consistent **Cyan** (user/host) and **Magenta** (Git) color scheme.
* **Git-Aware**: Displays branch and status indicators (`U` for unstaged, `+` for staged) only when inside a repository.
* **Smart Paths**: Abbreviates intermediate directories (e.g., `~/h/.dotfiles`).
* **Fixed Identity**: Forces the displayed username to **`ervice`** across all systems for consistency.

### Productivity Tools & Aliases
* **Modern Replacements**: Automatically installs and aliases `cat` → `bat`, `find` → `fd`, `grep` → `ripgrep`, and `cd` → `zoxide`.
* **Fuzzy Finding**: Integrates `fzf` for history search (`CTRL-R`), file search (`CTRL-T`), and directory jumping (`ALT-C`).
* **System Management**: Colorized `ip`, human-readable `df`/`free`, and process shortcuts (`psa`, `psmem`, `pscpu`).
* **Git Shortcuts**: `addup`, `addall`, `stat`, `pull`, `push`, `gl` (pretty log).

### Helper Functions
* **`refresh`**: The master command. Pulls updates from Git, re-runs the full setup/installation script, and reloads the current shell.
* **`startfresh`**: A "factory reset" that wipes all custom configs and local apps, resetting to a clean system shell while preserving a recovery `refresh` command.
* **`cleanup`**: Cleans user caches (`~/.cache`, Trash) and optionally system package caches (e.g., `cleanup --deep` for aggressive Pacman cleaning).
* **`extract`**: Universal archive extractor.
* **`ipinfo`**: Quick public IP and domain lookup.
* **`compile`**: Simple C/C++ builder.

### Automation, Maintenance, & Security
* **Smart Auto-Refresh**: Runs the setup logic once per session (if essential tools like `zoxide` are missing) to ensure new machines are always configured correctly upon login.
* **Robust Installation**: `setup.sh` detects the OS, handles `sudo`/non-`sudo` scenarios, and installs packages accordingly.
    * **Non-Root Fallback**: If `sudo` is unavailable, it automatically installs Kitty, Zoxide, and FZF locally to `~/.local/bin` and integrates them with the desktop.
* **Security Hardening**:
    * **Secure `PATH`**: Appends user `PATH` directories (like `~/.local/bin`) instead of prepending, preventing `PATH` injection attacks.
    * **Secret Management**: Includes a `.gitignore` and logic to load a private `~/.config/shell_secrets` file, so you can store API keys and tokens locally without committing them to Git.
    * **SSH Permissions**: `setup.sh` automatically enforces correct, secure permissions (e.g., `chmod 700 ~/.ssh`, `chmod 600 ~/.ssh/id_*`) on every run.
    * **Secure Downloads**: All `curl` installers use flags to enforce HTTPS-only connections and fail safely on errors.
* **SSH Persistence**: Includes `.ssh_agent_init` to keep `ssh-agent` running across sessions.

---

## Supported Systems

The `setup.sh` script automatically detects and supports:

* **Debian / Ubuntu / Kali Linux** (and derivatives like Mint, Pop!_OS)
* **Arch Linux / SteamOS**
* **openSUSE**
* **Alpine Linux**
* **macOS** (via Homebrew)
* **Termux** (Android - text-only mode, skips GUI apps like Kitty)

---

## Installation

1.  **Clone the repository:**
    ```sh
    git clone git@github.com:erkkaervice/.dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

2.  **Run the Setup Script:**
    ```sh
    bash .setup.sh
    ```
    *What it does:*
    * Detects OS and checks for `sudo` rights.
    * Installs required packages (falling back to local user install if `sudo` is missing).
    * Installs bundled custom fonts (Candara) and system fonts (Inconsolata).
    * Hardens SSH directory permissions.
    * Symlinks all configuration files (`.bashrc`, `.zshrc`, `.config/fish`, `.kitty.conf`, etc.).
    * Triggers desktop integration to set Kitty and standard fonts as default.

3.  **Restart:**
    Close and reopen your terminal. The auto-refresh logic should run automatically, and you will be in your fully configured shell.

---

## Usage

Once installed, standard commands work everywhere:

* **`refresh`**: Update everything. Run this if you make changes in your Git repo.
* **`cleanup`**: Clean up temporary files and caches.
* **`startfresh`**: Reset your entire custom shell environment to system defaults. (Run `refresh` to get it back).
* **`z <dir>`**: Jump quickly to a directory.
* **`CTRL+R`**: Fuzzy search command history.

**Launching Kitty:**
If installed successfully, Kitty should appear in your system's application menu (Super/Windows key -> type "Kitty").

---

## Structure

* **`.setup.sh`**: Master installation script. Handles OS detection, package managers, local fallbacks, font installation, and file linking.
* **`.configure_desktop.sh`**: Called by `setup.sh` to apply GNOME/KDE/XFCE specific settings (default terminal, fonts).
* **`.sh_common`**: Core logic shared by Bash and Zsh (aliases, exports, `refresh`, `cleanup`, `startfresh`).
* **`.config.fish`**: Feature-equivalent configuration for Fish shell.
* **`.kitty.conf`**: Cross-platform configuration for the Kitty terminal (fonts, opacity).
* **`.fonts.conf`**: System-wide configuration to map "monospace" to Inconsolata and "sans-serif" to Candara.
* **`.fonts/`**: Directory containing bundled TrueType fonts (Candara).
* **`.gitignore`**: Prevents secrets, cache files, and OS junk from being committed.
* **`.ssh_agent_init`**: Cross-shell script to manage `ssh-agent` persistence.
* **`.bashrc` / `.zshrc` / `.profile`**: Standard shell entry points that source the common config.

---

## Customization

* **Terminal Settings**: Edit `.kitty.conf` to change opacity or font size.
* **Aliases/Functions**: Add to `.sh_common` (for Bash/Zsh) AND `.config.fish` (for Fish) to ensure they are available everywhere.
* **New Fonts**: Just drop new `.ttf` files into the `.fonts/` directory and run `refresh`.
* **Secrets**: On any machine, create a **new file** at `~/.config/shell_secrets` (e.g., `export MY_TOKEN="123"`). This file is loaded automatically but is ignored by Git, keeping your secrets safe and local.

---

## Troubleshooting

* **`startfresh` fails:** If `refresh` is not found after running `startfresh`, you may need to manually `cd ~/dotfiles` and run `bash .setup.sh` one time to restore the environment.
* **Kitty not in menu**: Run `refresh` again. The script includes a specific fix to regenerate the `.desktop` file in `~/.local/share/applications` if it's missing.
* **Wrong Shell**: If you aren't switched to Fish automatically, ensure `fish` is in your standard `/bin` or `/usr/bin` (and that the auto-switch logic is uncommented in `.bashrc`/`.zshrc`).

---

## License

[MIT License](LICENSE.txt)
