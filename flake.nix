{
  description = "Modular NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    discordify.url = "github:itashki/discordify";
    discordify.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      discordify,
      ...
    }:
    let
      # secrets/ отсутствует в Git, но нужен при локальном вычислении flake.
      localSettings = import ./secrets/default.nix;
    in
    {
      nixosConfigurations = {
        ${localSettings.hostName} = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit localSettings; };
          modules = [
            ./configuration.nix
            ./secrets/nixos.nix
            ./hardware-configuration.nix
            discordify.nixosModules.default
            home-manager.nixosModules.home-manager
            ./modules/home-manager.nix
          ];
        };
      };
    };
}
