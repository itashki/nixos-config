{ config, ... }:
{
  age.secrets.wireguard-pc.file = ../../secrets/wireguard-pc.age;

  # Private tunnel via the VPS hub: VPS 10.8.0.1, this PC 10.8.0.2, phone 10.8.0.3.
  # Phone SSH: ssh -p 22222 ktrd@10.8.0.2 (user service phone-sshd).
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.8.0.2/24" ];
    privateKeyFile = config.age.secrets.wireguard-pc.path;
    peers = [
      {
        publicKey = "WOzharqh/EWARQqPzd1a7SRDhu/0oBe2fpwGEoosUFI=";
        endpoint = "193.181.210.149:51820";
        allowedIPs = [ "10.8.0.0/24" ];
        # Keep the NAT mapping open so the phone can reach the PC at any time.
        persistentKeepalive = 25;
      }
    ];
  };

  networking.networkmanager.unmanaged = [ "wg0" ];

  # Only tunnel peers can reach the key-only phone SSH.
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22222 ];
}
