#!/bin/bash
# Script to install Qt Designer for PyQt development

set -e

echo "Installing Qt Designer and PyQt development tools..."

# Create virtual environment for PyQt development
python3 -m venv ~/.local/pyqt-env

# Activate virtual environment
source ~/.local/pyqt-env/bin/activate

# Install PyQt5 and development tools
pip install --upgrade pip
pip install PyQt5 PyQt5-tools

# Create desktop entry for Qt Designer
cat > ~/.local/share/applications/qt-designer.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Qt Designer
Comment=Design Qt GUIs
Exec=/home/coder/.local/pyqt-env/bin/pyqt5-tools designer
StartupNotify=true
Terminal=false
Icon=designer
Type=Application
Categories=Development;GUIDesigner;
EOF

# Create a convenient launcher script
cat > ~/bin/qt-designer << 'EOF'
#!/bin/bash
source ~/.local/pyqt-env/bin/activate
pyqt5-tools designer "$@"
EOF

chmod +x ~/bin/qt-designer

# Add bin to PATH if not already there
if ! echo $PATH | grep -q "$HOME/bin"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi

echo "Qt Designer installation completed!"
echo "You can run it with: qt-designer"
echo "Or find it in the applications menu"
echo ""
echo "To use PyQt5 in your projects, activate the virtual environment:"
echo "source ~/.local/pyqt-env/bin/activate"