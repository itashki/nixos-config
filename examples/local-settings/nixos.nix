# Шаблон: скопируйте в secrets/ и настройте для своей машины.
# Настройки конкретной машины. Не добавлять в Git.
{ localSettings, ... }:
{
  networking = {
    hostName = localSettings.hostName;
  };
  services = {
    zerotierone = {
      enable = true;
      joinNetworks = [
        "0000000000000000"
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
    intelBusId = "PCI:0:2:0"; # Уточните через lspci.
    nvidiaBusId = "PCI:2:0:0"; # Уточните через lspci.
  };
  users.users.${localSettings.username} = {
    description = "Local User";
  };
}
