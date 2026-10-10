# Dotfiles

Personal configuration files for my Omarchy setup, maintained
to reproduce my desktop environment across my laptop and desktop.

## Repository Structure

- `hypr/` — shared Hyprland configuration.
- `machine-specific/laptop/` — laptop-specific monitor settings.
- `machine-specific/mainPC/` — desktop-specific monitor settings.

## Setup

These files are maintained on top of the default Omarchy installation.
Review the configuration before applying it to another machine.

Monitor configurations are kept separate because the laptop and desktop
use different displays and resolutions.

## Notes

- These dotfiles are intended for personal use.
- Hardware-specific settings should remain in the corresponding
  machine-specific directory.
- Do not commit credentials, tokens, private keys, or other secrets.
