{
  config,
  pkgs,
  localSettings,
  ...
}:
{
  age.identityPaths = [ "/home/${localSettings.username}/.ssh/id_ed25519" ];
  age.secrets.relaksacher-source-directory = {
    file = ../../secrets/relaksacher-source-directory.age;
    owner = "root";
    mode = "0400";
  };
  age.secrets.sunshine-frp.file = ../../secrets/sunshine-frp.age;

  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      settings = {
        capture = "kwin"; # Avoid the XDG portal startup/shutdown hang on Plasma.
        output_name = "eDP-1";
        # Encode on the screen's Intel GPU to avoid cross-GPU DMA-BUF import failures.
        encoder = "vaapi";
        # shortcut: render node numbering can change, recheck after GPU/driver changes.
        adapter_name = "/dev/dri/renderD128";
        origin_web_ui_allowed = "pc";
        external_ip = "193.181.210.149";
        # FRP connections arrive via loopback, including Internet clients.
        lan_encryption_mode = 2;
        wan_encryption_mode = 2;
      };
      applications.apps = [ { name = "Desktop"; } ];
    };
    frp.instances.sunshine = {
      enable = true;
      role = "client";
      environmentFiles = [ config.age.secrets.sunshine-frp.path ];
      settings = {
        serverAddr = "193.181.210.149";
        serverPort = 7000;
        auth.token = "{{ .Envs.FRP_TOKEN }}";
        transport.tls.enable = true;
        proxies =
          map
            (port: {
              name = "ktrd-sunshine-tcp-${toString port}";
              type = "tcp";
              localIP = "127.0.0.1";
              localPort = port;
              remotePort = port;
            })
            [
              47984
              47989
              48010
            ]
          ++
            map
              (port: {
                name = "ktrd-sunshine-udp-${toString port}";
                type = "udp";
                localIP = "127.0.0.1";
                localPort = port;
                remotePort = port;
              })
              [
                47998
                47999
                48000
                48002
                48010
              ];
      };
    };
    relaksacher = {
      enable = true;
      sourceDirectory = "/run/relaksacher-checkout/source";
      sourceExecutable = "dist/relaksacher";
      environmentFile = "/run/relaksacher-checkout/source/.env";
      operators = [ localSettings.username ];
      environment = {
        FACTS_FILE = "/run/relaksacher/source/facts.json5";
        PERSONALITY_FILE = "/run/relaksacher/source/personality.json5";
      };
    };
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
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
