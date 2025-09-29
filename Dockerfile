FROM debian:12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # X11 dependencies
    xvfb \
    # GPG for adding xpra repository
    gnupg2 \
    lsb-release \
    # Window manager and desktop environment
    i3-wm \
    i3status \
    i3lock \
    dmenu \
    feh \
    rofi \
    polybar \
    picom \
    # File manager
    pcmanfm \
    # Development tools
    git \
    wget \
    curl \
    # Python and development
    python3 \
    python3-pip \
    python3-venv \
    # GUI libraries for Python (install via pip instead)
    python3-pyqt5 \
    qttools5-dev-tools \
    # Java runtime for IntelliJ
    default-jre \
    # Text editor (gedit as notepad++ equivalent)
    gedit \
    # Archive tools for extracting downloads
    tar \
    unzip \
    # Basic utilities
    sudo \
    ca-certificates \
    # Desktop environment basics
    desktop-file-utils \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install xpra from official repository
RUN wget -q https://xpra.org/gpg.asc -O- | apt-key add - && \
    echo "deb https://xpra.org/ bookworm main" > /etc/apt/sources.list.d/xpra.list && \
    apt-get update && \
    apt-get install -y xpra && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create directories
RUN mkdir -p /home/coder/.local/share/applications \
    /home/coder/.config/pcmanfm/default \
    /home/coder/.config/i3 \
    /home/coder/.config/polybar \
    /home/coder/.config/rofi \
    /home/coder/.config/picom \
    /home/coder/bin \
    /home/coder/scripts

# Set up file manager to start in fullscreen
RUN echo '[config]' > /home/coder/.config/pcmanfm/default/pcmanfm.conf && \
    echo 'view_mode=icon_view' >> /home/coder/.config/pcmanfm/default/pcmanfm.conf && \
    echo 'maximized=1' >> /home/coder/.config/pcmanfm/default/pcmanfm.conf

# Create Chrome desktop file
RUN cat > /home/coder/.local/share/applications/google-chrome.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Google Chrome (Rootless)
Comment=Access the Internet
Exec=/opt/google/chrome/chrome --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;
EOF

# Install Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy installation scripts
COPY install_qt_designer.sh /home/coder/scripts/
COPY install_intellij.sh /home/coder/scripts/
COPY install_postman.sh /home/coder/scripts/
COPY i3_config /home/coder/.config/i3/config
COPY polybar_config /home/coder/.config/polybar/config
COPY rofi_config /home/coder/.config/rofi/config.rasi
COPY picom_config /home/coder/.config/picom/picom.conf
COPY polybar_launch.sh /home/coder/.config/polybar/launch.sh

# Make scripts executable
RUN chmod +x /home/coder/scripts/*.sh

# Set proper ownership
RUN chown -R coder:coder /home/coder

# Make only /home/coder and /tmp writable for non-root
RUN chmod 755 /home/coder && \
    chmod 1777 /tmp

# Switch to non-root user
USER coder
WORKDIR /home/coder

# Copy entrypoint script
COPY entrypoint.sh /home/coder/
USER root
RUN chmod +x /home/coder/entrypoint.sh && chown coder:coder /home/coder/entrypoint.sh
USER coder

# Expose port
EXPOSE 8080

ENTRYPOINT ["/home/coder/entrypoint.sh"]