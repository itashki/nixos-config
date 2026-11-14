{ pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.plasma6.excludePackages = [ pkgs.kdePackages.konsole ];

  # Ly is a TTY greeter, so pam_kwallet must be forced to unlock the wallet.
  security.pam.services.login.kwallet.forceRun = true;
  # Plasma's portal config routes the Secret portal to KWallet.
  xdg.portal.extraPortals = [ pkgs.kdePackages.kwallet ];

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us,ru,il";
        options = "grp:caps_toggle";
      };
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
      extraConfig.pipewire-pulse."90-block-mic-volume" = {
        "pulse.rules" = [
          {
            # Only desktop controls and mixer tools may adjust microphone volume.
            matches = [
              {
                "application.process.binary" = "!~^(plasmashell|systemsettings|kded6|pavucontrol|pactl|pamixer)$";
              }
            ];
            actions.quirks = [ "block-source-volume" ];
          }
        ];
      };
    };

    flatpak.enable = true;

    ratbagd.enable = true;
  };
}
