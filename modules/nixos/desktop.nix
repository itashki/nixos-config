{ ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services = {
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
