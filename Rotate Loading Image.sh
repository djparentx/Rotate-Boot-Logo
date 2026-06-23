#!/bin/bash
# Rotate Loading Image - installer
# Installs a script into EmulationStation's game-end hook that randomly
# rotates /roms/launchimages/loading.jpg
# Place .jpg files in /roms/launchimages/JPGs

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi
set -e
clear
echo "========================================================="
echo "                  Rotate Loading Image"
echo "                      by djparent"
echo "========================================================="
echo "Installing service..."
sleep 0.5

SCRIPT_DIR="/home/ark/.emulationstation/scripts/game-end"
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

echo "Rotate Loading Image installed."
sleep 3
