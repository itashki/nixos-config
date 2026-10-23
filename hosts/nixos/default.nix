{ localSettings, ... }:
{
  networking = {
    hostName = localSettings.hostName;
  };
  services = {
    zerotierone = {
      enable = true;
      joinNetworks = [
        "a581878f7d77dc10"
      ];
    };
  };
  boot.loader.systemd-boot = {
    windows = {
      "windows" = {
        title = "Windows";
        efiDeviceHandle = "HD0b";
        sortKey = "y_windows";
      };
    };
  };
  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:2:0:0";
  };
  users.users.${localSettings.username} = {
    description = "KTRD";
  };
}
