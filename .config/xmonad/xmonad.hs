-- :'######::'##:::::::'########:'########:'########::'##:::'##::::::::::'##::::'##:'########::'##::::'##:'##::::'##:'####:
-- '##... ##: ##::::::: ##.....:: ##.....:: ##.... ##:. ##:'##::::::::::: ##:::: ##: ##.... ##: ##:::: ##: ###::'###:. ##::
--  ##:::..:: ##::::::: ##::::::: ##::::::: ##:::: ##::. ####:::::::::::: ##:::: ##: ##:::: ##: ##:::: ##: ####'####:: ##::
-- . ######:: ##::::::: ######::: ######::: ########::::. ##::::'#######: ##:::: ##: ########:: ##:::: ##: ## ### ##:: ##::
-- :..... ##: ##::::::: ##...:::: ##...:::: ##.....:::::: ##::::........: ##:::: ##: ##.. ##::: ##:::: ##: ##. #: ##:: ##::
-- '##::: ##: ##::::::: ##::::::: ##::::::: ##::::::::::: ##::::::::::::: ##:::: ##: ##::. ##:: ##:::: ##: ##:.:: ##:: ##::
-- . ######:: ########: ########: ########: ##::::::::::: ##:::::::::::::. #######:: ##:::. ##:. #######:: ##:::: ##:'####:
-- :......:::........::........::........::..::::::::::::..:::::::::::::::.......:::..:::::..:::.......:::..:::::..::....::
--
-- Github Repo: https://github.com/sleepy-urumi/xmonad
-- 

import XMonad
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Layout.Spacing
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Layout.Dwindle
import XMonad.Hooks.InsertPosition
import qualified XMonad.StackSet as W
import qualified Data.Map.Strict as M
import Graphics.X11.ExtraTypes.XF86

myLayoutHook = avoidStruts $ spacingWithEdge 3 $
    Spiral R CW 1.618 1.1
    ||| Tall 1 (3/100) (1/2)
    ||| Mirror (Tall 1 (3/100) (1/2))
    ||| Full

myManageHook :: ManageHook
myManageHook = insertPosition End Newer <+> manageHook def

toggleFloat :: Window -> X ()
toggleFloat w = withWindowSet $ \ws ->
    if M.member w (W.floating ws)
        then windows (W.sink w)
        else windows (W.float w (W.RationalRect 0.1 0.1 0.8 0.8))

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "xrandr --output eDP-1 --mode 2880x1800 --scale-from 1920x1200 --rotate normal --pos 0x0"
    spawnOnce "dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_SESSION_TYPE=x11 XDG_CURRENT_DESKTOP=xmonad"
    spawnOnce "gentoo-pipewire-launcher"
    spawnOnce "lxqt-policykit-agent"
    spawnOnce "udiskie"
    spawnOnce "gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"
    spawnOnce "killall picom; picom &"
    spawnOnce "pkill -f 'notification-daemon' && sleep 0.5 && dunst"
    spawnOnce "xwallpaper --output eDP-1 --maximize /home/urumi/.wallpapers/8ztrtsedsfxgzuoi.png"
    spawnOnce "setxkbmap de"


myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = xmobarColor "#756b5d" "" "  •  "
    , ppCurrent         = xmobarColor "#c5a04b" ""
                         . wrap " " " "
    , ppVisible         = xmobarColor "#FEFEF6" ""
                         . wrap " " " "
    , ppHidden          = xmobarColor "#a9b1d6" ""
                         . wrap " " " "
    , ppHiddenNoWindows = xmobarColor "#756b5d" ""
    , ppUrgent          = xmobarColor "#BF4124" ""
                         . wrap "!" "!"
    , ppTitle           = const ""
    , ppLayout          = const ""
    , ppOrder           = \(ws : _ : _) -> [ws]
    }


myStatusBar = statusBarProp "xmobar" (pure myXmobarPP)

myKeys =
    [ ("M-<Return>", spawn "kitty")
    , ("M-d", spawn "rofi -show drun -theme ~/.config/rofi/theme.rasi")
    , ("M-S-r", spawn "xmonad --recompile" >> spawn "xmonad --restart")
    , ("M-q", kill)
    , ("M-c", spawn "/home/urumi/.local/opt/floorp/floorp")
    , ("M-e", spawn "pcmanfm")
    , ("M-s", withFocused toggleFloat)
    , ("<XF86MonBrightnessUp>", spawn "brightnessctl s +5%")
    , ("<XF86MonBrightnessDown>", spawn "brightnessctl s 5%-")
    , ("<XF86AudioRaiseVolume>", spawn "pamixer -i 5")
    , ("<XF86AudioLowerVolume>", spawn "pamixer -d 5")
    , ("<XF86AudioMute>", spawn "pamixer --toggle-mute")
    ]

main :: IO ()
main = xmonad $ withEasySB myStatusBar defToggleStrutsKey $ def
    { modMask = mod4Mask
    , terminal = "kitty"
    , borderWidth = 2
    , normalBorderColor = "#2A2D3F"
    , focusedBorderColor = "#c5a04b"
    , layoutHook = myLayoutHook
    , startupHook = myStartupHook
    , manageHook = myManageHook
    }
    `additionalKeysP` myKeys
