{ pkgs }: with pkgs;
[
  # Дополнения интерактивной оболочки Fish.
  fishPlugins.fzf-fish
  fishPlugins.done
  fishPlugins.pure
  fishPlugins.puffer
  fishPlugins.bass

  # Поиск, диагностика, сетевые утилиты и инструменты виртуальных машин.
  fzf
  fd
  bat
  ripgrep
  wget
  nil
  htop
  sshfs
  dnsmasq
  virtiofsd
  python3

  # Среды разработки, компиляторы и форматирование Nix.
  nodejs
  bun
  cargo
  rustc
  gcc

  javaPackages.compiler.openjdk25
  pkg-config
  nixfmt

  kdePackages.kate

  # Общение, сетевые приложения и удалённый доступ.
  telegram-desktop
  signal-desktop
  element-desktop
  vesktop
  tor-browser
  qbittorrent
  anydesk
  docker-compose
  piper

  # Графические редакторы и офис.
  gimp
  krita

  libreoffice

  # Игры, обработка мультимедиа и запуск Windows-приложений.
  prismlauncher
  ffmpeg-full
  gzdoom
  openspades

  wineWow64Packages.staging

  # Изоляция процессов и контейнерные окружения.
  bubblewrap
  distrobox

  vlc

  proton-vpn

  p7zip

  # Ассистент разработки, загрузка медиа и распознавание речи.
  codex
  yt-dlp
  whisper-cpp
]
