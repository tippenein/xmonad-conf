with (import <nixpkgs> {});

stdenv.mkDerivation {
  name = "my-xmonad";

  buildInputs = [
    haskell.packages.ghc801.ghc
    # pkgconfig
    # autoconf
    xorg.libX11
    xorg.libXext
    xorg.libXft
    xorg.libXinerama
    xorg.libXpm
    xorg.libXrandr
    xorg.libXrender

    # gnupg # sign tags and releases
  ];

  shellHook = ''
    # Generate the configure script in X11:
    ( test -d x11 && cd x11 && autoreconf -f )

    # Make stack happy:
    export GPG_TTY=`tty`

    setxkbmap -option caps:escape
    xmodmap -q ~/.Xmodmap
    feh --bg-center ~/Desktop/background.jpg
    # xscreensaver -no-splash &

    xrdb -merge ~/.Xresources

    # If we find that a screen is connected via VGA, activate it and position it
    # to the left of the primary screen.
    xrandr | grep 'VGA-1 connected' | ifne xrandr --output VGA-1 --auto --left-of LVDS-1

    # If we find that a screen is connected via DVI, activate it and position it
    # to the left of the primary screen.
    xrandr | grep 'DP-1 connected' | ifne xrandr --output DP-1 --auto --left-of LVDS-1
  '';
}
