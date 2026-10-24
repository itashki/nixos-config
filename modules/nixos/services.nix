{ config, pkgs, localSettings, ... }:
{
  age.identityPaths = [ "/home/${localSettings.username}/.ssh/id_ed25519" ];
  age.secrets = {
    relaksacher-facts = {
      file = ../../secrets/relaksacher-facts.age;
      owner = "relaksacher";
      mode = "0400";
    };
    relaksacher-personality = {
      file = ../../secrets/relaksacher-personality.age;
      owner = "relaksacher";
      mode = "0400";
    };
  };

  services = {
    relaksacher = {
      enable = true;
      environmentFile = "/etc/relaksacher/environment";
      operators = [ localSettings.username ];
      environment = {
        FACTS_FILE = config.age.secrets.relaksacher-facts.path;
        PERSONALITY_FILE = config.age.secrets.relaksacher-personality.path;
      };
    };
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  };
}
