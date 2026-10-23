{ config, ... }:
{
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  age.secrets.git-identity = {
    file = ../secrets/git-identity.age;
    path = "${config.home.homeDirectory}/.config/git/identity";
  };

  programs.git.includes = [ { path = config.age.secrets.git-identity.path; } ];
}
