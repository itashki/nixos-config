{ pkgs, localSettings, ... }:
{
  users.users.${localSettings.username} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
    ];
    shell = pkgs.fish;
    packages = import ../../packages/user.nix { inherit pkgs; };
  };
}
