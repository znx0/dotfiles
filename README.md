# Omarchy Dotfiles

My personal Omarchy desktop setup, managed with Git and a custom installation script. This repository documents and helps reproduce my desktop environment across my main PC and laptop.

The goal is to make my setup easy to replicate while keeping machine-specific configurations separate.

## Preview

This setup is built around:

- **OS:** Omarchy (Arch Linux-based)
- **Window manager:** Hyprland
- **Terminal:** Ghostty
- **Shell:** Fish, with additional environment configuration for `uv`
- **Theming:** Custom Omarchy themes and a personalized shell layout
- **Customization:** Hyprland keybindings, input settings, appearance, startup configuration and monitor layouts

## Features

- Automated application of personal configurations
- Separate monitor configurations for the main PC and laptop
- Installation of custom Omarchy themes and plugins
- Custom Ghostty and Omarchy shell settings
- Personal wallpapers
- Conditional support for Black omARCHy customizations
- Automatic backups of existing configuration files before replacing them
- Dry-run mode to preview planned changes before installation

## Repository Structure

```text
dotfiles/
├── configs/
│   ├── fish/
│   ├── ghostty/
│   ├── hypr/
│   └── omarchy/
├── machine-specific/
│   ├── laptop/
│   └── mainPC/
├── plugins/
│   └── plugins.txt
├── themes/
│   └── themes.txt
├── wallpapers/
│   └── Aether/
├── install.sh
└── README.md
```

### Directory overview

| Directory                  | Purpose                                   |
| -------------------------- | ----------------------------------------- |
| `configs/hypr/`            | Shared Hyprland configuration             |
| `configs/ghostty/`         | Ghostty terminal configuration            |
| `configs/omarchy/`         | Omarchy shell settings and customizations |
| `configs/fish/`            | Additional Fish shell configuration       |
| `machine-specific/mainPC/` | Main PC monitor configuration             |
| `machine-specific/laptop/` | Laptop monitor configuration              |
| `themes/`                  | List of Omarchy themes to install         |
| `plugins/`                 | List of Omarchy plugins to install        |
| `wallpapers/`              | Personal wallpapers                       |
| `install.sh`               | Installation and configuration script     |

## Installation

### Requirements

Before starting, make sure you have:

- A working Omarchy installation
- Git
- Bash
- The `omarchy` command available
- An internet connection to install missing themes and plugins

This repository is designed for Omarchy. It is not a complete operating system installer and does not automatically install every package from my personal system.

### 1. Clone the repository

```bash
git clone https://github.com/znx0/dotfiles.git
cd dotfiles
```

### 2. Preview the installation

**Always start with a dry run.** This shows the planned actions without copying configuration files or installing themes and plugins.

For the main PC:

```bash
./install.sh --dry-run mainPC
```

For the laptop:

```bash
./install.sh --dry-run laptop
```

Review the output and make sure the selected machine matches your intended setup.

### 3. Apply the configuration

After reviewing the dry-run output, run the installer for the machine you want to configure.

Main PC:

```bash
./install.sh mainPC
```

Laptop:

```bash
./install.sh laptop
```

If you omit the machine argument, the installer asks you to choose one interactively:

```bash
./install.sh
```

The script applies the shared configurations, selects the machine-specific monitor layout, installs missing themes and plugins, copies wallpapers and selects the Ayaka theme.

Existing configuration files are backed up under:

```text
~/.local/share/dotfiles-backups/
```

**Important:** Review the script before running it. Applying these configurations may replace your existing settings, and the monitor layouts and other customizations may not suit your hardware.

## Themes and Plugins

The repository tracks external themes and plugins through two text files:

- `themes/themes.txt`
- `plugins/plugins.txt`

Each entry contains a name or plugin identifier and its Git repository URL.

The installer installs missing themes and plugins and enables the listed plugins. Existing installations are reused where possible.

The theme and plugin repositories remain separate projects maintained by their respective authors.

## Machine-specific Configuration

Shared settings are kept under `configs/`, while hardware-dependent settings are stored separately.

For example, the monitor configuration for the main PC is located at:

```text
machine-specific/mainPC/monitors.lua
```

The laptop configuration is located at:

```text
machine-specific/laptop/monitors.lua
```

If you want to use this repository on another computer, review the relevant monitor configuration before applying it. You may need to create a new machine-specific configuration or adjust the existing one.

## Customization

Feel free to adapt the configuration to your own preferences.

- Edit the files under `configs/hypr/` to change Hyprland behavior, keybindings, input settings and appearance.
- Edit `configs/ghostty/config` to customize the terminal.
- Modify `configs/omarchy/` to change the shell layout and other Omarchy settings.
- Add or remove entries in `themes/themes.txt` and `plugins/plugins.txt`.
- Add your own wallpapers under `wallpapers/`.
- Create a separate directory under `machine-specific/` for another computer and add support for it to `install.sh`.

Some customizations are conditional. For example, Black omARCHy-specific files are only applied when the relevant installation is detected. The Fish/uv configuration is only applied when the expected local environment file exists.

## Updating

To update your local copy of the repository:

```bash
cd ~/Github/dotfiles
git pull
```

Review the changes and run the relevant dry run before applying updated configurations.

## Disclaimer

These are my personal dotfiles, developed for my own hardware and workflow. Your experience may differ depending on your hardware, installed packages, Omarchy version and existing configuration.

Always review scripts and configuration files before running them. Back up important data and adapt machine-specific settings before applying this setup.

## License

Check the repository for the applicable license and the licensing terms of external themes, plugins and other projects referenced here.
