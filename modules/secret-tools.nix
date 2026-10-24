{ pkgs, ... }:
let
  editSecret = pkgs.writeShellApplication {
    name = "edit-secret";
    runtimeInputs = [ pkgs.nix pkgs.vim ];
    text = builtins.readFile ../scripts/edit-secret.sh;
  };
  shortcut = name: secret: pkgs.writeShellApplication {
    inherit name;
    text = ''
      exec ${editSecret}/bin/edit-secret ${secret} "$@"
    '';
  };
in
{
  home.packages = [
    editSecret
    (shortcut "edit-facts" "relaksacher-facts")
    (shortcut "edit-personality" "relaksacher-personality")
    (shortcut "edit-git-identity" "git-identity")
  ];
}
