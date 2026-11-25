{
  config,
  pkgs,
  localSettings,
  llamaCppPrism,
  ...
}:
{
  age.identityPaths = [ "/home/${localSettings.username}/.ssh/id_ed25519" ];
  age.secrets.relaksacher-source-directory = {
    file = ../../secrets/relaksacher-source-directory.age;
    owner = "root";
    mode = "0400";
  };

  environment.systemPackages = [ llamaCppPrism ];
  systemd.tmpfiles.rules = [ "d /var/lib/llama-models 0755 ${localSettings.username} users -" ];

  services = {
    relaksacher = {
      enable = true;
      sourceDirectory = "/run/relaksacher-checkout/source";
      sourceExecutable = "dist/relaksacher";
      environmentFile = "/run/relaksacher-checkout/source/.env";
      operators = [ localSettings.username ];
      environment = {
        FACTS_FILE = "/run/relaksacher/source/facts.json5";
        PERSONALITY_FILE = "/run/relaksacher/source/personality.json5";
        LLAMA_MODEL = "/var/lib/llama-models/Ternary-Bonsai-2.5-27B-Uncensored-PTQ1_0.gguf";
        LLAMA_MMPROJ = "/var/lib/llama-models/Ternary-Bonsai-2.5-27B-mmproj-Q8_0.gguf";
        OLLAMA_NUM_CTX = "8192";
      };
    };
  };

  # Only root sees the real checkout location, decrypted at runtime by agenix.
  systemd.services.relaksacher-source = {
    description = "Resolve the private Relaksacher checkout location";
    before = [ "relaksacher.service" ];
    restartTriggers = [ config.age.secrets.relaksacher-source-directory.file ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "relaksacher-checkout";
      RuntimeDirectoryMode = "0700";
      UMask = "0077";
      ExecStart = pkgs.writeShellScript "relaksacher-source" ''
        set -eu
        IFS= read -r source < ${config.age.secrets.relaksacher-source-directory.path}
        case "$source" in
          /*) ;;
          *) echo "Invalid checkout location secret" >&2; exit 1 ;;
        esac
        if [ ! -x "$source/dist/relaksacher" ] || [ ! -r "$source/scripts/silero-tts.py" ] || [ ! -r "$source/scripts/gigaam-server.py" ]; then
          echo "Local executable or speech scripts unavailable; run the project build" >&2
          exit 1
        fi
        ${pkgs.coreutils}/bin/ln -sfnT -- "$source" "$RUNTIME_DIRECTORY/source"
      '';
    };
  };

  systemd.services.relaksacher = {
    path = [
      llamaCppPrism
      pkgs.ffmpeg
    ];
    requires = [ "relaksacher-source.service" ];
    after = [ "relaksacher-source.service" ];
    partOf = [ "relaksacher-source.service" ];
    # The standalone binary embeds Bun with JIT; executable memory must remain allowed.
    serviceConfig.MemoryDenyWriteExecute = false;
    # Keep Nix-managed speech models/Python instead of development paths in .env.
    serviceConfig.UnsetEnvironment = [
      "WHISPER_MODEL"
      "GIGAAM_PYTHON"
      "GIGAAM_MODEL_DIR"
      "SILERO_MODEL"
      "SILERO_MODEL_EN"
      "SILERO_PYTHON"
    ];
  };
}
