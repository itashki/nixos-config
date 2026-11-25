{ ... }:
{
  programs = {
    discordify.enable = true;

    steam = {
      enable = true;
      # Remote Play ports are opened on LAN interfaces only (networking.nix).
      remotePlay.openFirewall = false;
      protontricks.enable = true;
    };

    ssh = {
      startAgent = true;
    };

    fish = {
      enable = true;
    };

    virt-manager = {
      enable = true;
    };

    tmux = {
      enable = true;
      extraConfig = ''
        set -g mouse on
        set -as terminal-features ',*:hyperlinks'
      '';
    };
  };
}
