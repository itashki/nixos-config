{ lib, pkgs, ... }:
let
  # Change the city here, then apply the configuration.
  weatherCity = "Beer Sheva, Israel";
  weatherScript = pkgs.writeShellApplication {
    name = "waybar-weather";
    runtimeInputs = [ pkgs.curl pkgs.jq ];
    text = ''
      city=${lib.escapeShellArg weatherCity}
      encoded_city=$(jq -rn --arg city "$city" '$city | @uri')
      if response=$(curl --fail --silent --show-error --connect-timeout 5 --max-time 20 \
        "https://wttr.is/$encoded_city?format=j1&m&lang=ru") &&
        result=$(jq -ce --arg city "$city" '
          .current_condition[0] as $c |
          if $c.temp_C == null then error("Missing temperature") else
          {
            text: ($c.temp_C + "°C"),
            tooltip: ($city + "\n" + ($c.lang_ru[0].value // $c.weatherDesc[0].value // "") +
              "\nОщущается: " + $c.FeelsLikeC + "°C" +
              "\nВлажность: " + $c.humidity + "%" +
              "\nВетер: " + $c.windspeedKmph + " км/ч"),
            class: "available"
          } end' <<< "$response"); then
        printf '%s\n' "$result"
      else
        jq -cn --arg city "$city" \
          '{text: "WX --", tooltip: ($city + ": погода недоступна"), class: "unavailable"}'
      fi
    '';
  };
in
{
  imports = [ ./modules/secret-tools.nix ];

  # Версия совместимости Home Manager, не повышается при обычном обновлении.
  home.stateVersion = "24.11";

  fonts.fontconfig.enable = true;

  xdg.configFile."niri/config.kdl".source = ./config/niri/config.kdl;

  xdg.desktopEntries.codex = {
    name = "Codex";
    comment = "Open Codex CLI in Ghostty";
    exec = "${pkgs.ghostty}/bin/ghostty -e ${pkgs.codex}/bin/codex";
    icon = "utilities-terminal";
    categories = [ "Development" ];
    terminal = false;
  };

  # Allow Vulkan copies between GPUs in KWin on hybrid graphics systems.
  xdg.configFile."environment.d/90-kwin-mgpu.conf".text = ''
    KWIN_ALLOW_VULKAN_MGPU_COPIES=1
  '';

  # Avoid the Ghostty 1.3.1 startup race with systemd's reload-handler check.
  xdg.configFile."systemd/user/app-com.mitchellh.ghostty.service.d/startup.conf".text = ''
    [Service]
    Type=notify
    ExecReload=${pkgs.coreutils}/bin/kill -USR2 $MAINPID
  '';

  home.sessionVariables.TERMINAL = "ghostty";
  home.activation.setDefaultTerminal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key TerminalApplication ghostty
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop
  '';

  # Готовые пакеты сохраняют патчи Nixpkgs; адаптеры для plugins.src не нужны.
  home.packages = with pkgs.fishPlugins; [
    (pkgs.writeShellApplication {
      name = "brightness-all";
      runtimeInputs = [ pkgs.brightnessctl pkgs.ddcutil pkgs.util-linux pkgs.gawk ];
      text = ''
        case "''${1:-}" in
          up) backlight_change="+10%"; ddc_direction="+" ;;
          down) backlight_change="10%-"; ddc_direction="-" ;;
          *) echo "Usage: brightness-all up|down" >&2; exit 2 ;;
        esac

        # Keep slow DDC requests from piling up on key repeat.
        exec 9>"''${XDG_RUNTIME_DIR:?}/brightness-all.lock"
        flock -n 9 || exit 0

        brightnessctl --class=backlight --device=intel_backlight set "$backlight_change"
        # Detect DDC-capable displays, including NVIDIA HDMI connections.
        while IFS= read -r bus; do
          ddcutil --bus "$bus" setvcp 10 "$ddc_direction" 10 || true
        done < <(ddcutil detect --brief | awk '/I2C bus:/ {sub("/dev/i2c-", "", $NF); print $NF}')
      '';
    })
    pkgs.fira-code
    fzf-fish
    done
    pure
    puffer
    bass
  ];

  programs = {
    waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 4;
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/weather" "network" "bluetooth" "backlight" "pulseaudio" "battery" "niri/language" "tray" ];
        "custom/weather" = {
          exec = "${weatherScript}/bin/waybar-weather";
          return-type = "json";
          interval = 900;
          escape = true;
        };
        "niri/workspaces".format = "{index}";
        "niri/window".max-length = 36;
        clock = {
          format = "{:%H:%M}";
          tooltip-format = "{:%d.%m.%Y}";
        };
        network = {
          format-wifi = "Wi-Fi {signalStrength}%";
          format-ethernet = "LAN";
          format-disconnected = "Offline";
          tooltip-format = "{ifname}: {ipaddr}";
        };
        bluetooth = {
          format = "BT {status}";
          format-on = "BT ON";
          format-off = "BT OFF";
          format-disabled = "BT OFF";
          format-no-controller = "BT N/A";
          format-connected = "BT {num_connections}";
          tooltip-format = "Bluetooth: {status}";
          tooltip-format-connected = "{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
          on-click = "${pkgs.kdePackages.systemsettings}/bin/systemsettings kcm_bluetooth";
        };
        backlight = {
          device = "intel_backlight";
          format = "BRT {percent}%";
          tooltip-format = "Laptop brightness: {percent}% — scroll to adjust all screens";
          on-scroll-up = "brightness-all up";
          on-scroll-down = "brightness-all down";
        };
        pulseaudio = {
          format = "VOL {volume}%";
          format-muted = "MUTE";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step = 5;
        };
        battery = {
          format = "BAT {capacity}%";
          format-charging = "BAT +{capacity}%";
          states = { warning = 20; critical = 10; };
        };
        "niri/language" = {
          format = "{short}";
          format-en = "EN";
          format-ru = "RU";
          format-he = "HE";
        };
        tray.spacing = 10;
      };
      style = ''
        * {
          font-family: "Fira Code", sans-serif;
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }
        window#waybar {
          background: #202326;
          color: #e5e7eb;
          border-bottom: 1px solid #363b40;
        }
        #workspaces button {
          padding: 0 10px;
          color: #9ca3af;
          background: transparent;
        }
        #workspaces button.active { color: #e5e7eb; }
        #workspaces button.focused {
          color: #93c5fd;
          background: #303943;
          box-shadow: inset 0 -2px #93c5fd;
        }
        #workspaces button:hover { background: #363b40; }
        #window { padding: 0 12px; color: #9ca3af; }
        #clock, #custom-weather, #network, #bluetooth, #backlight, #pulseaudio, #battery, #language, #tray {
          padding: 0 10px;
        }
        #language { color: #93c5fd; }
        #custom-weather.unavailable { color: #9ca3af; }
        #bluetooth.connected { color: #93c5fd; }
        #bluetooth.off, #bluetooth.disabled { color: #9ca3af; }
        #network.disconnected, #battery.warning { color: #fbbf24; }
        #battery.critical { color: #f87171; }
        tooltip { background: #202326; color: #e5e7eb; }
      '';
    };
    # CLI-инструменты: модули позволяют добавлять настройки без дублирования пакетов.
    bat.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    htop.enable = true;
    yt-dlp.enable = true;
    codex.enable = true;
    ghostty = {
      enable = true;
      settings = {
        theme = "Adwaita Dark";
        font-family = "Fira Code";
        font-feature = [
          "calt"
          "liga"
        ];
      };
    };

    fzf = {
      enable = true;
      enableFishIntegration = false;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
    };

    java = {
      enable = true;
      package = pkgs.javaPackages.compiler.openjdk25;
    };
    bun.enable = true;
    distrobox.enable = true;

    element-desktop.enable = true;
    vesktop.enable = true;
    libreoffice.enable = true;
    prismlauncher.enable = true;

    home-manager.enable = true;

    vim.enable = true;
    git = {
      enable = true;

      settings = {
        url."git@github.com:".insteadOf = "https://github.com/";
      };

      signing.format = "openpgp";
    };

    mpv.enable = true;

    librewolf.enable = true;
    chromium.enable = true;

    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
  };
  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
