{ pkgs }: with pkgs;
[
  wget
  nil
  sshfs
  dnsmasq
  virtiofsd
  python3

  nodejs
  cargo
  rustc
  gcc

  pkg-config
  nixfmt

  kdePackages.kate

  telegram-desktop
  signal-desktop
  tor-browser
  qbittorrent
  anydesk
  docker-compose
  piper

  gimp
  krita

  ffmpeg-full
  gzdoom
  openspades
  wineWow64Packages.staging
  bubblewrap
  vlc
  proton-vpn
  p7zip
  whisper-cpp
  godot
]
