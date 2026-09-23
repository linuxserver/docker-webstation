#!/usr/bin/env bash

# Default files
if [ ! -f "${HOME}"/Desktop/pcsx2-qt.desktop ]; then
  mkdir -p "${HOME}"/Desktop
  cp /defaults/desktop/* "${HOME}"/Desktop
  sudo cp /defaults/desktop/* /usr/share/applications/
  chmod +x "${HOME}"/Desktop/*.desktop
fi

# shadPS4 loop to extract appimage
monitor_shadps4_no_fuse() {
  local SLEEP_TIME="${1:-5}"
  local VERSIONS_DIR="$HOME/.local/share/shadPS4QtLauncher/versions"
  local TARGET_APPIMAGE="Shadps4-sdl.AppImage"
  local INTERNAL_BIN_PATH="usr/bin/shadps4"
  local MARKER_FILE=".nofuse_ready"
  while true; do
    shopt -s nullglob
    for folder in "$VERSIONS_DIR"/*; do
      if [[ -d "$folder" ]]; then
        if [[ -f "$folder/$MARKER_FILE" ]]; then
          continue
        fi
        if [[ -f "$folder/$TARGET_APPIMAGE" ]]; then
          (
            cd "$folder" || exit
            chmod +x "$TARGET_APPIMAGE"
            ./"$TARGET_APPIMAGE" --appimage-extract >/dev/null 2>&1
            if [[ -f "squashfs-root/$INTERNAL_BIN_PATH" ]]; then
              rm "$TARGET_APPIMAGE"
              mv "squashfs-root/$INTERNAL_BIN_PATH" "$TARGET_APPIMAGE"
              rm -rf squashfs-root
              touch "$MARKER_FILE"
            fi
          )
        fi
      fi
    done
    shopt -u nullglob
    sleep "$SLEEP_TIME"
  done
}

monitor_shadps4_no_fuse &

# Start DE
export PATH=$PATH:/usr/games
if [ "${SELKIES_DESKTOP,,}" == "true" ]; then
  exec dbus-launch --exit-with-session /usr/bin/openbox-session > /dev/null 2>&1 &
  OPENBOX_PID=$!
  sleep 1
  selkies-desktop
  kill $OPENBOX_PID
else
  exec dbus-launch --exit-with-session /usr/bin/openbox-session > /dev/null 2>&1
fi
