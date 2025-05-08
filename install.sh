#!/bin/bash

# setup.sh
# Configures passwordless sudo for XAMPP and installs the XAMPP Toggle extension

# Check if XAMPP is installed
if [ ! -f /opt/lampp/lampp ]; then
    echo "Error: XAMPP is not installed at /opt/lampp/lampp"
    echo "Please install XAMPP first: https://www.apachefriends.org/download.html"
    exit 1
fi

# Get the current user
CURRENT_USER=$(whoami)

# Configure passwordless sudo for /opt/lampp/lampp
SUDOERS_FILE="/etc/sudoers.d/xampp-toggle"
echo "Configuring passwordless sudo for XAMPP commands..."
sudo bash -c "echo '$CURRENT_USER ALL=(ALL) NOPASSWD: /opt/lampp/lampp' > $SUDOERS_FILE"
sudo chmod 440 $SUDOERS_FILE

# Verify sudo configuration
if sudo -l -U "$CURRENT_USER" | grep -q "NOPASSWD: /opt/lampp/lampp"; then
    echo "Passwordless sudo configured successfully"
else
    echo "Error: Failed to configure passwordless sudo"
    exit 1
fi

# Install the extension
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/xampp-toggle@chshahaz108@gmail.com"
echo "Installing XAMPP Toggle extension to $EXTENSION_DIR..."

# Create extension directory
mkdir -p "$EXTENSION_DIR"

# Copy extension files (assumes metadata.json and extension.js are in the same directory as setup.sh)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cp "$SCRIPT_DIR/metadata.json" "$SCRIPT_DIR/extension.js" "$EXTENSION_DIR/"

# Verify installation
if [ -f "$EXTENSION_DIR/extension.js" ] && [ -f "$EXTENSION_DIR/metadata.json" ]; then
    echo "Extension installed successfully"
else
    echo "Error: Failed to install extension files"
    exit 1
fi

# Enable the extension
echo "Enabling the extension..."
gnome-extensions enable xampp-toggle@chshahaz108@gmail.com

# Restart GNOME Shell (for X11; Wayland users need to log out/in)
echo ""
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "Restarting GNOME Shell (press Alt+F2, type 'r', and press Enter after this script)"
else
    echo "Please log out and log back in to apply the extension"
fi
echo ""

echo "Setup complete! Open the Quick Settings menu to toggle XAMPP."
