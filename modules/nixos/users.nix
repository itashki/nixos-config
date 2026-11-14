{ pkgs, localSettings, ... }:
{
  users.users.${localSettings.username} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "i2c"
    ];
    shell = pkgs.fish;
    packages = import ../../packages/user.nix { inherit pkgs; };
  };
}
