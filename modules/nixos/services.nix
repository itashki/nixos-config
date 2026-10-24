{
  config,
  pkgs,
  localSettings,
  ...
}:
{
  age.identityPaths = [ "/home/${localSettings.username}/.ssh/id_ed25519" ];
  age.secrets = {
    relaksacher-environment = {
      file = ../../secrets/relaksacher-environment.age;
      owner = "root";
      mode = "0400";
    };
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
      environmentFile = config.age.secrets.relaksacher-environment.path;
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
