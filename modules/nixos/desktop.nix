{ pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.plasma6.excludePackages = [ pkgs.kdePackages.konsole ];

  programs.niri.enable = true;

  # Applications used by Niri's default key bindings.
  environment.systemPackages = with pkgs; [
    alacritty
    fuzzel
    swaylock
  ];

  services = {
    # Keep the existing OpenSSH agent when Niri enables GNOME Keyring.
    gnome.gcr-ssh-agent.enable = false;

    xserver = {
      enable = true;
      videoDrivers = [
        "modesetting"
        "nvidia"
      ];
    };

    displayManager.ly = {
      enable = true;
      settings = {
        animation = "matrix";
        clear_password = true;
        vi_mode = true;
        vi_default_mode = "insert";
      };
    };

    desktopManager.plasma6.enable = true;
    displayManager.defaultSession = "plasma";

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    flatpak.enable = true;

    ratbagd.enable = true;
  };
}
