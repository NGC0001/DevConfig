FROM ubuntu:20.04

# If there are broken GPG keys for cuda.
RUN mv /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/cuda.list.bak && \
    mv /etc/apt/sources.list.d/nvidia-ml.list /etc/apt/sources.list.d/nvidia-ml.list.bak

# Build stage ARGs.
ARG ADDING_USER_NAME=someone
ARG CONFIG_USER_NAME=${ADDING_USER_NAME}
ARG CMAKE_VERSION=3.18.4

# Set environment variables.
ENV TERM xterm-256color

# Set build stage workdir.
WORKDIR /tmp

# Switch to Tsinghua apt source, and install apt-utils.
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
COPY sources.list.ubuntu.20.04.tsinghua /etc/apt/sources.list
RUN apt update -y && \
    apt install -y --no-install-recommends \
    apt-utils \
    && rm -rf /var/lib/apt/lists/*

# Upgrade existing packages.
RUN apt update -y && \
    apt upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Set up locales.
RUN apt update -y && \
    apt install -y --no-install-recommends \
    locales \
    && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.utf8 && \
    update-locale LANG=en_US.utf8 LC_ALL=en_US.utf8

# Install essential tools.
RUN apt update -y && \
    apt install -y --no-install-recommends \
    sudo \
    locate \
    tldr \
    curl \
    wget \
    git \
    less \
    unzip \
    zip \
    rename \
    rsync \
    tmux \
    vim \
    neovim \
    # ctags: https://andrew.stwrt.ca/posts/vim-ctags/ \
    exuberant-ctags \
    openssh-server \
    zsh \
    ip \
    ss \
    && rm -rf /var/lib/apt/lists/*

# Install build tools.
RUN apt update -y && \
    apt install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*
# Upgrade CMake.
# We may also use installation scripts available from the net.
RUN wget -O cmake.tar.gz https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz && \
    tar zxf cmake.tar.gz --strip-components=1 -C /usr/local/ && \
    update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force && \
    rm -f cmake.tar.gz

# Install monitor tools.
RUN apt update -y && \
    apt install -y --no-install-recommends \
    glances \
    htop \
    atop \
    iotop \
    dstat \
    lsof \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*
## # Install nvtop
## RUN apt update -y && \
##     apt install -y --no-install-recommends \
##     libncurses5-dev \
##     libncursesw5-dev \
##     && rm -rf /var/lib/apt/lists/*
## RUN git clone https://github.com/Syllo/nvtop.git && \
##     mkdir -p nvtop/build && \
##     cd nvtop/build && \
##     cmake .. -DNVML_RETRIEVE_HEADER_ONLINE=True && \
##     make && \
##     make install && \
##     cd ../.. && \
##     rm -rf nvtop
## # Install Intel PCM
## RUN git clone https://github.com/opcm/pcm.git && \
##     cd pcm && \
##     make -j4 && \
##     make install && \
##     cd .. && \
##     rm -rf pcm

# Install python.
RUN apt update -y && \
    apt install -y --no-install-recommends \
    python3 \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install and configure pip. [/etx/pip.conf index-url extra-index-url trusted-host]
RUN apt update -y && \
    apt install -y --no-install-recommends \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip && \
    pip3 config --global set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# Install Python packages.
RUN pip3 install \
    wheel \
    setuptools \
    ipdb \
    clang-format \
    yapf \
    cpplint \
    numpy \
    scipy \
    sympy \
    matplotlib \
    seaborn \
    pandas \
    sklearn \
    # tensorflow \
    # tensorboard_plugin_profile \
    protobuf \
    pyyaml \
    ipython

# Install develop libraries.
RUN apt update -y && \
    apt install -y --no-install-recommends \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

########################

# Add user and sudo permission.
RUN useradd -m -U -s /usr/bin/zsh ${ADDING_USER_NAME}
COPY nopasswd-sudoer /etc/sudoers.d/
RUN sed -i "s/user_name/${ADDING_USER_NAME}/" /etc/sudoers.d/nopasswd-sudoer && \
    chmod 440 /etc/sudoers.d/nopasswd-sudoer

########################

# Specify the user.
USER ${CONFIG_USER_NAME}

# Ipython startup scripts.
# Let the shell deduct ${HOME}.
COPY --chown=${CONFIG_USER_NAME}:${CONFIG_USER_NAME} ipython /tmp/ipython/
RUN mkdir -p ${HOME}/.ipython && \
    cp -rPp /tmp/ipython/* ${HOME}/.ipython/ && \
    rm -rf /tmp/ipython

# Setup git.
RUN git config --global user.name "${CONFIG_USER_NAME}" && \
    git config --global user.email "${CONFIG_USER_NAME}@noreply.com" && \
    git config --global pager.branch false && \
    git config --global alias.lgd "log --graph --branches --pretty=format:'%C(yellow)%h%Creset %Cgreen%an%Creset %s %Cred%D%Creset%n'"

# Install oh-my-zsh and plugins.
RUN curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh >/tmp/install_omz.sh && \
    sh /tmp/install_omz.sh --unattended && \
    rm -f /tmp/install_omz.sh
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    sed -i 's/\(^plugins=(\)\(.*\))/\1\2 zsh-autosuggestions)/' ${HOME}/.zshrc
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/\(^plugins=(\)\(.*\))/\1\2 zsh-syntax-highlighting)/' ${HOME}/.zshrc
# TODO: Disable OMZ auto update
# TODO: Modify zsh key binding: bindkey \^U backward-kill-line

# Configure shell.
COPY --chown=${CONFIG_USER_NAME}:${CONFIG_USER_NAME} shell-config /tmp/shell-config
RUN cp /tmp/shell-config ${HOME}/.shell_config && \
    echo $'\n''source ${HOME}/.shell_config' >>${HOME}/.zshrc && \
    echo $'\n''source ${HOME}/.shell_config' >>${HOME}/.bashrc && \
    rm -f /tmp/shell-config

# Install rust-lang.
# NOTE, we won't log into a container,
# so PATH needs to be modified in '.rc', other than '.profile'.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >/tmp/install_rust.sh && \
    sh /tmp/install_rust.sh -y && \
    echo $'\n''export PATH="$PATH:${HOME}/.cargo/bin"' >>${HOME}/.shell_config && \
    rm -f /tmp/install_rust.sh

# Setup vim.
COPY --chown=${CONFIG_USER_NAME}:${CONFIG_USER_NAME} vimrc /tmp/vimrc
RUN cp /tmp/vimrc ${HOME}/.vimrc && \
    rm -f /tmp/vimrc
# Vim pathogen.
# With pathogen, consider maintain '~/.vim' as a github repo,
# and all the plugins under '~/.vim/bundle/' as respective submodules.
# Then we can use 'git clone --recursive'
# to pull the repo and its submodules (plugins) at a time.
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim --create-dirs \
    https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
# vim-plug.
RUN mkdir -p ~/.vim/autoload && \
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Setup neovim.
# We reuse the vim configuration.
RUN mkdir -p ${HOME}/.config/nvim "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site && \
    ln -s ${HOME}/.vimrc ${HOME}/.config/nvim/init.vim && \
    ln -s ~/.vim/autoload "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload && \
    ln -s ~/.vim/bundle "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/bundle

# Setup ssh.
COPY --chown=${CONFIG_USER_NAME}:${CONFIG_USER_NAME} ssh /tmp/ssh/
RUN mkdir -p ${HOME}/.ssh && \
    cp -rPp /tmp/ssh/* ${HOME}/.ssh/ && \
    find ${HOME}/.ssh -type d -exec chmod 700 {} \; && \
    find ${HOME}/.ssh -type f -exec chmod 600 {} \; && \
    rm -rf /tmp/ssh
# We can put id_rsa and id_rsa.pub to the 'ssh' directory.

# NOTE, the workdir here is manually set, not deducted by shell.
WORKDIR /home/${CONFIG_USER_NAME}

# Use zsh as the entry point.
ENTRYPOINT ["/usr/bin/zsh"]
CMD []

# How to merge docker image layers:
# https://stackoverflow.com/questions/22713551/how-to-flatten-a-docker-image
