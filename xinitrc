#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

# Keyboard Mapping
usermodmap=$HOME/.Xmodmap

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
    xkbset m
    xkbset exp =m
fi

# Enable screen saver
nohup xscreensaver -nosplash &

# Enable auto-suspend (lock requires UPower, PolicyKit, and xscreensaver)
xautolock -time 5 -locker $HOME/bin/lock &

# Enable fancy effects
xcompmgr -c -f -C -F &

# use a real cursor
xsetroot -cursor_name left_ptr

# set a wallpaper
feh --bg-fill ~/.config/wallpaper

# enable ssh-agent per-session
eval $(ssh-agent)

# Set default screen brightness
xbacklight =20

# Launch xmonad
xmonad

exit 0
