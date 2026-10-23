{ ... }:
{
  imports = [
    ./modules/nixos/boot.nix
    ./modules/nixos/networking.nix
    ./modules/nixos/services.nix
    ./modules/nixos/desktop.nix
    ./modules/nixos/hardware.nix
    ./modules/nixos/virtualisation.nix
    ./modules/nixos/users.nix
    ./modules/nixos/programs.nix
    ./modules/nixos/nix-ld.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Язык окружения, региональные форматы и раскладка консоли.
  time.timeZone = "Asia/Jerusalem";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "he_IL.UTF-8";
      LC_IDENTIFICATION = "he_IL.UTF-8";
      LC_MEASUREMENT = "he_IL.UTF-8";
      LC_MONETARY = "he_IL.UTF-8";
      LC_NAME = "he_IL.UTF-8";
      LC_NUMERIC = "he_IL.UTF-8";
      LC_PAPER = "he_IL.UTF-8";
      LC_TELEPHONE = "he_IL.UTF-8";
      LC_TIME = "he_IL.UTF-8";
    };
  };
  console.keyMap = "us";

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    allowUserNamespaces = true;
  };

  # Версия совместимости установленной системы, не версия nixpkgs.
  system.stateVersion = "25.05";
}
