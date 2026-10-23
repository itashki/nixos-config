# Домашний каталог пользователя; Git identity подключается из agenix.
{ localSettings, ... }:
{
  home = {
    username = localSettings.username;
    homeDirectory = "/home/${localSettings.username}";
  };

}
