FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="Webstation" \
    NO_FULL=true \
    PIXELFLUX_WAYLAND=true \
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
    eduke32 \
    eduke32-shareware-episode \
    featherpad \
    gnome-keyring \
    ibsdl2-2.0-0 \
    jstest-gtk \
    libenet7 \
    libfaad2 \
    libgtk-3-common \
    libopenal1 \
    libqt6multimedia6 \
    libqt6svg6 \
    libqt6svgwidgets6 \
    libqt6widgets6 \
    libusb-1.0-0 \
    lxqt-archiver \
    lxqt-core \
    p7zip-full \
    p7zip-rar \
    papirus-icon-theme && \
  echo "**** lxqt tweaks ****" && \
  sed -i \
    's#^Exec=.*#Exec=/usr/local/bin/wrapped-chromium#g' \
    /usr/share/applications/chromium.desktop && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-browser && \
  echo "**** install dolphin ****" && \
  add-apt-repository ppa:ubuntuhandbook1/dolphin-emu && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    dolphin-emu && \
  echo "**** install pcsx2 ****" && \
  add-apt-repository ppa:pcsx2-team/pcsx2-daily && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    pcsx2-stable && \
  setcap -r /usr/bin/pcsx2-qt && \
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
  mv \
    /usr/bin/retroarch \
    /usr/bin/retroarch-real && \
  echo "**** install dosbox ****" && \
  if [ -z ${DSTAGING_VERSION+x} ]; then \
    DSTAGING_VERSION=$(curl -sX GET "https://api.github.com/repos/dosbox-staging/dosbox-staging/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/dosbox.tar.xz -L \
    "https://github.com/dosbox-staging/dosbox-staging/releases/download/${DSTAGING_VERSION}/dosbox-staging-linux-x86_64-${DSTAGING_VERSION}.tar.xz" && \
  mkdir /opt/dosbox && \
  tar xf \
    /tmp/dosbox.tar.xz -C \
    /opt/dosbox --strip-components=1 && \
  echo "**** install duckstation ****" && \
  DOSBOX_URL=$(curl -sX GET "https://api.github.com/repos/stenzek/duckstation/releases/latest" \
    | awk -F '(": "|")' '/browser.*x64.AppImage/ {print $3}') && \
  curl -o \
    /tmp/duck.app -L \
    "${DOSBOX_URL}" && \
  cd /tmp && \
  chmod +x duck.app && \
  ./duck.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/duckstation && \
  echo "**** install eden ****" && \
  if [ -z ${EDEN_VERSION+x} ]; then \
    EDEN_VERSION=$(curl -sX GET "https://api.github.com/repos/eden-emulator/Releases/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/eden.deb -L \
    "https://github.com/eden-emulator/Releases/releases/download/${EDEN_VERSION}/Eden-Ubuntu-24.04-${EDEN_VERSION}-amd64.deb" && \
  apt-get install -y \
    /tmp/eden.deb && \
  echo "**** install flycast ****" && \
  FLYCAST_URL=$(curl -sX GET "https://api.github.com/repos/flyinghead/flycast/releases/latest" \
    | awk -F '(": "|")' '/browser.*.AppImage/ {print $3}') && \
  curl -o \
    /tmp/fly.app -L \
    "${FLYCAST_URL}" && \
  cd /tmp && \
  chmod +x fly.app && \
  ./fly.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/flycast && \
  echo "**** install gzdoom ****" && \
  GZDOOM_URL=$(curl -sX GET "https://api.github.com/repos/ZDoom/gzdoom/releases/latest" \
    | awk -F '(": "|")' '/browser.*amd64.deb/ {print $3}') && \
  curl -o \
    /tmp/gzdoom.deb -L \
    "${GZDOOM_URL}" && \
  cd /tmp && \
  apt install -y \
    ./gzdoom.deb && \
  FREEDOOM_URL=$(curl -sX GET "https://api.github.com/repos/freedoom/freedoom/releases/latest" \
    | awk -F '(": "|")' '/browser.*freedoom-.*.zip/ && !/.*sig/ {print $3}') && \
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
    | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  curl -o \
    /tmp/melon.zip -L \
    "https://github.com/melonDS-emu/melonDS/releases/download/${MELONDS_VERSION}/melonDS-${MELONDS_VERSION}-ubuntu-x86_64.zip" && \
  cd /tmp && \
  unzip melon.zip && \
  mv \
    melonDS \
    /usr/bin && \
  echo "**** install modrinth ****" && \
  MODRINTH_VERSION=$(curl -sX GET "https://api.github.com/repos/modrinth/code/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  curl -o \
    /tmp/modrinth.deb -L \
    "https://launcher-files.modrinth.com/versions/$(echo ${MODRINTH_VERSION}| sed 's/^v//g')/linux/Modrinth%20App_$(echo ${MODRINTH_VERSION}| sed 's/^v//g')_amd64.deb" && \
  apt-get install -y \
    /tmp/modrinth.deb && \
  echo "**** install rpcs3 ****" && \
  RPCS3_URL=$(curl -sX GET "https://api.github.com/repos/RPCS3/rpcs3-binaries-linux/releases/latest" \
    | awk -F '(": "|")' '/browser.*AppImage/ {print $3}') && \
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
  SCUMMVM_VERSION=$(curl -s https://downloads.scummvm.org/frs/scummvm/ \
    | awk -F'(<a href="|/">)' '{print $2}'| grep -B 1 'daily' |head -n1) && \
  curl -o \
    /tmp/scummvm.deb -L \
    "https://downloads.scummvm.org/frs/scummvm/${SCUMMVM_VERSION}/scummvm_${SCUMMVM_VERSION}-1_ubuntu24_04_amd64.deb" && \
  apt-get update && \
  apt-get install -y \
    /tmp/scummvm.deb && \
  echo "**** install xemu ****" && \
  mkdir /tmp/xemu && \
  XEMU_URL=$(curl -sX GET "https://api.github.com/repos/xemu-project/xemu/releases/latest" \
    | awk -F '(": "|")' '/browser.*x86_64.AppImage/ && !/.*dbg.*/ {print $3}') && \
  curl -o \
    /tmp/xemu/xemu.app -L \
    "${XEMU_URL}" && \
  cd /tmp/xemu && \
  chmod +x xemu.app && \
  ./xemu.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/xemu && \
  echo "**** install esde ****" && \
  mkdir /tmp/esde && \
  curl -o \
    /tmp/esde/esde.app -L \
    "https://gitlab.com/es-de/emulationstation-de/-/package_files/246875981/download" && \
  cd /tmp/esde && \
  chmod +x esde.app && \
  ./esde.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/esde && \
  echo "**** install shadps4qt ****" && \
  mkdir /tmp/shadps4 && \
  SHADPS4_VERSION=$(curl -sX GET "https://api.github.com/repos/shadps4-emu/shadps4-qtlauncher/releases" \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && \
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
    | awk -F '(": "|")' '/browser.*linux.zip/ {print $3}') && \
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
  echo "**** install cemu ****" && \
  mkdir /tmp/cemu && \
  CEMU_URL=$(curl -sX GET "https://api.github.com/repos/cemu-project/Cemu/releases/latest" \
    | awk -F '(": "|")' '/browser.*ubuntu-22.04-x64.zip/ {print $3}') && \
  curl -o \
    /tmp/cemu/cemu.zip -L \
    "${CEMU_URL}" && \
  cd /tmp/cemu && \
  unzip cemu.zip && \
  mv \
    Cemu* \
    /opt/cemu && \
  chmod +x \
    /opt/cemu/Cemu && \
  echo "**** install flips ****" && \
  mkdir /tmp/flips && \
  FLIPS_URL=$(curl -sX GET "https://api.github.com/repos/Alcaro/Flips/releases/latest" \
    | awk -F '(": "|")' '/browser.*-linux.zip/ {print $3}') && \
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
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /tmp/* \
    /usr/share/applications/lxqt-config-monitor.desktop \
    /usr/share/applications/lxqt-hibernate.desktop \
    /usr/share/applications/lxqt-leave.desktop \
    /usr/share/applications/lxqt-lockscreen.desktop \
    /usr/share/applications/lxqt-logout.desktop \
    /usr/share/applications/lxqt-reboot.desktop \
    /usr/share/applications/lxqt-shutdown.desktop \
    /usr/share/applications/lxqt-suspend.desktop \
    /var/lib/apt/lists/* \
    /var/tmp/* 

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
