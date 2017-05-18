Config { font = "xft:Bitstream Vera Sans Mono:size=12:antialias=true"
       , bgColor = "#222222"
       , fgColor = "grey"
       , position = TopW L 95
       , commands = [ Run Cpu ["-t", "<total>%", "-L","5","-H","40","--normal","green","--high","red"] 15
                    , Run BatteryP ["BAT0"] ["-t", "<left>%", "-h", "green", "-n", "yellow", "-l", "red"] 15
                    , Run Memory ["-t", "<usedratio>%"] 30
                    , Run Date "%a %b %_d - %l:%M" "date" 30
                    , Run StdinReader
                    , Run Com "/bin/bash" ["-c", "~/.xmonad/get_volume.sh"] "myvolume" 1
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ %date% | BAT: %battery% | Vol: <fc=#00CDCD>%myvolume%</fc> | CPU: %cpu% | MEM: %memory%"
       , lowerOnStart = False
}
