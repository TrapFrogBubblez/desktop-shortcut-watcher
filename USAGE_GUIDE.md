# Desktop Shortcut Watcher - Usage Guide

This guide explains how to install, configure, and use **Desktop Shortcut Watcher** on GNOME-based Linux systems.

---

## Installation

The recommended installation method is using the one-liner:

    git clone https://github.com/TrapFrogBubblez/desktop-shortcut-watcher.git ~/desktop-shortcut-watcher-temp && \
    mkdir -p ~/.local/bin ~/.config/desktop-shortcut-watcher ~/.config/systemd/user && \
    cp ~/desktop-shortcut-watcher-temp/desktop-shortcut-watcher.sh ~/.local/bin/ && \
    cp ~/desktop-shortcut-watcher-temp/config.env.example ~/.config/desktop-shortcut-watcher/config.env && \
    cp ~/desktop-shortcut-watcher-temp/desktop-shortcut-watcher.service ~/.config/systemd/user/ && \
    chmod +x ~/.local/bin/desktop-shortcut-watcher.sh && \
    systemctl --user daemon-reload && \
    systemctl --user enable --now desktop-shortcut-watcher.service && \
    rm -rf ~/desktop-shortcut-watcher-temp

## This will:

Clone the repository temporarily.

Create necessary directories for script, config, and service.

Copy files to proper locations.

Make the script executable.

Reload systemd, enable, and start the service.

Remove the temporary clone folder.

## Configuration

Copy the example config (if not already done):

    cp ~/.config/desktop-shortcut-watcher/config.env.example ~/.config/desktop-shortcut-watcher/config.env

Open config.env in your favorite editor and adjust:


### Destination for desktop shortcuts
DEST_DIR="${HOME}/Desktop"

### Log file path
LOG_FILE="${HOME}/.local/share/desktop-shortcut-watcher.log"

### Overwrite existing shortcuts: "true" or "false"
OVERWRITE="true"

### Regex to skip certain apps
BLACKLIST_REGEX=""

### Include Terminal=true apps on Desktop: "true" or "false"
INCLUDE_TERMINAL="true"

Save changes and restart the service to apply:

    systemctl --user restart desktop-shortcut-watcher.service

## Usage

Once installed, the watcher runs automatically in the background.

It monitors .desktop files from Snap, Flatpak, .deb, and local apps.

Any new or updated applications are automatically synced to your Desktop.

Logs can be viewed at:

    cat ~/.local/share/desktop-shortcut-watcher.log

## Service Management

Check service status:

    systemctl --user status desktop-shortcut-watcher.service

Stop the service:

    systemctl --user stop desktop-shortcut-watcher.service

Restart after config changes:

    systemctl --user restart desktop-shortcut-watcher.service

## Troubleshooting

If shortcuts are not appearing, ensure your DEST_DIR is valid and the service is running.

Check the log file for errors.

Make sure the .desktop files you want to monitor are not hidden or marked with NoDisplay=true.