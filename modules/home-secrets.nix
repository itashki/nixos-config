# Расшифровка пользовательских данных при запуске пользовательской службы agenix.
{ config, ... }:
{
  # Строковый путь: приватный ключ читается во время активации, не копируется в store.
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  age.secrets.git-identity = {
    file = ../secrets/git-identity.age;
    path = "${config.home.homeDirectory}/.config/git/identity";
  };

  # Git читает identity во время работы; plaintext не попадает в derivation.
  programs.git.includes = [ { path = config.age.secrets.git-identity.path; } ];
}
