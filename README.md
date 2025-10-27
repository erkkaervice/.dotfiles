# dotfiles
Personal shell configuration files for creating a consistent environment across various Linux distributions and shells (Bash, Zsh, and Fish).

dotfiles provides setups for Bash, Zsh, and Fish. It includes a shared configuration for Bash/Zsh (`.sh_common`) and a separate, feature-rich configuration for Fish (`.config.fish`). It includes colorized output, useful aliases, helper functions, and a setup script that links configuration files automatically.

---

## Table of Contents

- Features
- Supported Systems
- Installation
- Usage
- Structure
- Customization
- Troubleshooting
- License

---

## Features

This configuration provides:

**Multi-Shell Support**:
* Configuration split for Bash (`.bashrc`) and Zsh (`.zshrc`), sourcing a common file (`.sh_common`) for shared settings.
* A standalone, comprehensive configuration for Fish (`.config.fish`) that provides the same aliases and functions.

**Fish Shell Auto-switch**: Automatically attempts to switch to the Fish shell in graphical sessions (from Bash) if installed.

**Custom Prompt**:
* **Git-Aware Prompts**: Bash, Zsh, and Fish all now feature prompts that display the current Git branch and status (e.g., `*` for unstaged changes, `+` for staged changes).
* **Color-Coded**: The main prompt (`[user@host dir]`) is colored cyan, and the Git information is colored magenta for clear visibility, mimicking the Fish shell's default behavior.

**Useful Aliases**:
* Colorized output for `ls`, `grep`, `ip`.
* Human-readable `df` and `free`.
* Process management shortcuts (`psa`, `psgrep`, `psmem`, `pscpu`).
* Common Git commands (`addup`, `addall`, `stat`, `pull`, `push`, etc.).
* `code` alias for the VS Code Flatpak.

**Helper Functions**:
* `compile`: Simple C/C++ compilation and execution.
* `extract`: Universal extractor for various archive types.
* `ipinfo`: Quick IP/domain information lookup using `curl`.

**PATH Management**: Adds `~/.local/bin`, `~/.cargo/bin`, and Flatpak paths to the `PATH`.

**Environment Variables**: Sets preferred `EDITOR` (nvim) and `NAVIGATOR` (brave) via `.sh_common` (for Bash/Zsh) and `.config.fish` (for Fish).

**Automated Setup**: Includes a `setup.sh` script to install dependencies and link configuration files.

---

## Supported Systems

The `setup.sh` script automatically detects the OS and installs dependencies for:

- Debian / Ubuntu and derivatives
- Arch Linux / SteamOS
- openSUSE
- Alpine Linux

Manual installation of dependencies might be required on other systems. Basic aliases and functions should work on most POSIX-compliant shells (Bash/Zsh) and Fish.

---

## Installation

1.  Clone the repository:
    ```sh
    git clone <your-repo-url> ~/dotfiles
    cd ~/dotfiles
    ```
    (Replace `<your-repo-url>` with your actual repository URL)

2.  Run the Setup Script:
    ```sh
    bash .setup.sh
    ```
    The script will first check for sudo access.

    If sudo is available, it will detect your Linux distribution and attempt to install necessary packages (e.g., `fish`, `git`, `build-essential` / `base-devel`, `curl`, `dnsutils` / `bind`, `unzip`, `p7zip-full`, `unrar`, `libarchive-tools` / `bsdtar`, `cabextract`, `zstd`).

    If sudo is unavailable (e.g., on school computers), it will skip package installation and print a warning.

    Crucially, it will then automatically create symbolic links from the files in this repository (like `.bashrc`, `.zshrc`, `.sh_common`, and `.config.fish`) to the correct locations in your home directory (`~` and `~/.config/fish/`).

3.  Restart Your Shell:

    Close and reopen your terminal, or run `source ~/.bashrc` (for Bash) or `source ~/.zshrc` (for Zsh) to apply the new configuration. Fish will pick up the changes on its next launch.

---

## Usage

Once installed and sourced, the aliases and functions are available in your terminal.

Example: `extract archive.zip`

Example: `compile my_program.c`

Example: `ipinfo google.com`

Note: Aliases/functions requiring external commands will only work if those commands were successfully installed by `setup.sh` or are already present on the system.

---

## Structure

`.sh_common`: Contains aliases, functions, exports shared between **Bash and Zsh**.

`.config.fish`: Standalone configuration for the **Fish shell**. Mirrors the aliases, functions, and exports from `.sh_common` using Fish-native syntax.

`.profile`: Read by login shells. Sources `.sh_common` (which sets shared PATH/env vars) and sources `.bashrc` for interactive Bash login shells.

`.bashrc`: Read by interactive non-login Bash shells. Sets Bash-specific options, prompt, completion, sources `.sh_common`, and contains the Fish switch logic.

`.zshrc`: Read by interactive Zsh shells. Sets Zsh-specific options, prompt, completion, history, and sources `.sh_common`.

`.bash_logout`: Read by Bash login shells upon exit.

`.setup.sh`: Script to install dependencies and link the configuration files into place.

---

## Customization

The configuration is split. Settings are **not** automatically shared between Fish and the POSIX-compatible shells.

**Bash/Zsh-Specific**: Add new aliases, functions, or exports compatible with both shells to `.sh_common`. Add Bash-only settings to `.bashrc`.

**Fish-Specific**: Add Fish-native settings to `.config.fish`.

**All Shells**: To add a new alias or function everywhere, you must add the POSIX-compliant version to `.sh_common` **and** the Fish-native version to `.config.fish`.

---

## Troubleshooting

**Command Not Found**: If an alias or function fails, ensure the required package was installed successfully by `.setup.sh` (or install it manually). Check your system's package manager.

**Linking Errors**: Ensure you have write permissions in your home directory. Manually run the `ln -sf ...` commands from `.setup.sh` if needed.

**Fish Switch Loop**: The `.bashrc` includes a check to prevent looping if fish is already the current shell.

**Zsh Completion Issues**: You might need to run `compinit -i` once if you encounter completion problems after a new install.

---

## License

This project is licensed under the [MIT License](LICENCE.txt) - see the LICENSE file for details.