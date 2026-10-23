# Шаблон: скопируйте в secrets/ и настройте для своей машины.
# Персональные данные Home Manager.
{ localSettings, ... }:
{
  home = {
    username = localSettings.username;
    homeDirectory = "/home/${localSettings.username}";
  };

  programs.git.settings = {
    user = {
      name = "Your Name";
      email = "you@example.org";
    };
  };
}
