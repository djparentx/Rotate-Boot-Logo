#!/bin/bash
# Rotate Screens - installer
# Installs a script + systemd service that randomly rotates /boot/logo.bmp
# Place .bmp files in /boot/BMPs

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi
set -e
clear
echo "========================================================="
echo "                    Rotate Screens"
echo "                      by djparent"
echo "========================================================="
echo "Installing services..."
sleep 0.5

SCRIPT_DIR="/home/ark/.emulationstation/scripts/game-end"

cat > /usr/local/bin/rotate_boot_logo.sh << 'EOF'
#!/bin/bash
# Picks a random .bmp from /boot/BMPs and copies it over /boot/logo.bmp
# If no candidates exist, leaves /boot/logo.bmp untouched.

BMP_DIR="/boot/BMPs"
TARGET="/boot/logo.bmp"

shopt -s nullglob
bmp=("$BMP_DIR"/*.bmp)
shopt -u nullglob

if [ ${#bmp[@]} -eq 0 ]; then
    exit 0
fi

RANDOM_INDEX=$(( RANDOM % ${#bmp[@]} ))
SELECTED="${bmp[$RANDOM_INDEX]}"

cp -f "$SELECTED" "$TARGET"
EOF

chmod +x /usr/local/bin/rotate_boot_logo.sh

cat > /etc/systemd/system/rotate-boot-logo.service << 'EOF'
[Unit]
Description=Rotate Boot Logo
After=emulationstation.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/rotate_boot_logo.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable rotate-boot-logo.service

echo "Rotate Boot Logo installed and enabled."
echo "Place .bmp files in /boot/BMPs to rotate."

mkdir -p "$SCRIPT_DIR"
cat > "$SCRIPT_DIR/rotate_loading_image.sh" << 'EOF'
#!/bin/bash
# Picks a random .jpg or .png from /roms/launchimages/JPGs and copies it
# over /roms/launchimages/loading.jpg
# If no candidates exist, leaves loading.jpg untouched.

IMG_DIR="/roms/launchimages/JPGs"
TARGET="/roms/launchimages/loading.jpg"

shopt -s nullglob
images=("$IMG_DIR"/*.jpg)
shopt -u nullglob

if [ ${#images[@]} -eq 0 ]; then
    exit 0
fi

RANDOM_INDEX=$(( RANDOM % ${#images[@]} ))
SELECTED="${images[$RANDOM_INDEX]}"

cp -f "$SELECTED" "$TARGET"
EOF

chmod +x "$SCRIPT_DIR/rotate_loading_image.sh"
chown ark:ark "$SCRIPT_DIR/rotate_loading_image.sh"

echo "Rotate Loading Image installed and enabled."
echo "Place .jpg files in /roms/launchimages/JPGs to rotate."
sleep 5
