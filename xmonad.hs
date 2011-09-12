import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Layout.Named
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.WindowNavigation
import System.IO

rzTall   = ResizableTall 1 (3/100) (1/2) []
myLayout = (   Full
           ||| (named "Tall"   $ rzTall)
           ||| (named "Mirror" $ reflectHoriz rzTall)
           ||| (named "Wide"   $ Mirror (rzTall))
           )

main = do
        xmproc <- spawnPipe "xmobar"
        xmonad $ defaultConfig 
            { manageHook = manageDocks <+> manageHook defaultConfig
            , layoutHook = windowNavigation $ avoidStruts $ myLayout
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

            -- Remove bindings to keys so they can be reassigned
            --
            -- NOTE: There is a bug in removeKeys that makes it act like what
            -- you would expect from a function called removeKey (i.e. it only
            -- operates on the first element in a list). Therefore, it is
            -- currently being called for each keymapping that needs to be
            -- unbound. Once the bug fix has been pulled into the current
            -- xmonad-contrib package the code commented below can replace the
            -- repeated calls below:
            --
            --`removeKeys`
            --[ (i, j) | i <- [mod4Mask, mod4Mask .|. shiftMask],
            --           j <- [xK_h, xK_j, xK_k, xK_l]
            --]
            `removeKeys` [ (mod4Mask, xK_Tab) ]
            `removeKeys` [ (mod4Mask .|. shiftMask, xK_Tab) ]
            `removeKeys` [ (mod4Mask, xK_h) ]
            `removeKeys` [ (mod4Mask, xK_j) ]
            `removeKeys` [ (mod4Mask, xK_k) ]
            `removeKeys` [ (mod4Mask, xK_l) ]
            `removeKeys` [ (mod4Mask .|. shiftMask, xK_h) ]
            `removeKeys` [ (mod4Mask .|. shiftMask, xK_j) ]
            `removeKeys` [ (mod4Mask .|. shiftMask, xK_k) ]
            `removeKeys` [ (mod4Mask .|. shiftMask, xK_l) ]

            `additionalKeys`
            -- Add bindings for moving windows within a workspace
            [ ((mod4Mask .|. shiftMask, xK_h), sendMessage $ Swap L)
            , ((mod4Mask .|. shiftMask, xK_j), sendMessage $ Swap D)
            , ((mod4Mask .|. shiftMask, xK_k), sendMessage $ Swap U)
            , ((mod4Mask .|. shiftMask, xK_l), sendMessage $ Swap R)
            -- Resize windows (only works properly with ResizableTall atm)
            , ((mod4Mask .|. controlMask, xK_h), sendMessage $ Shrink)
            , ((mod4Mask .|. controlMask, xK_j), sendMessage $ MirrorShrink)
            , ((mod4Mask .|. controlMask, xK_k), sendMessage $ MirrorExpand)
            , ((mod4Mask .|. controlMask, xK_l), sendMessage $ Expand)
            -- Add bindings for navigating windows within a workspace
            , ((mod4Mask, xK_h), sendMessage $ Go L)
            , ((mod4Mask, xK_j), sendMessage $ Go D)
            , ((mod4Mask, xK_k), sendMessage $ Go U)
            , ((mod4Mask, xK_l), sendMessage $ Go R)
            ]
