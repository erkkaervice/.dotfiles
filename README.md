# dotfiles
Personal shell configuration files for creating a consistent environment across various Linux distributions and shells (Bash & Zsh).

dotfiles provides a unified and portable shell setup for Bash, Zsh, and optionally Fish. It includes colorized output, useful aliases, helper functions, and a setup script that links configuration files automatically.

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

Dual Shell Support: Configuration split for Bash (`.bashrc`) and Zsh (`.zshrc`), sourcing a common file (`.sh_common`) for shared settings.

Fish Shell Auto-switch: Automatically attempts to switch to the Fish shell in graphical sessions if installed.

Custom Prompt: Simple `[\u@\h \W]\$` prompt for Bash (Zsh uses its own, customizable as needed).

Useful Aliases:

Colorized output for `ls`, `grep`, `ip`.

Human-readable `df` and `free`.

Process management shortcuts (`psa`, `psgrep`, `psmem`, `pscpu`).

Common Git commands (`addup`, `addall`, `stat`, `pull`, `push`, etc.).

Helper Functions:

`compile`: Simple C/C++ compilation and execution.

`extract`: Universal extractor for various archive types.

`ipinfo`: Quick IP/domain information lookup using `curl`.

PATH Management: Adds `~/.local/bin` and `~/.cargo/bin` to the PATH via `.profile`.

Environment Variables: Sets preferred `EDITOR`, `NAVIGATOR`, and `TERM` via `.profile`.

Automated Setup: Includes a `setup.sh` script to install dependencies and link configuration files.

---

## Supported Systems

The `setup.sh` script automatically detects the OS and installs dependencies for:

- Debian / Ubuntu and derivatives
- Arch Linux / SteamOS
- openSUSE
- Alpine Linux

Manual installation of dependencies might be required on other systems. Basic aliases and functions should work on most POSIX-compliant shells.

---

## Installation

1. Clone the repository:

`git clone <your-repo-url> ~/dotfiles`

`cd ~/dotfiles`

(Replace `<your-repo-url>` with your actual repository URL)

2. Run the Setup Script:

`bash setup.sh`

The script will first check for sudo access.

If sudo is available, it will detect your Linux distribution and attempt to install necessary packages (`fish`, `git`, `build-essential` / `base-devel`, `curl`, `dnsutils` / `bind`, `unzip`, `p7zip`, `unrar`, etc.).

If sudo is unavailable (e.g., on school computers), it will skip package installation and print a warning.

Crucially, it will then automatically create symbolic links from the files in this repository (like `.bashrc`, `.zshrc`, `.sh_common`) to the correct locations in your home directory (`~`).

3. Restart Your Shell:

Close and reopen your terminal, or run `source ~/.bashrc` (for Bash) or `source ~/.zshrc` (for Zsh) to apply the new configuration.

---

## Usage

Once installed and sourced, the aliases and functions defined in `.sh_common` (and shell-specific files) are available in your terminal.

Example: `extract archive.zip`

Example: `compile my_program.c`

Example: `ipinfo google.com`

Note: Aliases/functions requiring external commands will only work if those commands were successfully installed by `setup.sh` or are already present on the system.

---

## Structure

`.sh_common`: Contains aliases, functions, exports shared between Bash and Zsh.

`.profile`: Read by login shells. Sets PATH, environment variables, sources `.sh_common`, and sources `.bashrc` for interactive Bash login shells.

`.bashrc`: Read by interactive non-login Bash shells. Sets Bash-specific options, prompt, completion, and sources `.sh_common`. Contains Fish switch logic.

`.zshrc`: Read by interactive Zsh shells. Sets Zsh-specific options, prompt, completion, history, and sources `.sh_common`.

`.bash_logout`: Read by Bash login shells upon exit (currently minimal).

`setup.sh`: Script to install dependencies and link the configuration files into place.

---

## Customization

Shared Settings: Add new aliases, functions, or exports compatible with both shells to `.sh_common`.

Bash-Specific: Add Bash-only settings to `.bashrc`.

Zsh-Specific: Add Zsh-only settings to `.zshrc`. Consider using a Zsh framework like Oh My Zsh for more advanced customization (might require adjusting `.zshrc`).

Dotfiles Management: The commented-out `config` alias in `.sh_common` is an example using a bare Git repository to manage dotfiles directly in `$HOME`. You can adapt or remove it based on your workflow.

---

## Troubleshooting

Command Not Found: If an alias or function fails, ensure the required package was installed successfully by `setup.sh` (or install it manually). Check your system's package manager.

Linking Errors: Ensure you have write permissions in your home directory. Manually run the `ln -sf ...` commands from `setup.sh` if needed.

Fish Switch Loop: The `.bashrc` includes a check to prevent looping if fish is already the current shell.

Zsh Completion Issues: You might need to install `zsh-completions` or run `compinit -i` once if you encounter completion problems.

---

## License

This project is licensed under the [MIT License](LICENSE.txt) - see the LICENSE file for details.
