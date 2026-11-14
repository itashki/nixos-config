{ ... }:
{
  networking = {
    networkmanager.enable = true;

    firewall = {
      # ALVR; Steam Remote Play ports come from programs.steam.remotePlay.
      allowedTCPPorts = [
        9943
        9944
      ];
      allowedUDPPorts = [
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
