# dotfiles
Personal shell configuration files for creating a consistent, powerful environment across various Linux distributions, macOS, and Termux.

This repository provides synchronized setups for Bash, Zsh, and Fish. It standardizes not just the shell, but the entire terminal experience by including configurations for the **Kitty** terminal emulator and bundled system-wide font preferences. It features automated setup scripts that handle everything from package installation (with non-root fallbacks) to desktop environment integration.

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
* **Universal Terminal**: Standardizes on **Kitty** across all desktop systems for a consistent rendering experience.
* **Consistent Fonts**:
    * **Terminal**: Automatically installs and configures **Inconsolata** as the default monospace font.
    * **UI/Desktop**: Includes and installs **Candara** as the default UI font via a bundled `.fonts` directory.
* **Desktop Integration**: A specialized script (`.configure_desktop.sh`) automatically sets Kitty as the default terminal and applies font settings on GNOME, KDE Plasma, and XFCE.

### Multi-Shell Support
* **Bash & Zsh**: Share a common core configuration (`.sh_common`) for identical aliases, exports, and functions.
* **Fish**: A feature-rich, standalone configuration (`.config.fish`) that mirrors all POSIX functionality.
* **Auto-Switch**: Automatically attempts to switch to Fish in graphical sessions if installed.

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
* **`refresh`**: The master command. Pulls updates from Git, re-runs the full setup/installation script, updates fonts/desktop integration, and reloads the current shell.
* **`extract`**: Universal archive extractor.
* **`ipinfo`**: Quick public IP and domain lookup.
* **`compile`**: Simple C/C++ builder.

### Automation & Maintenance
* **Smart Auto-Refresh**: Runs the setup logic once per session (or if critical tools are missing) to ensure school/shared computers are always configured correctly upon login.
* **Robust Installation**: `setup.sh` detects the OS, handles `sudo`/non-`sudo` scenarios, and installs packages accordingly.
    * **Non-Root Fallback**: If `sudo` is unavailable, it automatically installs Kitty, Zoxide, and FZF locally to `~/.local/bin` and integrates them with the desktop.
* **SSH Persistence**: keeps `ssh-agent` running across sessions.

---

## Supported Systems

The `setup.sh` script automatically detects and supports:

* **Debian / Ubuntu** (and derivatives like Mint, Pop!_OS)
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
    * Symlinks all configuration files (`.bashrc`, `.zshrc`, `.config/fish`, `.kitty.conf`, etc.).
    * Triggers desktop integration to set Kitty and standard fonts as default.

3.  **Restart:**
    Close and reopen your terminal. You should now be in Fish (if graphical) or have all standard aliases available.

---

## Usage

Once installed, standard commands work everywhere:

* **`refresh`**: Update everything. Run this if you add new fonts or change configs.
* **`z <dir>`**: Jump quickly to a directory.
* **`CTRL+R`**: Fuzzy search command history.
* **`ipinfo`**: Check your connection.

**Launching Kitty:**
If installed successfully, Kitty should appear in your system's application menu (Super/Windows key -> type "Kitty").

---

## Structure

* **`.setup.sh`**: Master installation script. Handles OS detection, package managers, local fallbacks, font installation, and file linking.
* **`.configure_desktop.sh`**: Called by setup.sh to apply GNOME/KDE/XFCE specific settings (default terminal, fonts).
* **`.sh_common`**: Core logic shared by Bash and Zsh (aliases, exports, auto-refresh).
* **`.config.fish`**: Feature-equivalent configuration for Fish shell.
* **`.kitty.conf`**: Cross-platform configuration for the Kitty terminal (fonts, opacity).
* **`.fonts.conf`**: System-wide configuration to map "monospace" to Inconsolata and "sans-serif" to Candara.
* **`.fonts/`**: Directory containing bundled TrueType fonts.
* **`.bashrc` / `.zshrc` / `.profile`**: Standard shell entry points that source the common config.

---

## Customization

* **Terminal Settings**: Edit `.kitty.conf` to change opacity or font size across all your machines.
* **Aliases/Functions**: Add to `.sh_common` (for Bash/Zsh) AND `.config.fish` (for Fish) to ensure they are available everywhere.
* **New Fonts**: Just drop new `.ttf` files into the `.fonts/` directory and run `refresh`.

---

## Troubleshooting

* **Kitty not in menu**: Run `refresh` again. The script includes a specific fix to regenerate the `.desktop` file in `~/.local/share/applications` if it's missing.
* **Wrong Shell**: If you aren't switched to Fish automatically, ensure `fish` is in your standard `/bin` or `/usr/bin`.
* **Missing Icons**: If your prompt looks weird, ensure a Nerd Font (like the installed Inconsolata) is actually selected in your terminal emulator.

---

## License

[MIT License](LICENSE.txt)