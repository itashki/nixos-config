{ localSettings, ... }:
{
  home = {
    username = localSettings.username;
    homeDirectory = "/home/${localSettings.username}";
  };

}
