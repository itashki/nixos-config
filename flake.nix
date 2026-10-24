{
  description = "Modular NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    discordify.url = "github:itashki/discordify";
    discordify.inputs.nixpkgs.follows = "nixpkgs";
    relaksacher.url = "github:itashki/relaksacher";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      discordify,
      relaksacher,
      agenix,
      ...
    }:
    let
      localSettings = import ./hosts/nixos/settings.nix;
    in
    {
      packages.x86_64-linux.agenix = agenix.packages.x86_64-linux.default;

      nixosConfigurations = {
        ${localSettings.hostName} = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit localSettings agenix relaksacher; };
          modules = [
            ./configuration.nix
            ./hosts/nixos/default.nix
            ./hardware-configuration.nix
            discordify.nixosModules.default
            relaksacher.nixosModules.default
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            ./modules/home-manager.nix
          ];
        };
      };
    };
}
