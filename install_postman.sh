#!/bin/bash
# Script to install Postman

set -e

echo "Installing Postman..."

# Download Postman
POSTMAN_URL="https://dl.pstmn.io/download/latest/linux64"
POSTMAN_DIR="$HOME/.local/share/postman"
TEMP_FILE="/tmp/postman.tar.gz"

echo "Downloading Postman..."
wget -O "$TEMP_FILE" "$POSTMAN_URL"

# Create installation directory
mkdir -p "$POSTMAN_DIR"

# Extract Postman
echo "Extracting Postman..."
tar -xzf "$TEMP_FILE" -C "$HOME/.local/share/" 

# Rename the extracted folder to postman
if [ -d "$HOME/.local/share/Postman" ]; then
    mv "$HOME/.local/share/Postman" "$POSTMAN_DIR"
fi

# Clean up download
rm "$TEMP_FILE"

# Create desktop entry
cat > ~/.local/share/applications/postman.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Postman
Comment=API Development Environment
Exec=/home/coder/.local/share/postman/Postman
Icon=/home/coder/.local/share/postman/app/resources/app/assets/icon.png
StartupWMClass=Postman
Categories=Development;WebDevelopment;
StartupNotify=true
EOF

# Create a convenient launcher script
cat > ~/bin/postman << 'EOF'
#!/bin/bash
/home/coder/.local/share/postman/Postman "$@" &
EOF

chmod +x ~/bin/postman

# Add bin to PATH if not already there
if ! echo $PATH | grep -q "$HOME/bin"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi

# Set proper permissions
chmod +x ~/.local/share/postman/Postman

echo "Postman installation completed!"
echo "You can run it with: postman"
echo "Or find it in the applications menu"