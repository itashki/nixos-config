{ config, pkgs, localSettings, relaksacher, ... }:
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

  # Copy existing local models outside the private login home at activation/boot.
  # C preserves an existing destination; remove it explicitly when replacing a model.
  systemd.tmpfiles.rules = [
    "d /var/lib/relaksacher/models 0750 relaksacher relaksacher -"
    "C /var/lib/relaksacher/models/ggml-small.bin 0440 relaksacher relaksacher - /home/${localSettings.username}/ai/ggml-small.bin"
    "C /var/lib/relaksacher/models/silero-v5_6_ru.pt 0440 relaksacher relaksacher - /home/${localSettings.username}/ai/piper-voices/silero-v5_6_ru.pt"
    "C /var/lib/relaksacher/models/silero-v3_en.pt 0440 relaksacher relaksacher - /home/${localSettings.username}/ai/piper-voices/silero-v3_en.pt"
  ];

  services = {
    relaksacher = {
      enable = true;
      # Read agenix data directly instead of invoking Bun's module resolver.
      package = relaksacher.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ../../patches/relaksacher-config-paths.patch
          ../../patches/relaksacher-tui-render.patch
        ];
      });
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
