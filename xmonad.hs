import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Layout.Named
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.WindowNavigation
import Control.Monad
import System.IO

rzTall   = ResizableTall 1 (3/100) (1/2) []
myLayout = Full
           ||| named "Tall"     rzTall
           ||| named "Mirror" (reflectHoriz rzTall)
           ||| named "Wide"   (Mirror rzTall)

removeKeysFixed :: XConfig a -> [(ButtonMask,KeySym)] -> XConfig a
removeKeysFixed xconf [] = xconf
removeKeysFixed xconf keys = foldr (\x y -> y `removeKeys` [x]) xconf keys

vimSwapMap xK_h = sendMessage $ Swap L
vimSwapMap xK_j = sendMessage $ Swap D
vimSwapMap xK_k = sendMessage $ Swap U
vimSwapMap xK_l = sendMessage $ Swap R

vimGoMap xK_h = sendMessage $ Go L
vimGoMap xK_j = sendMessage $ Go D
vimGoMap xK_k = sendMessage $ Go U
vimGoMap xK_l = sendMessage $ Go R

vimResizeMap xK_h = sendMessage Shrink
vimResizeMap xK_j = sendMessage MirrorShrink
vimResizeMap xK_k = sendMessage MirrorExpand
vimResizeMap xK_l = sendMessage Expand

vimKeys = [xK_h, xK_j, xK_k, xK_l]

keysList = [((customShiftMask, x), vimSwapMap x)   | x <- vimKeys] ++
           [((customCtrlMask , x), vimResizeMap x) | x <- vimKeys] ++
           [((mod4Mask       , x), vimGoMap x) | x <- vimKeys]

customShiftMask = mod4Mask .|. shiftMask
customCtrlMask  = mod4Mask .|. controlMask

main = do
        xmproc <- spawnPipe "xmobar"
        xmonad $ defaultConfig 
            { manageHook = manageDocks <+> manageHook defaultConfig
            , layoutHook = windowNavigation $ avoidStruts myLayout
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

            -- NOTE: There is a bug in removeKeys that makes it act like what
            -- you would expect from a function called removeKey (i.e. it only
            -- operates on the first element in a list). Therefore we are using
            -- the removedKeysFixed function which works around this bug. Once
            -- the bug fix has been pulled into the current xmonad-contrib
            -- package the code commented below can replace the repeated calls
            -- below:
            
            `removeKeysFixed`
            [ (i, j) | i <- [mod4Mask, mod4Mask .|. shiftMask],
                       j <- [xK_h, xK_j, xK_k, xK_l]
            ]

            `additionalKeys` keysList
