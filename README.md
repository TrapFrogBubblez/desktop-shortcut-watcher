# Desktop Shortcut Watcher

![Release](https://img.shields.io/github/v/release/TrapFrogBubblez/desktop-shortcut-watcher)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![GitHub stars](https://img.shields.io/github/stars/TrapFrogBubblez/desktop-shortcut-watcher?style=social)
![GitHub issues](https://img.shields.io/github/issues/TrapFrogBubblez/desktop-shortcut-watcher)
![GitHub forks](https://img.shields.io/github/forks/TrapFrogBubblez/desktop-shortcut-watcher?style=social)
![Downloads](https://img.shields.io/github/downloads/TrapFrogBubblez/desktop-shortcut-watcher/total)
![Last commit](https://img.shields.io/github/last-commit/TrapFrogBubblez/desktop-shortcut-watcher)
![Linux](https://img.shields.io/badge/OS-Linux-yellow)
![Ubuntu](https://img.shields.io/badge/OS-Ubuntu-orange)


Automatically create Desktop shortcuts for new or updated applications on GNOME-based Linux systems. This tool monitors `.desktop` launcher files from Snap, Flatpak, `.deb`, and local installations, ensuring your Desktop always has shortcuts for visible GUI apps.

---

## Features

- Monitors `.desktop` files in Snap, Flatpak, `.deb`, and local app directories.
- Skips hidden or `NoDisplay` apps.
- Optional blacklist to skip specific apps.
- Overwrite policy for existing desktop shortcuts.
- Logs all actions to a user-specific log file.
- Runs as a persistent **systemd user service**, starting automatically on login.

---

## Installation

The easiest way to install and start the watcher is with the following one-liner (copy-paste into your terminal):

    git clone https://github.com/TrapFrogBubblez/desktop-shortcut-watcher.git ~/desktop-shortcut-watcher-temp && \
    mkdir -p ~/.local/bin ~/.config/desktop-shortcut-watcher ~/.config/systemd/user && \
    cp ~/desktop-shortcut-watcher-temp/desktop-shortcut-watcher.sh ~/.local/bin/ && \
    cp ~/desktop-shortcut-watcher-temp/config.env.example ~/.config/desktop-shortcut-watcher/config.env && \
    cp ~/desktop-shortcut-watcher-temp/desktop-shortcut-watcher.service ~/.config/systemd/user/ && \
    chmod +x ~/.local/bin/desktop-shortcut-watcher.sh && \
    systemctl --user daemon-reload && \
    systemctl --user enable --now desktop-shortcut-watcher.service && \
    rm -rf ~/desktop-shortcut-watcher-temp

### This will:

Clone the repository to a temporary folder.

Create necessary directories for the script, configuration, and systemd service.

Copy the script, config example, and service to their proper locations.

Make the script executable.

Reload systemd user units, enable the service, and start it immediately.

Remove the temporary clone folder.

## Configuration

By default, the watcher uses sane defaults. To customize:

Copy the example config (done automatically by the one-liner):

    cp ~/.config/desktop-shortcut-watcher/config.env.example ~/.config/desktop-shortcut-watcher/config.env

# Edit config.env to adjust:

## Destination for desktop shortcuts
DEST_DIR="${HOME}/Desktop"

## Log file path
LOG_FILE="${HOME}/.local/share/desktop-shortcut-watcher.log"

## Overwrite existing shortcuts: "true" or "false"
OVERWRITE="true"

## Regex to skip certain apps, e.g., "^(org.gnome|com.canonical)"
BLACKLIST_REGEX=""

## Include Terminal=true apps on Desktop: "true" or "false"
INCLUDE_TERMINAL="true"

# Usage

Once installed:

The watcher automatically syncs existing .desktop files to your Desktop.

New or updated applications will be copied automatically.

Logs are stored in the path specified by LOG_FILE (default: ~/.local/share/desktop-shortcut-watcher.log).

The service runs continuously in the background as a systemd user service.

To check the service status:

    systemctl --user status desktop-shortcut-watcher.service

To stop the watcher:

    systemctl --user stop desktop-shortcut-watcher.service

To restart after configuration changes:

    systemctl --user restart desktop-shortcut-watcher.service

# License:

This project is licensed under the MIT License.