FROM jupyter/minimal-notebook

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Installation of packages for development
RUN apt-get update --yes && \
    apt-get install --yes --quiet --no-install-recommends \
    curl \
    iputils-ping \
	build-essential \
    make \
    cmake \
    g++ \
    clang \
    htop \
    libopencv-dev \
    && \
    apt-get --quiet clean && rm -rf /var/lib/apt/lists/*

# Installing Code Server and server-proxy/vscode-proxy to integrate Code into JupyterLab
ENV CODE_VERSION=4.7.1
RUN curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_VERSION/code-server_${CODE_VERSION}_amd64.deb \
    && dpkg -i code-server_${CODE_VERSION}_amd64.deb \
    && rm -f code-server_${CODE_VERSION}_amd64.deb
RUN /opt/conda/bin/conda install -c conda-forge jupyter-server-proxy
RUN /opt/conda/bin/conda install -c conda-forge jupyter-vscode-proxy

# Installation of the XFCE desktop and the Desktop server extension to have a graphical display
RUN apt-get update --yes --quiet && \
    apt-get install --yes --quiet \
    dbus-x11 xfce4 xfce4-panel xfce4-session xfce4-settings xorg xubuntu-icon-theme && \
    apt-get remove --yes --quiet light-locker && \
    apt-get clean --quiet && rm -rf /var/lib/apt/lists/*
RUN /opt/conda/bin/conda install -c manics websockify && \
    pip install git+https://github.com/yuvipanda/jupyter-desktop-server.git
 
# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
