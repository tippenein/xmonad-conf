with (import <nixpkgs> {});

stdenv.mkDerivation {
  name = "my-xmonad";

  buildInputs = [
    # GHC:
    haskell.packages.ghc801.ghc

    # Non-Haskell Dependencies:
    pkgconfig
    autoconf
    xorg.libX11
    xorg.libXext
    xorg.libXft
    xorg.libXinerama
    xorg.libXpm
    xorg.libXrandr
    xorg.libXrender

    gnupg # sign tags and releases
  ];

  shellHook = ''
    # Generate the configure script in X11:
    ( test -d x11 && cd x11 && autoreconf -f )

    # Make stack happy:
    export GPG_TTY=`tty`

    setxkbmap -option caps:escape
    xmodmap -q ~/.Xmodmap
    feh --bg-center ~/Desktop/background.jpg
  '';
}
