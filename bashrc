# bashrc additions for xmonad
alias retina27='nohup bash -c \
              "~/src/xmonad/install Xdefaults-retina27 \
              && killall urxvt \
              && sleep 1 \
              && (urxvt -e screen -x main &) \
              && (urxvt -e screen -x irc &) \
              "'
alias retina15='nohup bash -c \
              "~/src/xmonad/install Xdefaults-retina15.4 \
              && killall urxvt \
              && sleep 1 \
              && (urxvt -e screen -x main &) \
              && (urxvt -e screen -x irc &) \
              "'
