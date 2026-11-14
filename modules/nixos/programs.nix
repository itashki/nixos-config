{ ... }:
{
  programs = {
    discordify.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
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
