FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute AS dolphin

RUN \
  echo "**** install build deps ****" && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    cmake \
    git \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libcurl4-openssl-dev \
    libegl1-mesa-dev \
    libevdev-dev \
    libpulse-dev \
    libqt6svg6-dev \
    libswscale-dev \
    libudev-dev \
    libvulkan-dev \
    libx11-dev \
    libxi-dev \
    libxrandr-dev \
    pkg-config \
    qt6-base-dev \
    qt6-base-private-dev \
    qt6-wayland-dev \
    qt6-wayland-private-dev

RUN \
  echo "**** build dolphin ****" && \
  DOLPHIN_VERSION=$(curl -sL 'https://dolphin-emu.org/download/' \
    | awk -F '(dolphin-|-x86_64.flatpak)' '/-x86_64.flatpak/ {print $3;exit}') && \
  mkdir /root-out && \
  git clone https://github.com/dolphin-emu/dolphin.git && \
  cd dolphin && \
  echo "**** building dolphin at ${DOLPHIN_VERSION} ****" && \
  git checkout -f ${DOLPHIN_VERSION} && \
  git submodule update --init --recursive && \
  mkdir build && \
  cd build && \
  cmake .. && \
  make -j16 && \
  make install DESTDIR=/root-out

FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute AS eden

RUN \
  echo "**** install build deps ****" && \
  apt-get update && \
  apt-get install -y \
    autoconf \
    cmake \
    g++ \
    gcc \
    git \
    glslang-tools \
    libasound2t64 \
    libavcodec-dev \
    libavfilter-dev \
    libboost-context-dev \
    libboost-fiber-dev \
    libcpp-httplib-dev \
    libcpp-jwt-dev \
    libcubeb-dev \
    libenet-dev \
    libfmt-dev \
    libglu1-mesa-dev \
    libhidapi-dev \
    liblz4-dev \
    libopus-dev \
    libpulse-dev \
    libqt6core5compat6 \
    libquazip1-qt6-dev \
    libsdl2-dev \
    libsimpleini-dev \
    libssl-dev \
    libswscale-dev \
    libtool \
    libudev-dev \
    libusb-1.0-0-dev \
    libva-dev \
    libvdpau-dev \
    libvulkan-dev \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxext-dev \
    libxkbcommon-x11-0 \
    libzstd-dev \
    mesa-common-dev \
    nasm \
    ninja-build \
    nlohmann-json3-dev \
    patch \
    pkg-config \
    qt6-base-private-dev \
    qt6-charts-dev \
    qt6-multimedia-dev \
    qt6-tools-dev \
    qt6-webengine-dev \
    spirv-headers \
    spirv-tools \
    spirv-tools-dev \
    vulkan-utility-libraries-dev \
    zlib1g-dev

