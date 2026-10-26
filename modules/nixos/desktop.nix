{ lib, pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.plasma6.excludePackages = [ pkgs.kdePackages.konsole ];

  programs.niri.enable = true;

  # Applications used by Niri's default key bindings.
  environment.systemPackages = with pkgs; [
    alacritty
    fuzzel
    swaylock
    waybar
    brightnessctl
    xwayland-satellite
  ];

  # Ly includes the login PAM stack; finish unlocking KWallet in Niri.
  security.pam.services.login.kwallet.forceRun = true;
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkForce "kwallet";
  xdg.portal.extraPortals = [ pkgs.kdePackages.kwallet ];

  systemd.user.services = {
    niri-kwallet = {
      description = "Finish KWallet PAM login in Niri";
      wantedBy = [ "niri.service" ];
      partOf = [ "niri.service" ];
      after = [ "niri.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init";
        RemainAfterExit = true;
      };
    };
    niri-kded = {
      description = "KDE services and NetworkManager KWallet agent for Niri";
      wantedBy = [ "niri.service" ];
      partOf = [ "niri.service" ];
      after = [
        "niri.service"
        "niri-kwallet.service"
      ];
      environment.QT_PLUGIN_PATH = "${pkgs.kdePackages.plasma-nm}/lib/qt-6/plugins:/run/current-system/sw/lib/qt-6/plugins";
      serviceConfig = {
        Type = "dbus";
        BusName = "org.kde.kded6";
        ExecStart = "${pkgs.kdePackages.kded}/bin/kded6";
        Restart = "on-failure";
      };
    };
    niri-polkit = {
      description = "KDE authentication agent for Niri";
      wantedBy = [ "niri.service" ];
      partOf = [ "niri.service" ];
      after = [ "niri.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
      };
    };
  };

  services = {
    # Use the same wallet in Plasma and Niri instead of a second secret store.
    gnome.gnome-keyring.enable = lib.mkForce false;
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
