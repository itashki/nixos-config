{ pkgs, ... }:
{
  # Версия совместимости Home Manager, не повышается при обычном обновлении.
  home.stateVersion = "24.11";

  # Готовые пакеты сохраняют патчи Nixpkgs; адаптеры для plugins.src не нужны.
  home.packages = with pkgs.fishPlugins; [
    fzf-fish
    done
    pure
    puffer
    bass
  ];

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
      enableFishIntegration = false;
    };

    fish.enable = true;

    java = {
      enable = true;
      package = pkgs.javaPackages.compiler.openjdk25;
    };
    bun.enable = true;
    distrobox.enable = true;

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