RUN \
  echo "**** build eden ****" && \
  mkdir -p /root-out/usr/bin && \
  mkdir -p /root-out/usr/share/icons/hicolor/scalable/apps/ && \
  EDEN_VERSION=$(curl -sX GET 'https://git.eden-emu.dev/api/v1/repos/eden-emu/eden/releases/latest' \
    | jq -er '.tag_name') && \
  git clone https://git.eden-emu.dev/eden-emu/eden.git && \
  cd eden/ && \
  git checkout -f ${EDEN_VERSION} && \
  cmake -B build -GNinja \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_C_FLAGS="-march=x86-64-v3 -O2" \
    -DCMAKE_CXX_FLAGS="-march=x86-64-v3 -O2" \
    -DUSE_DISCORD_PRESENCE=ON \
    -DYUZU_ENABLE_LTO=OFF \
    -DYUZU_USE_CPM=OFF \
    -DCPM_USE_LOCAL_PACKAGES=ON \
    -DYUZU_USE_BUNDLED_FFMPEG=OFF \
    -DYUZU_USE_BUNDLED_SDL2=OFF \
    -DYUZU_USE_EXTERNAL_SDL2=OFF \
    -DYUZU_USE_BUNDLED_QT=OFF \
    -DENABLE_QT_TRANSLATION=ON \
    -DYUZU_USE_QT_MULTIMEDIA=ON \
    -DYUZU_USE_QT_WEB_ENGINE=ON \
    -Dhttplib_FORCE_BUNDLED=ON \
    -DTITLE_BAR_FORMAT_RUNNING="eden | ${EDEN_VERSION} {}" \
    -DTITLE_BAR_FORMAT_IDLE="eden ${EDEN_VERSION} {}" \
    -DYUZU_TESTS=OFF \
    -DDYNARMIC_TESTS=OFF \
    -DBUILD_TESTING=OFF \
    -Wno-dev && \
  cmake --build build && \
  mv \
    build/bin/* \
    /root-out/usr/bin/ && \
  mv \
    dist/icon_variations/base.svg \
    /root-out/usr/share/icons/hicolor/scalable/apps/dev.eden_emu.eden.svg

FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute AS cemu

RUN \
  echo "**** install build deps ****" && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    cmake \
    freeglut3-dev \
    git \
    libbluetooth-dev \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-nowide-dev \
    libboost-program-options-dev \
    libcubeb-dev \
    libcurl4-openssl-dev \
    libglm-dev \
    libfmt-dev \
    libgtk-3-dev \
    libhidapi-dev \
    libpng-dev \
    libpugixml-dev \
    libpulse-dev \
    libsdl2-dev \
    libssl-dev \
    libusb-1.0-0-dev \
    libwayland-dev \
    libwxgtk3.2-dev \
    libx11-dev \
    libzip-dev \
    libzstd-dev \
    nasm \
    ninja-build \
    pkg-config \
    python3 \
    rapidjson-dev \
    wayland-protocols \
    zlib1g-dev

RUN \
  echo "**** build cemu ****" && \
  CEMU_VERSION=$(curl -sX GET "https://api.github.com/repos/cemu-project/Cemu/releases/latest" \
    | jq -er '.tag_name') && \
  mkdir -p /root-out/usr/bin && \
  mkdir -p /root-out/usr/share/Cemu && \
  mkdir -p /root-out/usr/share/icons/hicolor/128x128/apps && \
  git clone https://github.com/KhronosGroup/glslang.git && \
  cd glslang && \
  git checkout -f 14.2.0 && \
  ./update_glslang_sources.py && \
  cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-include cstdint" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -G Ninja && \
  cmake --build build && \
  cmake --install build && \
  cd .. && \
  git clone https://github.com/cemu-project/Cemu.git && \
  cd Cemu && \
  echo "**** building cemu at ${CEMU_VERSION} ****" && \
  git checkout -f ${CEMU_VERSION} && \
  git submodule update --init --recursive \
    dependencies/cubeb \
    dependencies/ih264d \
    dependencies/imgui \
    dependencies/Vulkan-Headers \
    dependencies/ZArchive && \
  mkdir -p /usr/lib/x86_64-linux-gnu/cmake/hidapi && \
  printf '%s\n' \
    'add_library(hidapi::hidapi SHARED IMPORTED)' \
    'set_target_properties(hidapi::hidapi PROPERTIES' \
    '  IMPORTED_LOCATION "/usr/lib/x86_64-linux-gnu/libhidapi-hidraw.so"' \
    '  INTERFACE_INCLUDE_DIRECTORIES "/usr/include/hidapi")' \
    > /usr/lib/x86_64-linux-gnu/cmake/hidapi/hidapiConfig.cmake && \
  sed -i \
    's/set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)/set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE OFF)/' \
    CMakeLists.txt && \
  cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_C_COMPILER=/usr/bin/gcc \
    -DCMAKE_CXX_COMPILER=/usr/bin/g++ \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DENABLE_DISCORD_RPC=OFF \
    -DENABLE_FERAL_GAMEMODE=OFF \
    -DENABLE_VCPKG=OFF \
    -G Ninja && \
  cmake --build build && \
  cp -r \
    bin/* \
    /root-out/usr/share/Cemu/ && \
  mv \
    /root-out/usr/share/Cemu/Cemu_release \
    /root-out/usr/bin/Cemu && \
  cp \
    dist/linux/info.cemu.Cemu.png \
    /root-out/usr/share/icons/hicolor/128x128/apps/info.cemu.Cemu.png

# runtime stage
FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BROKER_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

ENV TITLE="Webstation" \
    NO_FULL=true \
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
    ibsdl2-2.0-0 \
    jstest-gtk \
    libavcodec62 \
    libbluetooth3 \
    libboost-context1.90.0 \
    libboost-filesystem1.90.0 \
    libboost-nowide1.90.0 \
    libboost-program-options1.90.0 \
    libcubeb0 \
    libenet7 \
    libfaad2 \
    libfmt10 \
    libgtk-3-0t64 \
    libgtk-3-common \
    libhidapi-hidraw0 \
    liblz4-1 \
    libopenal1 \
    libopus0 \
    libpipewire-0.3 \
    libpugixml1v5 \
    libqt6charts6 \
    libqt6multimedia6 \
    libqt6svg6 \
    libqt6webenginewidgets6 \
    libquazip1-qt6-1t64 \
    libsdl2-2.0-0 \
    libsimpleini1t64 \
    libssl3t64 \
    libusb-1.0-0 \
    libwxgtk-gl3.2-1t64 \
    libwxgtk3.2-1t64 \
    libxcb-cursor0 \
    libzip5 \
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
    | jq -er '.assets[] | select(.name == "azahar-wayland.AppImage") | .browser_download_url') && \
  curl -o \
    /tmp/azahar.app -L \
    "${AZAHAR_URL}" && \
  cd /tmp && \
  chmod +x azahar.app && \
  ./azahar.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/azahar && \
  ln -s \
    /opt/azahar/AppRun \
    /usr/bin/azahar && \
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
  DOSBOX_URL=$(curl -sX GET "https://api.github.com/repos/stenzek/duckstation/releases/latest" \
    | jq -er '.assets[] | select(.name == "DuckStation-x64.AppImage") | .browser_download_url') && \
  curl -o \
    /tmp/duck.app -L \
    "${DOSBOX_URL}" && \
  cd /tmp && \
  chmod +x duck.app && \
  ./duck.app --appimage-extract && \
  mv \
    squashfs-root \
    /opt/duckstation && \
  ln -s \
    /opt/duckstation/AppRun \
    /usr/bin/duckstation-qt && \
  ln -s \
    /opt/duckstation/usr/bin/libshaderc_shared.so \
    /usr/lib/x86_64-linux-gnu/libshaderc.so.1 && \
  echo "**** install flycast ****" && \
  FLYCAST_URL=$(curl -sX GET "https://api.github.com/repos/flyinghead/flycast/releases/latest" \
    | jq -er '.assets[] | select(.name | endswith("-x86_64.AppImage")) | .browser_download_url') && \
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
  ln -s \
    /opt/rpcs3/AppRun \
    /usr/bin/rpcs3 && \
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
  FLIPS_URL=$(curl -sX GET "https://api.github.com/repos/Alcaro/Flips/releases/latest" \
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

# add local files and files from build stages
COPY --from=cemu /root-out/ /
COPY --from=dolphin /root-out/ /
COPY --from=eden /root-out/ /
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
