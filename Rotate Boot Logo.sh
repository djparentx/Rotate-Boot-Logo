#!/bin/bash
# Rotate Boot Logo - installer
# Installs a script + systemd service that randomly rotates /boot/logo.bmp
# Place .bmp files in /boot/BMPs

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi
set -e
clear
echo "========================================================="
echo "                   Rotate Boot Logo"
echo "                      by djparent"
echo "========================================================="
echo "Installing services..."
sleep 0.5

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
After=local-fs.target

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
sleep 5
