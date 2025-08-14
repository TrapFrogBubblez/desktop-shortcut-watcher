#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------
# Desktop Shortcut Watcher
# - Auto-copies new/updated *.desktop launchers
#   to ~/Desktop and makes them executable
# - Supports Snap, Flatpak, .deb, local apps
# - Skips Hidden/NoDisplay entries
# - Optional blacklist and overwrite policy
# - Logs actions
# ---------------------------------------------

# Default config (overridden by ~/.config/desktop-shortcut-watcher/config.env)
DEST_DIR="${HOME}/Desktop"
LOG_FILE="${HOME}/.local/share/desktop-shortcut-watcher.log"
OVERWRITE="true"             # "true" or "false"
BLACKLIST_REGEX=""           # e.g. "^(org.gnome|com.canonical.)"
INCLUDE_TERMINAL="true"      # allow Terminal=true apps: "true" or "false"

CONFIG_FILE="${HOME}/.config/desktop-shortcut-watcher/config.env"
[ -f "${CONFIG_FILE}" ] && source "${CONFIG_FILE}"

mkdir -p "$(dirname "${LOG_FILE}")" "${DEST_DIR}"

# Use flock to prevent concurrent instances
LOCKFILE="/tmp/desktop-shortcut-watcher.lock"
exec 9>"${LOCKFILE}"
flock -n 9 || { echo "Another instance is running. Exiting."; exit 0; }

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "${LOG_FILE}"; }

# Validate a .desktop file is a visible GUI app
is_visible_app() {
  local f="$1"
  # Hidden or NoDisplay => skip
  if grep -Eiq '^\s*Hidden\s*=\s*true' "$f"; then return 1; fi
  if grep -Eiq '^\s*NoDisplay\s*=\s*true' "$f"; then return 1; fi

  # Respect blacklist
  if [[ -n "${BLACKLIST_REGEX}" ]]; then
    local base; base="$(basename "$f")"
    if [[ "$base" =~ ${BLACKLIST_REGEX} ]]; then return 1; fi
  fi

  # Skip Terminal apps unless allowed
  if [[ "${INCLUDE_TERMINAL}" != "true" ]]; then
    if grep -Eiq '^\s*Terminal\s*=\s*true' "$f"; then return 1; fi
  fi

  # Basic sanity: must have Exec= and Name=
  grep -Eq '^\s*Exec\s*=' "$f" && grep -Eq '^\s*Name\s*=' "$f"
}

copy_launcher() {
  local src="$1"
  local dest_base; dest_base="$(basename "$src")"
  local dest="${DEST_DIR}/${dest_base}"

  # If destination exists and OVERWRITE=false, skip unless content changed
  if [[ -f "$dest" ]]; then
    if [[ "${OVERWRITE}" != "true" ]]; then
      log "Exists (skip due to OVERWRITE=false): ${dest_base}"
      return 0
    fi
    # Overwrite only when content differs
    if cmp -s "$src" "$dest"; then
      log "Up-to-date: ${dest_base}"
      chmod +x "$dest" || true
      return 0
    fi
  fi

  cp -f "$src" "$dest"
  chmod +x "$dest"
  log "Installed/updated shortcut: ${dest_base}"
}

initial_sync() {
  log "Initial sync started."
  while IFS= read -r -d '' f; do
    if is_visible_app "$f"; then copy_launcher "$f"; fi
  done < <(find \
      /usr/share/applications \
      /usr/local/share/applications \
      "${HOME}/.local/share/applications" \
      /var/lib/snapd/desktop/applications \
      /var/lib/flatpak/exports/share/applications \
      2>/dev/null -type f -name '*.desktop' -print0)
  log "Initial sync completed."
}

watch_dirs=(
  "/usr/share/applications"
  "/usr/local/share/applications"
  "${HOME}/.local/share/applications"
  "/var/lib/snapd/desktop/applications"
  "/var/lib/flatpak/exports/share/applications"
)

# Filter to only existing dirs
existing_dirs=()
for d in "${watch_dirs[@]}"; do
  [[ -d "$d" ]] && existing_dirs+=("$d")
done

if [[ ${#existing_dirs[@]} -eq 0 ]]; then
  log "No application directories found to watch. Exiting."
  exit 0
fi

initial_sync

log "Watching for new/updated launchers..."
# -m: monitor continuously; events: create, moved_to, close_write (file finished writing)
inotifywait -m -e create -e moved_to -e close_write --format '%w%f' "${existing_dirs[@]}" \
| while read -r file; do
    [[ "${file}" == *.desktop ]] || continue
    if [[ -f "$file" ]] && is_visible_app "$file"; then
      copy_launcher "$file"
    fi
  done
