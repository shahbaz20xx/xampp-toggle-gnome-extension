#!/bin/bash

# uninstall.sh
# Removes the XAMPP Toggle extension and its sudo configuration

# Extension details
EXTENSION_UUID="xampp-toggle@chshahaz108@gmail.com"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"
SUDOERS_FILE="/etc/sudoers.d/xampp-toggle"

# Disable the extension
echo "Disabling the XAMPP Toggle extension..."
if gnome-extensions disable "$EXTENSION_UUID" 2>/dev/null; then
    echo "Extension disabled successfully"
else
    echo "Warning: Extension was not enabled or not found"
fi

# Remove the extension directory
if [ -d "$EXTENSION_DIR" ]; then
    echo "Removing extension files from $EXTENSION_DIR..."
    rm -rf "$EXTENSION_DIR"
    if [ ! -d "$EXTENSION_DIR" ]; then
        echo "Extension files removed successfully"
    else
        echo "Error: Failed to remove extension files"
        exit 1
    fi
else
    echo "Extension directory not found, skipping removal"
fi

# Remove sudoers configuration with safety checks
if [ -f "$SUDOERS_FILE" ]; then
    echo "Checking sudoers configuration at $SUDOERS_FILE..."
    # Verify the file contains only the expected XAMPP configuration
    EXPECTED_CONTENT=".*NOPASSWD: /opt/lampp/lampp"
    if sudo grep -qE "$EXPECTED_CONTENT" "$SUDOERS_FILE" 2>/dev/null; then
        echo "Removing passwordless sudo configuration for XAMPP..."
        # Create a backup for safety
        BACKUP_FILE="$SUDOERS_FILE.bak-$(date +%F-%H%M%S)"
        sudo cp "$SUDOERS_FILE" "$BACKUP_FILE"
        echo "Backup created at $BACKUP_FILE"
        # Remove the sudoers file
        sudo rm -f "$SUDOERS_FILE"
        if [ ! -f "$SUDOERS_FILE" ]; then
            echo "Sudo configuration removed successfully"
        else
            echo "Error: Failed to remove sudo configuration"
            exit 1
        fi
    else
        echo "Warning: $SUDOERS_FILE contains unexpected content or is not readable"
        echo "Please manually check $SUDOERS_FILE with 'sudo cat $SUDOERS_FILE' and remove it with sudo rm $SUDOERS_FILE if it only pertains to XAMPP Toggle"
    fi
else
    echo "Sudo configuration not found, skipping removal"
fi

# Inform user about GNOME Shell restart
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "Please restart GNOME Shell to complete uninstallation (press Alt+F2, type 'r', and press Enter)"
else
    echo "Please log out and log back in to complete uninstallation"
fi

echo "Uninstallation complete!"
