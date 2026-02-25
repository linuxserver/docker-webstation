#!/usr/bin/env bash

# Default files
if [ ! -f "${HOME}"/.config/lxqt/lxqt.conf ]; then
  mkdir -p "${HOME}"/.config
  cp -r /defaults/config/.config/* "${HOME}"/.config/
fi
if [ ! -f "${HOME}"/Desktop/PCSX2.desktop ]; then
  mkdir -p "${HOME}"/Desktop
  cp /defaults/desktop/* "${HOME}"/Desktop
  sudo cp /defaults/desktop/* /usr/share/applications/
  chmod +x "${HOME}"/Desktop/*.desktop
fi

# Start DE
ulimit -c 0
export XCURSOR_THEME=breeze
export XCURSOR_SIZE=24
export XKB_DEFAULT_LAYOUT=us
export XKB_DEFAULT_RULES=evdev
export WAYLAND_DISPLAY=wayland-1
labwc > /dev/null 2>&1
