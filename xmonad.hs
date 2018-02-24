-- xmonad.hs

import           XMonad

import           System.IO

import           XMonad.Actions.CycleWS
import           XMonad.Config.Gnome
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.SetWMName
import           XMonad.Util.EZConfig       (additionalKeys)
import           XMonad.Util.Run

-- Hooks
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Util.SpawnOnce

import           XMonad.Layout.NoBorders    (noBorders, smartBorders)
import           XMonad.Layout.PerWorkspace (onWorkspace, onWorkspaces)
import           XMonad.Layout.SimpleFloat

import           Data.List                  (intercalate)
import qualified Data.Map                   as M
import qualified XMonad.StackSet            as W
-------------------
-- Layouts --------
-------------------
myLayout = avoidStruts $ layoutHook def

-------------------
-- Worspace names -
-------------------
myWorkspaces = [ "1:shell"
               , "2:emacs"
               , "3:web"
               , "4:biz"
               , "5:chat"
               , "6:other"
               , "7"
               , "8"
               , "9:logs"]
-------------------
-- Hooks ----------
-------------------
myManageHook :: ManageHook
myManageHook = (composeAll . concat $
    [ pure $ manageHook gnomeConfig
    , [ resource     =? r   --> doIgnore            |   r   <- myIgnores]
    , [ className    =? c   --> doShift  "1:shell"  |   c   <- myShell  ]
    , [ className    =? c   --> doShift  "2:emacs"  |   c   <- myDev    ]
    , [ className    =? c   --> doShift  "3:web"    |   c   <- myWeb    ]
    , [ className    =? c   --> doShift  "4:biz"    |   c   <- myBiz    ]
    , [ className    =? c   --> doShift  "5:chat"   |   c   <- myChat   ]
    , [ className    =? c   --> doShift  "6:other"  |   c   <- myOther  ]
    , [ className    =? c   --> doCenterFloat       |   c   <- myFloats ]
    , [ name         =? n   --> doCenterFloat       |   n   <- myNames  ]
    , [ isFullscreen        --> myDoFullFloat                           ]
    , pure manageDocks
    ])

    where
      role      = stringProperty "WM_WINDOW_ROLE"
      name      = stringProperty "WM_NAME"

      -- classnames - Use 'xprop' to click windows and find out classname
      myShell   = ["gnome-terminal", "urxvt", "rxvt-unicode"]
      myDev     = ["emacs", "Emacs"]
      myWeb     = ["Firefox", "firefox-trunk"]
      myBiz     = ["Chromium-browser","chromium-browser"]
      myChat    = ["Pidgin","Buddy List", "hipchat", "HipChat", "Slack"]
      myOther   = ["Evince","xchm","libreoffice-writer","libreoffice-startcenter", "Signal"]
      myFloats  = ["Slack Call Minipanel", "keepass2","feh","Gimp","Xmessage","XFontSel","Nm-connection-editor", "qbittorrent", "Steam", "pavucontrol"]

      -- resources
      myIgnores = ["desktop","desktop_window","stalone-tray","notify-osd","stalonetray","trayer", "jetbrains-studio"]
      myNames   = ["bashrun","Google Chrome Options","Chromium Options"]

      -- a trick for fullscreen but stil allow focusing of other WSs
      myDoFullFloat :: ManageHook
      myDoFullFloat = doF W.focusDown <+> doFullFloat

newManageHook = myManageHook <+> manageHook def

myStartupHook = do
  ewmhDesktopsStartup >> setWMName "LG3D"  --- make java applications work..
  spawnOnce "stalonetray --dockapp-mode simple"
  spawnOnce "unity-settings-daemon"
  spawnOnce "gnome-settings-daemon"
  spawnOnce "nm-applet"
  spawnOnce "pasystray"
  spawnOnce "fdpowermon"
  spawnOnce myTerminal

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobar.hs"
    xmonad $ gnomeConfig
      { borderWidth        = 2
      , manageHook         = newManageHook
      , modMask            = myModMask
      , workspaces         = myWorkspaces
      , layoutHook         = smartBorders $ myLayout
      , normalBorderColor  = myNormalBorderColor
      , focusedBorderColor = myFocusedBorderColor
      , terminal           = myTerminal
      , startupHook        = myStartupHook
      , handleEventHook    = fullscreenEventHook <+> docksEventHook
      , focusFollowsMouse  = True
      , logHook = dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                }
      }
----------------
-- Keybinds ----
----------------
      `additionalKeys`
      -- screensaver
      [ (modShift xK_z          , spawn myScreensaver)
      -- normal screenshot
      , ((0, xK_Print         ) , spawn myFullScreenShot)
      , ((modMask, xK_p)        , spawn "dmenu_run")
      -- select screenshot
      , (modCtrl xK_Print       , spawn mySelectScreenShot)
      , (modCtrl xK_g           , spawn myScreenGif)
      , (modShift xK_n          , spawn "nm-connection-editor")
      , (modCtrl  xK_Right      , nextWS)
      , (modShift xK_Right      , shiftToNext)
      , (smash xK_o             , spawn "pavucontrol")
      , (modCtrl  xK_Left       , prevWS)
      , (modShift xK_Left       , shiftToPrev)
      , ((0, 0x1008ff12        ), spawn "amixer -q set Master mute")    --- can use 'xev' to see key events
      , ((0, 0x1008ff11        ), spawn "amixer -q sset Master 2%- unmute")
      , ((0, 0x1008ff13        ), spawn "amixer -q sset Master 2%+ unmute")
      , ((0, 0x1008ff03        ), spawn "xbacklight -inc -10%")
      , ((0, 0x1008ff02        ), spawn "xbacklight -inc +10%")
      ]
    where
      smash x = (mod1Mask .|. mod4Mask .|. controlMask, x)
      modMask = myModMask
      modShift x = (modMask .|. shiftMask, x)
      modCtrl x = (modMask .|. controlMask, x)

----------------
-- constants ---
----------------
myModMask = mod4Mask -- mod1Maks = alt   |   mod4Mask == meta
myTerminal = "gnome-terminal"
myFocusedBorderColor = "#88bb77"
myNormalBorderColor  = "#003300"
myScreensaver = "gnome-screensaver-command --lock"-- "systemctl suspend" -- "xscreensaver-command -lock"
mySelectScreenShot = "sleep 0.2; scrot -s -e 'mv $f ~/screenies'"
myFullScreenShot = "scrot -e 'mv $f ~/screenies'"

-- ctrl-shift s to stop recordmydesktop
myScreenGif = "mplayer -ao null ./out.ogv -vo jpeg:outdir=/tmp/output"
  ++ "&& convert /tmp/output/* /tmp/output.gif"
  ++ "&& gifsicle --batch --optimize=3 --scale=0.5 --colors=256 /tmp/output.gif --output ~/screenies/screen-cast-`date +%Y-%m-%d:%H:%M:%S`.gif"
  -- ++ "&& convert /tmp/output.gif -fuzz 10% -layers Optimize ~/screenies/screen-cast-`date +%Y-%m-%d:%H:%M:%S`.gif"
  ++ "&& mv ~/out.ogv /tmp/screen-cast-original-`date +%Y-%m-%d:%H:%M:%S`.ogv"
