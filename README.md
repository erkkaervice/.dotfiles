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

**Fish Shell Auto-switch**: Automatically attempts to switch to the Fish shell in graphical sessions **(from Bash or Zsh)** if installed.

**Custom Prompt**:
* **Fixed Username**: The username is fixed to **`ervice`** across all shells/systems.
* **Git-Aware Prompts**: Bash, Zsh, and Fish all now feature prompts that display the current Git branch and status. The status indicators appear **only when inside a Git repository** and disappear otherwise.
    * Indicators for unstaged (`U`) and staged (`+`) changes are shown consistently across all three shells.
* **Color-Coded**: The main prompt (`[user@host dir]`) is colored **cyan**, and the Git information is colored **magenta** across all shells.
* **Abbreviated Path Display**: All three shells now display the path relative to the home directory (`~`), with intermediate directories shortened to their first letter (e.g., `~/h/.dotfiles`).
* **Consistent Prompt End**: All shells use `>` as the final prompt character for non-root users.

**Useful Aliases**:
* Colorized output for `ls`, `grep`, `ip`.
* Human-readable `df` and `free`.
* Process management shortcuts (`psa`, `psgrep`, `psmem`, `pscpu`).
* Common Git commands (`addup`, `addall`, `stat`, `pull`, `push`, `gl` for pretty log, etc.).
* Aliases for modern command-line tools: **`cat`** (replaces with `bat`), **`find`** (replaces with `fd`), and **`grep`** (replaces with `ripgrep` or `rg`).
* `code` alias for the VS Code Flatpak.

**Helper Functions**:
* `compile`: Simple C/C++ compilation and execution.
* `extract`: Universal extractor for various archive types.
* **`ipinfo`**: Quick IP/domain information lookup using `curl`. Calling it without an argument shows **your own** IP information.

**Productivity Tools**:
* **`zoxide`**: Smart directory jumping (`z <partial dir name>`).
* **`fzf`**: Interactive fuzzy finder for history (`CTRL-R`), files (`CTRL-T`), and directories (`ALT-C`).

**Maintenance & Setup**:
* **`refresh` alias**: A single command (available in all shells) to pull the latest changes from the Git repository, re-run the setup script, and reload the current shell configuration.
* **SSH Agent Persistence**: Includes a cross-shell compatible script (`.ssh_agent_init`) sourced by all shells to start the `ssh-agent` automatically and add keys, avoiding repetitive passphrase entry in Termux and non-desktop environments.

**PATH Management**: Adds `~/.local/bin`, `~/.cargo/bin`, and Flatpak paths to the `PATH`.

**Environment Variables**: Sets preferred `EDITOR` (nvim) and `NAVIGATOR` (brave) via `.sh_common`. The fixed username **`ervice`** is also set via `export USER` in `.sh_common` for Bash/Zsh compatibility.

**Automated Setup**: Includes a `setup.sh` script to install dependencies and link configuration files.

---

## Supported Systems

The `setup.sh` script automatically detects the OS and installs dependencies for:

- **Termux** (Mobile Linux environment)
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
    The script handles platform detection, including Termux. It checks for sudo access (which is skipped in Termux) and installs all necessary packages (`fish`, `git`, `fzf`, `bat`, `zoxide`, etc.) using the appropriate package manager.

    It then automatically creates symbolic links from the files in this repository (like `.bashrc`, `.zshrc`, `.sh_common`, `.config.fish`, `.ssh_agent_init`) to the correct locations in your home directory (`~` and `~/.config/fish/`).

3.  Restart Your Shell:

    Close and reopen your terminal, or run `source ~/.bashrc` (for Bash) or `source ~/.zshrc` (for Zsh) to apply the new configuration. Fish will pick up the changes on its next launch.

    **Note for Termux Users:** To make Fish your default shell in Termux, you must run `chsh -s fish` once manually after the setup is complete.

---

## Usage

Once installed and sourced, the aliases and functions are available in your terminal.

Example: `refresh` (Updates all dotfiles from the repository and reloads config)
Example: `ipinfo` (Shows your own IP details)
Example: `ipinfo google.com` (Shows IP details for google.com)
Example: `z cool` (Jumps to your most-used directory containing "cool")
Example: `cat my_script.sh` (Shows the script with syntax highlighting via `bat`)

Note: Aliases/functions requiring external commands will only work if those commands were successfully installed by `setup.sh` or are already present on the system.

---

## Structure

`.sh_common`: Contains aliases, functions, exports shared between **Bash and Zsh**. Includes the **`service_user`** function and the `export USER` override.

`.config.fish`: Standalone configuration for the **Fish shell**. Contains a custom `fish_prompt` function to ensure color/user/path/indicator consistency. Mirrors aliases/functions from `.sh_common` using Fish-native syntax.

`.profile`: Read by login shells. Sources `.sh_common` (which sets shared PATH/env vars) and sources `.bashrc` for interactive Bash login shells.

`.bashrc`: Read by interactive non-login Bash shells. Sets Bash-specific options, defines path abbreviation and **custom Git prompt functions**, sources `.sh_common`, and contains the Fish switch logic.

`.zshrc`: Read by interactive Zsh shells. Sets Zsh-specific options, defines path abbreviation function and uses `precmd` to build the **Git-aware prompt**, sources `.sh_common`, and contains the Fish switch logic.

`.bash_logout`: Read by Bash login shells upon exit.

`.setup.sh`: Script to install dependencies and link the configuration files into place, including specialized support for **Termux**.

`.ssh_agent_init`: A cross-shell compatible script sourced by all shells to manage the `ssh-agent` process.

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

**Fish Switch Loop**: The `.bashrc` and `.zshrc` include checks to prevent looping if fish is already the current shell.

**Zsh Completion Issues**: You might need to run `compinit -i` once if you encounter completion problems after a new install.

**Git Passphrase Repetition**: Ensure the `.ssh_agent_init` file is linked and being sourced, and that you entered your passphrase when the script first prompted you. Verify the `SSH_AUTH_SOCK` environment variable is set (`echo $SSH_AUTH_SOCK`).

---

## License

This project is licensed under the [MIT License](LICENSE.txt) - see the LICENSE file for details.
