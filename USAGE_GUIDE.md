# Desktop Shortcut Watcher - Usage Guide

**Desktop Shortcut Watcher** automatically detects new or updated applications on GNOME-based Linux systems and creates corresponding Desktop shortcuts for visible GUI apps. It works with Snap, Flatpak, `.deb`, and local applications, keeping your Desktop organized and up-to-date.

This guide covers installation, configuration, usage, advanced options, troubleshooting, and best practices to ensure a reliable experience.

---

## Table of Contents

1. [Installation](#installation)  
2. [Configuration](#configuration)  
3. [Usage](#usage)  
4. [Service Management](#service-management)  
5. [Advanced Options](#advanced-options)  
6. [Troubleshooting](#troubleshooting)  
7. [Edge Cases and Notes](#edge-cases-and-notes)  
8. [FAQ](#faq)  

---

## Installation

The recommended installation method is a single, robust one-liner:

    git clone https://github.com/TrapFrogBubblez/desktop-shortcut-watcher.git ~/desktop-shortcut-watcher-temp && \
    mkdir -p ~/.local/bin ~/.config/desktop-shortcut-watcher ~/.config/systemd/user && \
    cp ~/desktop-shortcut-watcher-temp/desktop-shortcut-watcher.sh ~/.local/bin/ && \
    cp ~/desktop-shortcut-watcher-temp/config.env.example ~/.config/desktop-shortcut-watcher/config.env && \
    cp ~/desktop-shortcut-watcher-temp/desktop-shortcut-watcher.service ~/.config/systemd/user/ && \
    chmod +x ~/.local/bin/desktop-shortcut-watcher.sh && \
    systemctl --user daemon-reload && \
    systemctl --user enable --now desktop-shortcut-watcher.service && \
    rm -rf ~/desktop-shortcut-watcher-temp


## What this does:

Clones the repository to a temporary location.

Creates required directories for binaries, configuration, and systemd service.

Copies the main script, configuration template, and systemd service file to proper locations.

Sets the script as executable.

Reloads systemd user units and enables the watcher service to start automatically at login.

Cleans up temporary files.

Tip: Run the installation as a regular user, not root, to ensure proper access to your Desktop and $HOME directories.

## Configuration

The watcher is configured via config.env, located at:

    ~/.config/desktop-shortcut-watcher/config.env

Copy the example file if you skipped the installation step:

    cp ~/.config/desktop-shortcut-watcher/config.env.example ~/.config/desktop-shortcut-watcher/config.env

Open config.env with your favorite text editor:

    nano ~/.config/desktop-shortcut-watcher/config.env

# Configuration Parameters
##  Parameter	        Description	Example / Default
    DEST_DIR	        Destination folder for Desktop shortcuts	${HOME}/Desktop
    LOG_FILE	        Path to store watcher logs	${HOME}/.local/share/desktop-shortcut-watcher.log
    OVERWRITE	        Whether to overwrite existing shortcuts (true or false)	true
    BLACKLIST_REGEX	    Regex pattern to exclude certain apps	`^(org.gnome
    INCLUDE_TERMINAL	Include Terminal-enabled apps (true or false)	true

After editing, save the file and restart the service:

    systemctl --user restart desktop-shortcut-watcher.service

# Usage

Once installed, the watcher runs continuously in the background as a systemd user service.

Automatically detects and copies .desktop files for newly installed or updated apps.

Skips hidden apps or those marked NoDisplay=true.

Logs all actions to the file specified by LOG_FILE.

## View Logs

    cat ~/.local/share/desktop-shortcut-watcher.log

## Manual Sync

If you make manual changes to .desktop files and want to force a sync:

    ~/.local/bin/desktop-shortcut-watcher.sh

Note: Running manually does not interfere with the systemd service.

## Service Management
Check Status

    systemctl --user status desktop-shortcut-watcher.service

Stop Service

    systemctl --user stop desktop-shortcut-watcher.service

Restart Service

    systemctl --user restart desktop-shortcut-watcher.service

## Enable/Disable Auto Start

Enable auto-start at login:

    systemctl --user enable desktop-shortcut-watcher.service

Disable auto-start:

    systemctl --user disable desktop-shortcut-watcher.service

## Advanced Options
## Custom Directories

You can monitor additional directories by updating the script or adding multiple .desktop paths in config.env.
Blacklist/Whitelist

Blacklist: Prevent specific apps from appearing on Desktop via regex (BLACKLIST_REGEX).

Whitelist: Only allow specific apps by editing the script logic or using a stricter regex.

## Overwrite Policy

true → Existing shortcuts are replaced automatically.

false → Existing shortcuts remain untouched; new apps only added.

## Terminal-enabled Apps

Apps that require a terminal to launch can be optionally included or excluded (INCLUDE_TERMINAL).
Troubleshooting

Shortcuts not appearing

-Confirm DEST_DIR exists and is writable.

-Verify the service is running: systemctl --user status desktop-shortcut-watcher.service.

-Check logs for errors: cat ~/.local/share/desktop-shortcut-watcher.log.

## Permissions issues

Ensure .desktop files are readable.

Ensure the script has execute permissions (chmod +x ~/.local/bin/desktop-shortcut-watcher.sh).

## Service not starting

Reload systemd user units: systemctl --user daemon-reload.

Start manually: systemctl --user start desktop-shortcut-watcher.service.

## Duplicate shortcuts

Check OVERWRITE setting.

Inspect BLACKLIST_REGEX for unintended matches.

## Hidden or NoDisplay apps appearing/disappearing incorrectly

Verify .desktop file contains NoDisplay=true or Hidden=true.

Check for updates in Snap/Flatpak .desktop file locations.

## Logs filling disk

Log rotation is recommended.

Manually rotate logs:

    mv ~/.local/share/desktop-shortcut-watcher.log ~/.local/share/desktop-shortcut-watcher.log.old
    systemctl --user restart desktop-shortcut-watcher.service

## Edge Cases and Notes

Flatpak apps may store .desktop files under ~/.local/share/flatpak/exports/share/applications.

Snap apps store files under /var/lib/snapd/desktop/applications.

Updates from Snap/Flatpak might replace .desktop files; the watcher will sync automatically.

Some apps may require a session restart for icons to appear correctly.

Desktop environments other than GNOME may handle .desktop files differently; functionality is not guaranteed outside GNOME-based systems.

# FAQ

Q: Can I run this as root?
A: No. The script is intended to run per-user to manage the Desktop of that user.

Q: Can I monitor multiple user accounts?
A: Yes, but you must run a separate service for each user.

Q: Can I change the Desktop icon style or order?
A: No, the watcher only creates .desktop files. Icon arrangement depends on the desktop environment.

Q: Is it safe to enable INCLUDE_TERMINAL=true?
A: Yes. It only copies .desktop files for apps that require a terminal to launch.