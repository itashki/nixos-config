{ localSettings, agenix, ... }:
{
  home-manager = {
    extraSpecialArgs = { inherit localSettings; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${localSettings.username} = {
      imports = [
        ../home.nix
        ../hosts/nixos/home.nix
        agenix.homeManagerModules.default
        ../modules/home-secrets.nix
      ];
    };
  };
}
