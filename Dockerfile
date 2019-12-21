FROM ubuntu:18.04

# ARGS
ARG userid
ARG groupid
ARG username

# SET NONINTERACTIVE
ENV DEBIAN_FRONTEND "noninteractive"

# RUN STUFF AS ROOT
USER root

RUN apt update && \
    apt install -y \
    curl \
    gpg \
    coreutils \
    tree \
    nano \
    net-tools \
    locate \
    bsdmainutils \
    locales \
    apt-transport-https

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US
ENV LC_ALL en_US.UTF-8

RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

RUN apt update && \
    apt install -y code

RUN apt update \
    && apt install -y libnotify4 \
    libnss3 \
    libxkbfile1 \
    libgconf-2-4 \
    libsecret-1-0 \
    libgtk2.0-0 \
    libxss1 \
    libasound2 \
    libcanberra-gtk-module \
    gtk2-engines-murrine \
    gtk2-engines-pixbuf \
    ubuntu-mate-icon-themes \
    ubuntu-mate-themes

RUN apt update && \
    apt install -y \
    git \
    gcc-8 \
    g++-8

RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 50 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 50 && \
    update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-8 50 && \
    update-alternatives --set g++ /usr/bin/g++-8 && \
    update-alternatives --set gcc /usr/bin/gcc-8 && \
    update-alternatives --set cpp-bin /usr/bin/cpp-8 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/g++-8 50

RUN apt install -y \
    libx11-xcb-dev \
    pkg-config \
    wget \
    sudo

RUN apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN mkdir -p /home/$username \
    && echo "$username:x:$userid:$groupid:$username,,,:/home/$username:/bin/bash" >> /etc/passwd \
    && echo "$username:x:$userid:" >> /etc/group \
    && mkdir -p /etc/sudoers.d \
    && echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username \
    && chmod 0440 /etc/sudoers.d/$username \
    && chown $userid:$groupid -R /home/$username \
    && chmod 777 -R /home/$username \
    && usermod -a -G $username www-data \
    && dbus-uuidgen > /var/lib/dbus/machine-id

# UNSET NONINTERACTIVE
ENV DEBIAN_FRONTEND ""

USER $username
ENV SHELL /bin/bash
ENV HOME /home/$username
WORKDIR /home/$username

RUN wget https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init -O rustup-init && \
    chmod +x rustup-init

RUN ./rustup-init -y

COPY .bashrc .bashrc

RUN /home/$username/.cargo/bin/rustup component add rust-analysis --toolchain stable-x86_64-unknown-linux-gnu && \
    /home/$username/.cargo/bin/rustup component add rust-src --toolchain stable-x86_64-unknown-linux-gnu && \
    /home/$username/.cargo/bin/rustup component add rls --toolchain stable-x86_64-unknown-linux-gnu

RUN echo 'include "/usr/share/themes/Ambiant-MATE/gtk-2.0/gtkrc"' > /home/$username/.gtkrc-2.0

CMD ["/bin/bash", "--login"]