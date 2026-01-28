#!/bin/sh
set -e

# =====================================
# Alpine Fluxbox Desktop Configuration
# Run as root AFTER installing packages
# =====================================

WALLPAPER_URL="https://wallpapers.com/images/featured/beautiful-3vau5vtfa3qn7k8v.jpg"
WALLPAPER_PATH="/usr/share/wallpapers/default.jpg"

echo "==> Enabling required OpenRC services"
rc-update add dbus default
rc-update add slim default

echo "==> Preparing wallpaper"
mkdir -p /usr/share/wallpapers
wget -O "$WALLPAPER_PATH" "$WALLPAPER_URL"

echo "==> Configuring SLiM for Fluxbox"
if [ -f /etc/slim.conf ]; then
  sed -i 's|^#*login_cmd.*|login_cmd exec /bin/sh - ~/.xinitrc|' /etc/slim.conf
  sed -i 's|^#*default_user.*|default_user nobody|' /etc/slim.conf
fi

mkdir -p /etc/slim.conf.d
echo "default_user_session=fluxbox" > /etc/slim.conf.d/fluxbox.conf

echo "==> Setting up /etc/skel"

# ---------------------
# .xinitrc
# ---------------------
cat <<'EOF' > /etc/skel/.xinitrc
#!/bin/sh

# Start desktop services
pcmanfm --desktop &
tint2 &
feh --bg-scale /usr/share/wallpapers/default.jpg &

exec fluxbox
EOF
chmod +x /etc/skel/.xinitrc

# ---------------------
# Fluxbox config
# ---------------------
mkdir -p /etc/skel/.fluxbox

cat <<'EOF' > /etc/skel/.fluxbox/init
session.screen0.toolbar.visible: true
session.screen0.toolbar.height: 24
session.screen0.focusModel: sloppy
session.screen0.workspaceNames: Workspace 1,Workspace 2,Workspace 3,Workspace 4
session.screen0.menuDelay: 200
session.autoRaiseDelay: 300
EOF

cat <<'EOF' > /etc/skel/.fluxbox/menu
[begin] (Applications)
  [exec] (Terminal) {alacritty}
  [exec] (File Manager) {pcmanfm}
  [exec] (Web Browser) {firefox-esr}
  [exec] (Text Editor) {geany}
  [exec] (Media Player) {mpv}
  [separator]
  [exec] (Settings) {echo "Settings app placeholder"}
  [separator]
  [exit] (Logout)
[end]
EOF

# ---------------------
# Desktop icons
# ---------------------
mkdir -p /etc/skel/Desktop

create_icon () {
  NAME="$1"
  EXEC="$2"
  ICON="$3"

  cat <<EOF > "/etc/skel/Desktop/$NAME.desktop"
[Desktop Entry]
Name=$NAME
Exec=$EXEC
Icon=$ICON
Type=Application
Terminal=false
EOF

  chmod +x "/etc/skel/Desktop/$NAME.desktop"
}

create_icon "Firefox ESR" "firefox-esr" "firefox"
create_icon "File Manager" "pcmanfm" "folder"
create_icon "Geany" "geany" "geany"
create_icon "Media Player" "mpv" "multimedia-player"
create_icon "Settings" "sh -c 'echo Settings app coming soon'" "preferences-system"

# ---------------------
# doas configuration
# ---------------------
echo "==> Configuring doas"
if [ ! -f /etc/doas.conf ]; then
  echo "permit persist :wheel" > /etc/doas.conf
fi
chmod 600 /etc/doas.conf

echo "==> Desktop configuration complete!"
echo "Reboot, log in via SLiM, and enjoy Fluxbox."
