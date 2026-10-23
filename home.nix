{ pkgs, ... }:
{
  # Версия совместимости Home Manager, не повышается при обычном обновлении.
  home.stateVersion = "24.11";

  programs = {
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
