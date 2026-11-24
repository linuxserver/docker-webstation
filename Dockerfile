FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BROKER_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

ENV TITLE="Webstation" \
    NO_FULL=true \
    SELKIES_RATE_CONTROL_MODE="cbr,crf" \
    SELKIES_USE_PAINT_OVER_QUALITY=true \
    PIXELFLUX_WAYLAND=true \
    SUBFOLDER="/streaming/" \
    DOOMWADDIR="/config" 

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/webstation-logo.png && \
  echo "**** install base packages ****" && \
  add-apt-repository ppa:xtradeb/apps && \
  apt-get update && \
  add-apt-repository ppa:xtradeb/play && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    chromium \
    darkplaces \
    dbus-x11 \
    eduke32 \
    eduke32-shareware-episode \
    featherpad \
    gnome-keyring \
    jstest-gtk \
    libavcodec62 \
    libenet7 \
    libfaad2 \
    libgtk-3-0t64 \
    libgtk-3-common \
    liblz4-1 \
    libopenal1 \
    libopus0 \
    libpipewire-0.3 \
    libqt6multimedia6 \
    libqt6svg6 \
    libsdl2-2.0-0 \
    libshaderc1 \
    libssl3t64 \
    libusb-1.0-0 \
    libxcb-cursor0 \
    libzstd1 \
    nodejs \
    p7zip-full \
    papirus-icon-theme \
    pcmanfm-qt \
    python3 \
    python3-dbus \
    python3-gi \
    python3-pip \
    qt6-wayland \
    qemu-utils \
    unrar \
    zenity && \
  echo "**** chromium wrapper ****" && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-browser && \
  echo "**** install pcsx2 ****" && \
  add-apt-repository ppa:pcsx2-team/pcsx2-daily && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    pcsx2 && \
  echo "**** install ppsspp ****" && \
  add-apt-repository ppa:xuzhen666/ppsspp && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    ppsspp && \
  echo "**** install mame ****" && \
  add-apt-repository ppa:c.falco/mame && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    mame && \
  echo "**** install retroarch ****" && \
  add-apt-repository ppa:libretro/stable && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    libretro-core-info \
    retroarch \
    retroarch-assets \
    unzip \
    xz-utils && \
  curl -o \
    /tmp/autoconfig.zip \
    https://buildbot.libretro.com/assets/frontend/autoconfig.zip && \
  mkdir -p /usr/share/libretro/autoconfig && \
  unzip \
    /tmp/autoconfig.zip \
    -d /usr/share/libretro/autoconfig && \
  echo "**** install azahar ****" && \
  AZAHAR_URL=$(curl -sX GET "https://api.github.com/repos/azahar-emu/azahar/releases/latest" \
    | jq -er '.assets[] | select(.name == "azahar.AppImage") | .browser_download_url') && \
  curl -o \
    /tmp/azahar.app -L \
    "${AZAHAR_URL}" && \
  cd /tmp && \
  chmod +x azahar.app && \
  ./azahar.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/azahar && \
  echo "**** install cemu ****" && \
  mkdir /tmp/cemu && \
  CEMU_URL=$(curl -sX GET "https://api.github.com/repos/cemu-project/Cemu/releases/latest" \
    | jq -er '.assets[] | select(.name | endswith("-x86_64.AppImage")) | .browser_download_url') && \
  curl -o \
    /tmp/cemu/cemu.app -L \
    "${CEMU_URL}" && \
  cd /tmp/cemu && \
  chmod +x cemu.app && \
  ./cemu.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/cemu && \
  rm -f \
    /opt/cemu/usr/lib/libudev.so* && \
  ln -s \
    /opt/cemu/usr/bin/Cemu \
    /usr/bin/Cemu && \
  mkdir -p /usr/share/icons/hicolor/128x128/apps && \
  ln -s \
    /opt/cemu/usr/share/icons/hicolor/128x128/apps/info.cemu.Cemu.png \
    /usr/share/icons/hicolor/128x128/apps/info.cemu.Cemu.png && \
  echo "**** install dolphin ****" && \
  mkdir /tmp/dolphin && \
  for DOLPHIN_TAG in $(curl -sX GET "https://api.github.com/repos/dolphin-emu/dolphin/tags?per_page=50" \
    | jq -er '[.[].name | select(test("^[0-9]{4}[a-z]?$"))] | sort | reverse | .[]'); do \
    if curl -sfIL -o /dev/null "https://dl.dolphin-emu.org/releases/${DOLPHIN_TAG}/dolphin-${DOLPHIN_TAG}-x64.AppImage"; then \
      DOLPHIN_VERSION="${DOLPHIN_TAG}"; \
      break; \
    fi; \
  done && \
  curl -fo \
    /tmp/dolphin/dolphin.app -L \
    "https://dl.dolphin-emu.org/releases/${DOLPHIN_VERSION}/dolphin-${DOLPHIN_VERSION}-x64.AppImage" && \
  cd /tmp/dolphin && \
  chmod +x dolphin.app && \
  ./dolphin.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/dolphin && \
  rm -f \
    /opt/dolphin/usr/lib/libudev.so* && \
  ln -s \
    /opt/dolphin/usr/bin/dolphin-emu \
    /usr/local/bin/dolphin-emu && \
  mkdir -p /usr/share/icons/hicolor/scalable/apps && \
  ln -s \
    /opt/dolphin/usr/share/icons/hicolor/scalable/apps/dolphin-emu.svg \
    /usr/share/icons/hicolor/scalable/apps/dolphin-emu.svg && \
  echo "**** install dosbox ****" && \
  if [ -z ${DSTAGING_VERSION+x} ]; then \
    DSTAGING_VERSION=$(curl -sX GET "https://api.github.com/repos/dosbox-staging/dosbox-staging/releases/latest" \
    | jq -er '.tag_name'); \
  fi && \
  curl -o \
    /tmp/dosbox.tar.xz -L \
    "https://github.com/dosbox-staging/dosbox-staging/releases/download/${DSTAGING_VERSION}/dosbox-staging-linux-x86_64-${DSTAGING_VERSION}.tar.xz" && \
  mkdir /opt/dosbox && \
  tar xf \
    /tmp/dosbox.tar.xz -C \
    /opt/dosbox --strip-components=1 && \
  echo "**** install duckstation ****" && \
  DUCKSTATION_URL=$(curl -sX GET "https://api.github.com/repos/stenzek/duckstation/releases/latest" \
    | jq -er '.assets[] | select(.name == "DuckStation-x64.AppImage") | .browser_download_url') && \
  curl -o \
    /tmp/duck.app -L \
    "${DUCKSTATION_URL}" && \
  cd /tmp && \
  chmod +x duck.app && \
  ./duck.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/duckstation && \
  ln -s \
    /opt/duckstation/AppRun \
    /usr/bin/duckstation-qt && \
  echo "**** install eden ****" && \
  mkdir /tmp/eden && \
  EDEN_URL=$(curl -sX GET "https://git.eden-emu.dev/api/v1/repos/eden-emu/eden/releases/latest" \
    | jq -er '.assets[] | select(.name | test("^Eden-Linux-.*-amd64-clang-pgo\\.AppImage$")) | .browser_download_url') && \
  curl -o \
    /tmp/eden/eden.app -L \
    "${EDEN_URL}" && \
  cd /tmp/eden && \
  chmod +x eden.app && \
  ./eden.app --appimage-extract && \
  mv \
    AppDir \
    /opt/eden && \
  rm -f \
    /opt/eden/shared/lib/libudev.so* && \
  ln -s \
    /opt/eden/bin/eden \
    /usr/bin/eden && \
  ln -s \
    /opt/eden/dev.eden_emu.eden.svg \
    /usr/share/icons/hicolor/scalable/apps/dev.eden_emu.eden.svg && \
  echo "**** install lichii ****" && \
  mkdir /tmp/lichii && \
  LICHII_URL=$(curl -sX GET "https://api.github.com/repos/zortos293/Lichii/releases" \
    | jq -er 'first(.[].assets[] | select(.name == "lichii-linux-x86_64-pgo.AppImage") | .browser_download_url)') && \
  curl -o \
    /tmp/lichii/lichii.app -L \
    "${LICHII_URL}" && \
  cd /tmp/lichii && \
  chmod +x lichii.app && \
  ./lichii.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/lichii && \
  ln -s \
    /opt/lichii/AppRun \
    /usr/bin/lichii && \
  echo "**** install flycast ****" && \
  FLYCAST_URL=$(curl -sX GET "https://api.github.com/repos/flyinghead/flycast/releases/latest" \
    | jq -er '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url') && \
  curl -o \
    /tmp/fly.app -L \
    "${FLYCAST_URL}" && \
  cd /tmp && \
  chmod +x fly.app && \
  ./fly.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/flycast && \
  ln -s \
    /opt/flycast/AppRun \
    /usr/bin/flycast && \
  echo "**** install gzdoom ****" && \
  GZDOOM_URL=$(curl -sX GET "https://api.github.com/repos/ZDoom/gzdoom/releases/latest" \
    | jq -er '.assets[] | select(.name | endswith("_amd64.deb")) | .browser_download_url') && \
  curl -o \
    /tmp/gzdoom.deb -L \
    "${GZDOOM_URL}" && \
  cd /tmp && \
  apt install -y \
    ./gzdoom.deb && \
  FREEDOOM_URL=$(curl -sX GET "https://api.github.com/repos/freedoom/freedoom/releases/latest" \
    | jq -er '.assets[] | select(.name | startswith("freedoom-") and endswith(".zip")) | .browser_download_url') && \
  curl -o \
    /tmp/freedoom.zip -L \
    "${FREEDOOM_URL}" && \
  unzip freedoom.zip && \
  mv \
    freedoom*/freedoom1.wad \
    /defaults/ && \
  echo "**** quake shareware ****" && \
  curl -o \
    /pak0.pak -L \
    https://github.com/pweil-/origin-quake/raw/refs/heads/master/id1/pak0.pak && \
  echo "**** install melonds ****" && \
  MELONDS_VERSION=$(curl -sX GET "https://api.github.com/repos/melonDS-emu/melonDS/releases/latest" \
    | jq -er '.tag_name') && \
  curl -o \
    /tmp/melon.zip -L \
    "https://github.com/melonDS-emu/melonDS/releases/download/${MELONDS_VERSION}/melonDS-${MELONDS_VERSION}-ubuntu-x86_64.zip" && \
  cd /tmp && \
  unzip melon.zip && \
  mv \
    melonDS \
    /usr/bin && \
  echo "**** install xenia-edge ****" && \
  XENIA_VERSION=$(curl -sX GET "https://api.github.com/repos/has207/xenia-edge/releases/latest" \
    | jq -er '.tag_name') && \
  curl -o \
    /tmp/xenia.app -L \
    "https://github.com/has207/xenia-edge/releases/download/${XENIA_VERSION}/xenia_edge_linux.AppImage" && \
  cd /tmp && \
  chmod +x xenia.app && \
  ./xenia.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/xenia && \
  ln -s \
    /opt/xenia/AppRun \
    /usr/bin/xenia && \
  echo "**** install modrinth ****" && \
  MODRINTH_VERSION=$(curl -sX GET "https://api.github.com/repos/modrinth/code/releases/latest" \
    | jq -er '.tag_name') && \
  curl -o \
    /tmp/modrinth.deb -L \
    "https://launcher-files.modrinth.com/versions/$(echo ${MODRINTH_VERSION}| sed 's/^v//g')/linux/Modrinth%20App_$(echo ${MODRINTH_VERSION}| sed 's/^v//g')_amd64.deb" && \
  apt-get install -y \
    /tmp/modrinth.deb && \
  echo "**** install rpcs3 ****" && \
  RPCS3_URL=$(curl -sX GET "https://api.github.com/repos/RPCS3/rpcs3-binaries-linux/releases/latest" \
    | jq -er '.assets[] | select(.name | endswith("_linux64.AppImage")) | .browser_download_url') && \
  curl -o \
    /tmp/rpcs3.app -L \
    "${RPCS3_URL}" && \
  cd /tmp && \
  chmod +x rpcs3.app && \
  ./rpcs3.app --appimage-extract && \
  mv \
    AppDir \
    /opt/rpcs3 && \
  echo "**** install scummvm ****" && \
  apt-get install -y \
    scummvm && \
  echo "**** install xemu ****" && \
  mkdir /tmp/xemu && \
  XEMU_URL=$(curl -sX GET "https://api.github.com/repos/xemu-project/xemu/releases" \
    | jq -er 'first(.[].assets[] | select(.name | endswith("-x86_64.AppImage") and (contains("dbg") | not)) | .browser_download_url)') && \
  curl -o \
    /tmp/xemu/xemu.app -L \
    "${XEMU_URL}" && \
  cd /tmp/xemu && \
  chmod +x xemu.app && \
  ./xemu.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/xemu && \
  ln -s \
    /opt/xemu/AppRun \
    /usr/bin/xemu && \
  echo "**** install xbased ****" && \
  mkdir /tmp/xbased && \
  XBASED_URL=$(curl -sX GET "https://api.github.com/repos/crazyriddler/xbased/releases/latest" \
    | jq -er '.assets[] | select(.name | endswith("-x86_64.AppImage")) | .browser_download_url') && \
  curl -o \
    /tmp/xbased/xbased.app -L \
    "${XBASED_URL}" && \
  cd /tmp/xbased && \
  chmod +x xbased.app && \
  ./xbased.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/xbased && \
  ln -s \
    /opt/xbased/AppRun \
    /usr/bin/xbased && \
 echo "**** install esde ****" && \
  mkdir /tmp/esde && \
  curl -o \
    /tmp/esde/esde.app -L \
    "https://gitlab.com/es-de/emulationstation-de/-/package_files/288156961/download" && \
  cd /tmp/esde && \
  chmod +x esde.app && \
  ./esde.app --appimage-extract && \
  mv \
    AppDir \
    /opt/esde && \
  echo "**** install shadps4qt ****" && \
  mkdir /tmp/shadps4 && \
  SHADPS4_VERSION=$(curl -sX GET "https://api.github.com/repos/shadps4-emu/shadps4-qtlauncher/releases" \
    | jq -er '.[0].tag_name') && \
  SHORT_VERSION=$(echo "$SHADPS4_VERSION" | sed 's/shadPS4QtLauncher-//' | cut -c 1-18) && \
  curl -o \
    /tmp/shadps4/shad.zip -L \
    "https://github.com/shadps4-emu/shadps4-qtlauncher/releases/download/${SHADPS4_VERSION}/shadPS4QtLauncher-linux-qt-${SHORT_VERSION}.zip" && \
  cd /tmp/shadps4 && \
  unzip shad.zip && \
  chmod +x shadPS4QtLauncher-qt.AppImage && \
  ./shadPS4QtLauncher-qt.AppImage --appimage-extract && \
  mv \
    squashfs-root \
    /opt/shadps4 && \
  PKG_URL=$(curl -sX GET "https://api.github.com/repos/AzaharPlus/shadPS4Plus/releases/latest" \
    | jq -er '.assets[] | select(.name | endswith("-linux.zip")) | .browser_download_url') && \
  curl -o \
    /tmp/pkg.zip -L \
    "${PKG_URL}" && \
  cd /tmp && \
  unzip pkg.zip && \
  cd ShadPs4Plus-PkgExtractor* && \
  chmod +x pkg_extractor.AppImage && \
  ./pkg_extractor.AppImage --appimage-extract && \
  mv \
    squashfs-root/usr/bin/pkg_extractor \
    /usr/local/bin/ && \
  echo "**** install flips ****" && \
  mkdir /tmp/flips && \
  FLIPS_URL=$(curl -sLX GET "https://api.github.com/repos/Alcaro/Flips/releases/latest" \
    | jq -er '.assets[] | select(.name | endswith("-linux.zip")) | .browser_download_url') && \
  curl -o \
    /tmp/flips/flips.zip -L \
    "${FLIPS_URL}" && \
  cd /tmp/flips && \
  unzip flips.zip && \
  mv \
    flips \
    /usr/local/bin/ && \
  chmod +x \
    /usr/local/bin/flips && \
  echo "**** install broker ****" && \
  mkdir -p /tmp/broker && \
  if [ -z ${BROKER_RELEASE+x} ]; then \
    BROKER_RELEASE=$(curl -sX GET "https://api.github.com/repos/romm-streaming/romm-broker/releases/latest" \
    | jq -er '.tag_name'); \
  fi && \
  curl -o \
    /tmp/broker.tar.gz -L \
    "https://github.com/romm-streaming/romm-broker/archive/${BROKER_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/broker.tar.gz -C \
    /tmp/broker/ --strip-components=1 && \
  pip install /tmp/broker --break-system-packages && \
  cd /tmp/broker/frontend && \
  npm install && \
  SUBFOLDER=/streaming/ npm run build && \
  mkdir -p /usr/share/webstation-broker && \
  cp -r dist /usr/share/webstation-broker/www && \
  echo "**** cleanup ****" && \
  find /opt/* -type d -exec chmod 755 {} + && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /config/.npm \
    /tmp/* \
    /usr/share/applications/debian-uxterm.desktop \
    /usr/share/applications/debian-xterm.desktop \
    /usr/share/applications/foot-server.desktop \
    /usr/share/applications/footclient.desktop \
    /usr/share/applications/pcmanfm-qt-desktop-pref.desktop \
    /usr/share/applications/st.desktop \
    /var/lib/apt/lists/* \
    /var/tmp/* 

# add local files
COPY /root /
COPY /root/defaults/desktop/ /usr/share/applications/

# ports and volumes
EXPOSE 3001
VOLUME /config
