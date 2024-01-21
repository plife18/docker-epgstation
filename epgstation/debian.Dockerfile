FROM l3tnun/epgstation:v2.6.20-debian

ENV DEV="make gcc git g++ automake curl wget autoconf build-essential libass-dev libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev \
        ninja-build cmake meson libboost-all-dev"
ENV FFMPEG_VERSION=4.4.4

RUN apt-get update && \
    apt-get -y install $DEV && \
    apt-get -y install yasm libx264-dev libmp3lame-dev libopus-dev libvpx-dev && \
    apt-get -y install libx265-dev libnuma-dev && \
    apt-get -y install libasound2 libass9 libvdpau1 libva-x11-2 libva-drm2 libxcb-shm0 libxcb-xfixes0 libxcb-shape0 libvorbisenc2 libtheora0 libaribb24-dev && \
\
    echo "deb http://http.us.debian.org/debian buster main contrib non-free" | tee -a /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install libfdk-aac-dev libfdk-aac1 && \
\
# avisynth+
    cd /tmp && \
    git clone https://github.com/AviSynth/AviSynthPlus && \
    cd AviSynthPlus && \
    mkdir avisynth-build && \
    cd avisynth-build && \
    cmake ../ -G Ninja -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON && \
    ninja && \
    ninja install && \
    ldconfig && \
\
# ffmpeg build
    mkdir /tmp/ffmpeg_sources && \
    cd /tmp/ffmpeg_sources && \
    curl -fsSL http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 | tar -xj --strip-components=1 && \
    ./configure \
      --prefix=/usr/local \
      --disable-shared \
      --pkg-config-flags=--static \
      --enable-gpl \
      --enable-libass \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-version3 \
      --enable-libaribb24 \
      --enable-nonfree \
      --disable-debug \
      --disable-doc \
      --enable-libfdk-aac \
      --enable-avisynth \
    && \
    make -j$(nproc) && \
    make install && \
\
# l-smash
    cd /tmp && \
    git clone https://github.com/l-smash/l-smash.git && \
    cd l-smash && \
    ./configure --enable-shared && \
    make -j$(nproc) && \
    make install && \
\
# l-smash-source
    cd /tmp && \
    git clone -b 20200728 https://github.com/HolyWu/L-SMASH-Works.git && \
    git clone https://github.com/tobitti0/chapter_exe.git -b arm-test && \
    cp chapter_exe/src/sse2neon.h L-SMASH-Works/AviSynth/emmintrin.h && \
    cd L-SMASH-Works/AviSynth && \
    sed -i.bk -e '42,43d' -e "72aif host_machine.cpu_family().startswith('arm')\n add_project_arguments('-mfpu=neon', language : ['c', 'cpp'])\nendif\n" meson.build && \
    sed -i.bk '52d' video_output.cpp && \
    LDFLAGS="-Wl,-Bsymbolic" meson build && \
    cd build && \
    ninja -v && \
    ninja install && \
\
# JoinLogoScpTrialSetLinux
    cd /tmp && \
    git clone --recursive https://github.com/plife18/JoinLogoScpTrialSetLinux.git && \
    cd JoinLogoScpTrialSetLinux && \
    git submodule foreach git pull origin master && \
    \
    ## chapter_exe
    cd /tmp/chapter_exe/src && \
    cp -a Makefile Makefile_org && \
    sed s/-mfpu=neon// Makefile_org > Makefile && \
    make -j$(nproc) && \
    mv chapter_exe /tmp/JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial/bin && \
    \
    ## logoframe
    cd /tmp/JoinLogoScpTrialSetLinux/modules/logoframe/src && \
    make -j$(nproc) && \
    mv logoframe /tmp/JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial/bin && \
    \
    ## join_logo_scp
    cd /tmp/JoinLogoScpTrialSetLinux/modules/join_logo_scp/src && \
    make -j$(nproc) && \
    mv join_logo_scp /tmp/JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial/bin && \
    \
    ## tsdivider
    cd /tmp/JoinLogoScpTrialSetLinux/modules/tsdivider && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    mv tsdivider /tmp/JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial/bin && \
    \
    ## copy directory
    mv /tmp/JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial / && \
\
# delogo
    cd /tmp && \
    git clone https://github.com/tobitti0/delogo-AviSynthPlus-Linux && \
    cd delogo-AviSynthPlus-Linux/src && \
    make -j$(nproc) && \
    make install && \
\
# jlse
    cd /join_logo_scp_trial && \
    npm install && \
    npm link && \
\
# 不要なパッケージを削除
    apt-get -y remove $DEV && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
