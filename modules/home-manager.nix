{ localSettings, ... }:
{
  home-manager = {
    extraSpecialArgs = { inherit localSettings; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${localSettings.username} = {
      imports = [
        ../home.nix
        ../secrets/home.nix
      ];
    };
  };
}
