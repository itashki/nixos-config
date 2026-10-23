{ pkgs, localSettings, ... }:
{
  users.users.${localSettings.username} = {
    isNormalUser = true;
    # Доступ к управлению сетью, sudo и виртуализации.
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
