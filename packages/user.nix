{ pkgs }: with pkgs;
[
  # Поиск, диагностика, сетевые утилиты и инструменты виртуальных машин.
  wget
  nil
  sshfs
  dnsmasq
  virtiofsd
  python3

  # Среды разработки, компиляторы и форматирование Nix.
  nodejs
  cargo
  rustc
  gcc

  pkg-config
  nixfmt

  kdePackages.kate

  # Общение, сетевые приложения и удалённый доступ.
  telegram-desktop
  signal-desktop
  tor-browser
  qbittorrent
  anydesk
  docker-compose
  piper

  # Графические редакторы.
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
