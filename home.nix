{ lib, pkgs, ... }:
{
  imports = [ ./modules/secret-tools.nix ];

  # Версия совместимости Home Manager, не повышается при обычном обновлении.
  home.stateVersion = "24.11";

  fonts.fontconfig.enable = true;

  # Allow Vulkan copies between GPUs in KWin on hybrid graphics systems.
  xdg.configFile."environment.d/90-kwin-mgpu.conf".text = ''
    KWIN_ALLOW_VULKAN_MGPU_COPIES=1
  '';

  # Avoid the Ghostty 1.3.1 startup race with systemd's reload-handler check.
  xdg.configFile."systemd/user/app-com.mitchellh.ghostty.service.d/startup.conf".text = ''
    [Service]
    Type=notify
    ExecReload=${pkgs.coreutils}/bin/kill -USR2 $MAINPID
  '';

  home.sessionVariables.TERMINAL = "ghostty";
  home.activation.setDefaultTerminal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key TerminalApplication ghostty
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop
  '';

  # Готовые пакеты сохраняют патчи Nixpkgs; адаптеры для plugins.src не нужны.
  home.packages = with pkgs.fishPlugins; [
    pkgs.fira-code
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
    ghostty = {
      enable = true;
      settings = {
        theme = "Adwaita Dark";
        font-family = "Fira Code";
        font-feature = [
          "calt"
          "liga"
        ];
      };
    };

    fzf = {
      enable = true;
      enableFishIntegration = false;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
    };

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
