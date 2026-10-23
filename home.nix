{ pkgs, ... }:
{
  # Версия совместимости Home Manager, не повышается при обычном обновлении.
  home.stateVersion = "24.11";

  programs = {
    # CLI-инструменты: модули позволяют добавлять настройки без дублирования пакетов.
    bat.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    htop.enable = true;
    yt-dlp.enable = true;
    codex.enable = true;

    fzf = {
      enable = true;
      # Привязками Fish управляет fzf-fish; не подключаем второй набор.
      enableFishIntegration = false;
    };

    # Системное включение Fish остаётся в modules/nixos/programs.nix.
    fish = {
      enable = true;
      plugins =
        map
          (name: {
            inherit name;
            src = pkgs.fishPlugins.${name}.src;
          })
          [
            "fzf-fish"
            "done"
            "pure"
            "puffer"
            "bass"
          ];
    };

    # Сохраняем выбранную версию JDK; модуль также устанавливает JAVA_HOME.
    java = {
      enable = true;
      package = pkgs.javaPackages.compiler.openjdk25;
    };
    bun.enable = true;
    distrobox.enable = true;

    # Пользовательские приложения с собственными модулями Home Manager.
    element-desktop.enable = true;
    vesktop.enable = true;
    libreoffice.enable = true;
    prismlauncher.enable = true;

    home-manager.enable = true;

    vim.enable = true;
    git = {
      enable = true;

      settings = {
        url."git@github.com:".insteadOf = "https://github.com/";
      };

      signing.format = "openpgp";
    };

    mpv.enable = true;

    librewolf.enable = true;
    chromium.enable = true;

    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
  };
  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
