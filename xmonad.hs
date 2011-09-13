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
myLayout = Full
           ||| named "Tall"     rzTall
           ||| named "Mirror" (reflectHoriz rzTall)
           ||| named "Wide"   (Mirror rzTall)

-- removeKeys has a bug that causes it to only remove the first key in the
-- list. This function works around that, it should be removed once the
-- arch package is updated with the bugfix.
removeKeysFixed :: XConfig a -> [(ButtonMask,KeySym)] -> XConfig a
removeKeysFixed xconf [] = xconf
removeKeysFixed xconf keys = foldr (\x y -> y `removeKeys` [x]) xconf keys

-- pattern matching seems broken here, so use guards instead
vimDir k
    | k == xK_h = L
    | k == xK_j = D
    | k == xK_k = U
    | k == xK_l = R

vimResizeMap k
    | k == xK_h = sendMessage $ Shrink
    | k == xK_j = sendMessage $ MirrorShrink
    | k == xK_k = sendMessage $ MirrorExpand
    | k == xK_l = sendMessage $ Expand

-- List of the bound keys for convenience
vimKeys = [xK_h, xK_j, xK_k, xK_l]

keysList = [((customShiftMask,x),sendMessage $ Swap (vimDir x))|x<-vimKeys]++
           [((customCtrlMask ,x),vimResizeMap x) | x <- vimKeys] ++
           [((mod4Mask       ,x),sendMessage $ Go (vimDir x)) | x <- vimKeys]

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
            -- TODO: switch this to 'removeKeys' once the package is updated
            -- with the bugfix.
            `removeKeysFixed` [(i,j)|i<-[mod4Mask,customShiftMask],j<-vimKeys]
            `additionalKeys` keysList
