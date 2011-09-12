import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Layout.WindowNavigation
import XMonad.Layout.ResizableTile
import System.IO

main = do
        xmproc <- spawnPipe "xmobar"
        xmonad $ defaultConfig 
            { manageHook = manageDocks <+> manageHook defaultConfig
            , layoutHook = avoidStruts $ windowNavigation
                                       $ layoutHook defaultConfig
            , logHook = dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                }
            , modMask = mod4Mask
            , borderWidth = 2
            , terminal = "urxvt"
            , normalBorderColor = "#333333"
            , focusedBorderColor = "#FFAA00"
            }

