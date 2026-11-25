{ lib, ... }:
let
  # Local services are reachable only from the home LAN, never via ZeroTier,
  # which is used solely as a Fantasy Grounds client (no inbound ports needed).
  lanInterfaces = [
    "enp129s0"
    "wlp130s0"
  ];
  kdeConnect = [
    {
      from = 1714;
      to = 1764;
    }
  ];
  lanPorts = {
    allowedTCPPorts = [
      # ALVR
      9943
      9944
      # Steam Remote Play
      27036
      27037
    ];
    allowedUDPPorts = [
      # ALVR
      9943
      9944
      # Steam Remote Play
      10400
      10401
      27036
    ];
    allowedTCPPortRanges = kdeConnect;
    allowedUDPPortRanges = kdeConnect ++ [
      # Steam Remote Play
      {
        from = 27031;
        to = 27035;
      }
    ];
  };
in
{
  networking = {
    networkmanager.enable = true;

    firewall.interfaces = lib.genAttrs lanInterfaces (_: lanPorts);
  };
}
