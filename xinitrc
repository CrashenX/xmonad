#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

# Keyboard Mapping
usermodmap=$HOME/.Xmodmap

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi
#setxkbmap -layout "$(setxkbmap -print | awk -F + '/xkb_symbols/ {print $2}')" -option ctrl:nocaps

# Enable screen saver
nohup xscreensaver -nosplash &

# Load Xresources
#xrdb -merge ~/.Xresources

# Launch xmonad
xmonad
