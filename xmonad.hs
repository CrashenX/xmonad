import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Layout.Named
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.WindowNavigation
import XMonad.Util.CustomKeys
import System.IO
import Control.Monad


-- define layouts
rzTall     = ResizableTall 1 (3/100) (1/2) []
fullLayout = named "Full" Full
tallLayout = named "Tall" rzTall
mirrorTall = named "Mirror" $ reflectHoriz rzTall
wideLayout = named "Wide" $ Mirror rzTall

myLayout = fullLayout ||| tallLayout ||| mirrorTall ||| wideLayout

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

-- vimResizeMapMirror k
--     | k == xK_h = sendMessage $ MirrorShrink
--     | k == xK_j = sendMessage $ Shrink
--     | k == xK_k = sendMessage $ Expand
--     | k == xK_l = sendMessage $ MirrorExpand

vimResizeMapMirror k
    | k == xK_h = sendMessage $ Expand
    | k == xK_j = sendMessage $ Expand
    | k == xK_k = sendMessage $ Expand
    | k == xK_l = sendMessage $ Expand

compareLayouts l1 l2 = (description l1) == (description l2)

getVimResizeMap l
    | (compareLayouts (layoutHook l) mirrorTall) = vimResizeMapMirror
    | otherwise = vimResizeMap

-- List of the bound keys for convenience
vimKeys = [xK_h, xK_j, xK_k, xK_l]

deleteList _ = [(i,j)|i<-[mod4Mask,customShiftMask,customCtrlMask],j<-vimKeys]

keysList l = 
       [((customShiftMask,x),sendMessage $ Swap (vimDir x))|x<-vimKeys]
    ++ [((customCtrlMask ,x),(getVimResizeMap l) x) | x <- vimKeys]
    ++ [((mod4Mask       ,x),sendMessage $ Go (vimDir x)) | x <- vimKeys]

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
            , keys = customKeys deleteList keysList
            , borderWidth = 2
            , terminal = "urxvt"
            , normalBorderColor = "#333333"
            , focusedBorderColor = "#FFAA00"
            }
