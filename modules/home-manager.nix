{ localSettings, agenix, ... }:
{
  home-manager = {
    # При переходе на управление через HM сохраняем существующие файлы,
    # в частности ~/.config/fish/config.fish, вместо остановки активации.
    backupFileExtension = "before-home-manager";
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
