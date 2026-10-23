{ ... }:
{
  networking = {
    networkmanager.enable = true;

    # Разрешённые входящие порты и диапазоны.
    firewall = {
      allowedTCPPorts = [
        27031
        27036
        9943
        9944
      ];
      allowedUDPPorts = [
        27036
        27037
        10400
        10401
        9943
        9944
      ];
      allowedTCPPortRanges = [
        # KDE Connect
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        # KDE Connect
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };
}
