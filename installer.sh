#!/bin/sh
# Beginner-Friendly Fluxbox Alpine Setup Script (Enhanced with Desktop Icons and Wallpaper)
set -e

# -----------------------------
# Variables
# -----------------------------
WALLPAPER_URL="https://wallpapers.com/images/featured/beautiful-3vau5vtfa3qn7k8v.jpg"
WALLPAPER_NAME="default_wallpaper.jpg"

# -----------------------------
# Update and install core packages
# -----------------------------
echo "Updating package index..."
apk update

echo "Installing X11 and basic utilities..."
apk add xorg-server xf86-video-vesa xinit xterm bash sudo vim wget

echo "Installing Fluxbox..."
apk add fluxbox

echo "Installing PCManFM and GVFS..."
apk add pcmanfm gvfs

echo "Installing media tools (MPV, Fih)..."
apk add mpv fih

echo "Installing Firefox ESR..."
apk add firefox-esr

echo "Installing SLiM login manager..."
apk add slim
rc-update add slim default

echo "Preconfiguring SLiM to use Fluxbox..."
mkdir -p /etc/slim.conf.d
echo "default_user_session=fluxbox" > /etc/slim.conf.d/fluxbox.conf
if [ -f /etc/slim.conf ]; then
    sed -i 's/^#*login_cmd.*/login_cmd        exec \/bin\/sh - ~/.xinitrc %session/' /etc/slim.conf
fi

echo "Installing optional terminal (Alacritty)..."
apk add alacritty

echo "Installing text editor (Geany)..."
apk add geany

echo "Installing wallpaper and panel utilities..."
apk add nitrogen fbsetbg tint2

echo "Installing Flatpak..."
apk add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
apk add gnome-software # lightweight GUI for Flatpak apps

# -----------------------------
# Configure default Xinit for Fluxbox session
# -----------------------------
mkdir -p /etc/skel
cat <<'EOF' > /etc/skel/.xinitrc
#!/bin/sh
# Start desktop environment and utilities
pcmanfm --desktop &
tint2 &
nitrogen --restore &
exec fluxbox
EOF
chmod +x /etc/skel/.xinitrc

# -----------------------------
# Create default Fluxbox settings
# -----------------------------
mkdir -p /etc/skel/.fluxbox
cat <<'EOF' > /etc/skel/.fluxbox/init
session.screen0.toolbar.visible: true
session.screen0.toolbar.height: 20
session.screen0.focus: sloppy
session.screen0.workspaceNames: Workspace1,Workspace2,Workspace3,Workspace4
EOF

cat <<'EOF' > /etc/skel/.fluxbox/menu
[begin] (Applications)
  [xterm] (xterm)
  [Alacritty] (alacritty)
  [PCManFM] (pcmanfm)
  [Firefox ESR] (firefox-esr)
  [Geany] (geany)
  [MPV] (mpv)
  [Settings] (echo "Launch your settings app here")
[end]
EOF

# -----------------------------
# Set up Desktop icons
# -----------------------------
mkdir -p /etc/skel/Desktop

# Function to create .desktop files
create_desktop_icon() {
    NAME=$1
    EXEC=$2
    ICON=$3
    cat <<EOF > /etc/skel/Desktop/$NAME.desktop
[Desktop Entry]
Name=$NAME
Exec=$EXEC
Icon=$ICON
Type=Application
Terminal=false
EOF
}

echo "Creating default desktop icons..."
create_desktop_icon "Firefox ESR" "firefox-esr" "firefox"
create_desktop_icon "PCManFM" "pcmanfm" "folder"
create_desktop_icon "Geany" "geany" "geany"
create_desktop_icon "MPV" "mpv" "multimedia-player"
create_desktop_icon "Settings" "echo Launch your settings app here" "preferences-system"

chmod +x /etc/skel/Desktop/*.desktop

# -----------------------------
# Download and set default wallpaper
# -----------------------------
echo "Downloading default wallpaper..."
mkdir -p /usr/share/wallpapers
wget -O /usr/share/wallpapers/$WALLPAPER_NAME $WALLPAPER_URL

echo "Setting default wallpaper for new users..."
mkdir -p /etc/skel/.config/nitrogen
cat <<EOF > /etc/skel/.config/nitrogen/bg-saved.cfg
[geometry]
0=0,0,1920,1080

[screen0]
file=/usr/share/wallpapers/$WALLPAPER_NAME
mode=5
bgcolor=#000000
EOF

# -----------------------------
# Install essential build tools
# -----------------------------
apk add alpine-sdk coreutils

echo "Setup complete! New users will have a ready-to-use Fluxbox desktop with icons and wallpaper."

