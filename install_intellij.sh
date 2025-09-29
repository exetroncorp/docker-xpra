#!/bin/bash
# Script to install IntelliJ IDEA

set -e

echo "Installing IntelliJ IDEA Ultimate..."

# Download IntelliJ IDEA
INTELLIJ_URL="https://download.jetbrains.com/idea/ideaIU-2025.2.2.tar.gz"
INTELLIJ_DIR="$HOME/.local/share/intellij"
TEMP_FILE="/tmp/intellij.tar.gz"

echo "Downloading IntelliJ IDEA from: $INTELLIJ_URL"
wget -O "$TEMP_FILE" "$INTELLIJ_URL"

# Create installation directory
mkdir -p "$INTELLIJ_DIR"

# Extract IntelliJ IDEA
echo "Extracting IntelliJ IDEA..."
tar -xzf "$TEMP_FILE" -C "$INTELLIJ_DIR" --strip-components=1

# Clean up download
rm "$TEMP_FILE"

# Create desktop entry
cat > ~/.local/share/applications/intellij-idea.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Ultimate
Comment=Intelligent Java IDE
Exec=/home/coder/.local/share/intellij/bin/idea.sh
Icon=/home/coder/.local/share/intellij/bin/idea.png
StartupWMClass=jetbrains-idea
Categories=Development;IDE;
StartupNotify=true
EOF

# Create a convenient launcher script
cat > ~/bin/intellij << 'EOF'
#!/bin/bash
/home/coder/.local/share/intellij/bin/idea.sh "$@" &
EOF

chmod +x ~/bin/intellij

# Add bin to PATH if not already there
if ! echo $PATH | grep -q "$HOME/bin"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi

# Set proper permissions
chmod +x ~/.local/share/intellij/bin/idea.sh

echo "IntelliJ IDEA Ultimate installation completed!"
echo "You can run it with: intellij"
echo "Or find it in the applications menu"
echo ""
echo "Note: This is the Ultimate edition. You'll need a license or can use the 30-day trial."
echo "For the free Community edition, modify this script to download the Community version instead."