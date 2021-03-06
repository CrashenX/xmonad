import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.PhysicalScreens
import XMonad.Operations
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Layout.Named
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.WindowNavigation
import XMonad.Util.CustomKeys
import XMonad.StackSet as W
import Graphics.X11.ExtraTypes.XF86
import Data.List (find)
import System.IO
import Control.Monad


-- define layouts
rzTall     = ResizableTall 1 (3/100) (1/2) []
fullLayout = named "Full" Full
tallLayout = named "Tall" rzTall
mirrorTall = named "Mirror" $ reflectHoriz rzTall
wideLayout = named "Wide" $ Mirror rzTall

myLayout = fullLayout ||| tallLayout ||| mirrorTall ||| wideLayout

curLayout :: X String
curLayout = gets windowset >>= return . description . W.layout . W.workspace . W.current

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

vimResizeMapMirror k
    | k == xK_h = sendMessage $ Expand
    | k == xK_j = sendMessage $ MirrorShrink
    | k == xK_k = sendMessage $ MirrorExpand
    | k == xK_l = sendMessage $ Shrink

vimResizeMapWide k
    | k == xK_h = sendMessage $ MirrorExpand
    | k == xK_j = sendMessage $ Expand
    | k == xK_k = sendMessage $ Shrink
    | k == xK_l = sendMessage $ MirrorShrink

vimGetResizeMap k = do
    str <- curLayout
    case str of
        "Mirror"  -> vimResizeMapMirror k
        "Wide"    -> vimResizeMapWide k
        otherwise -> vimResizeMap k
    return ()

vimKeys = [xK_h, xK_j, xK_k, xK_l]
workspaceKeys = [xK_n, xK_p]
allKeys = vimKeys ++ workspaceKeys
myDmenu = "exe=`dmenu_path | dmenu` && eval \"exec $exe\""

deleteList _ = [(i,j)|i<-[mod1Mask,mod4Mask,customShiftMask,customCtrlMask]
               ,      j<-allKeys
               ]

keysList l =
       -- Add keybindings to move windows around within a workspace
       [((customShiftMask, x), sendMessage $ Swap (vimDir x))|x<-vimKeys]
       -- Add keybindings to resize windows within a workspace
    ++ [((customCtrlMask, x), vimGetResizeMap x) | x <- vimKeys]
       -- Add keybindings to change focused window within a workspace
    ++ [((mod4Mask, x), sendMessage $ Go (vimDir x)) | x <- vimKeys]
       -- Add keybinding to launch dmenu
    ++ [((mod4Mask, xK_o), spawn myDmenu)
       -- Add additional keybinding to close focused window
       ,((mod4Mask, xK_w), kill)
       -- Add keybindings to cycle physical screens
       ,((customAltMask, xK_h), onPrevNeighbour W.view)
       ,((customAltMask, xK_l), onNextNeighbour W.view)
       -- Add keybindings to cycle workspaces
       ,((mod4Mask, xK_n), nextWS)
       ,((mod4Mask, xK_p), prevWS)
       -- Add keybindings to cycle focused window through workspaces
       ,((customShiftMask, xK_n), shiftToNext >> nextWS)
       ,((customShiftMask, xK_p), shiftToPrev >> prevWS)
       -- Add keybindings to lock screen
       ,((mod1Mask, xK_l), spawn "xscreensaver-command --lock")
       -- Add keybindings for screen brightness
       ,((0, xF86XK_MonBrightnessUp  ), spawn "xbacklight -time 100 +10")
       ,((0, xF86XK_MonBrightnessDown), spawn "xbacklight -time 100 -10")
       -- Add keybindings for volume controls
       ,((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master 1%+")
       ,((0, xF86XK_AudioLowerVolume), spawn "amixer set Master 1%-")
       ,((0, xF86XK_AudioMute), spawn "amixer set Master toggle")
       ]


-- Convenience functions defining our masks to make the code more readable.
customShiftMask = mod4Mask .|. shiftMask
customCtrlMask  = mod4Mask .|. controlMask
customAltMask   = mod4Mask .|. mod1Mask

main = do
        -- since we are in a "do" block, using "<-" here calls the "bind"
        -- function of the monad that is returned by spawnPipe, allowing us to
        -- directly access the value inside the monad, in this case the IO
        -- monad.
        xmproc <- spawnPipe "xmobar"

        -- Call the xmonad function with an XConfig value that is generated by
        -- everything that comes after the "$"

        xmonad $ defaultConfig 
        -- defaultConfig is a type, manageHook, layoutHook, etc. are members of
        -- the type. We say "manageHook = ", etc. so that we don't have to care
        -- about the order that the elements are defined in the data type.
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
            , normalBorderColor = "#4E4E4E"
            , focusedBorderColor = "#606060"
            }
