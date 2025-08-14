# Desktop Shortcut Watcher

Automatically creates Desktop shortcuts for new/updated applications on GNOME.

## Features
- Monitors .desktop files in Snap, Flatpak, .deb, and local installs
- Skips Hidden/NoDisplay apps
- Optional blacklist and overwrite policy
- Logs all actions
- Runs as a systemd user service

## Installation
Copy the script to ~/.local/bin, config to ~/.config/desktop-shortcut-watcher, and service to ~/.config/systemd/user. Then enable the service with systemctl --user.

## Configuration
Copy `config.env.example` to `~/.config/desktop-shortcut-watcher/config.env` and edit as needed.

## License
MIT
