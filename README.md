# NixOS configuration

Модульная конфигурация NixOS с локальными настройками вне Git.

## Структура

| Файл | Назначение |
| --- | --- |
| `flake.nix` | Источники зависимостей и сборка конфигурации хоста |
| `flake.lock` | Зафиксированные версии зависимостей |
| `configuration.nix` | Список системных модулей, Nix, локаль и базовая безопасность |
| `hardware-configuration.nix` | Подключение локального аппаратного конфига из `secrets/` |
| `modules/nixos/boot.nix` | Загрузчик, Windows и UEFI shell |
| `modules/nixos/networking.nix` | NetworkManager и firewall |
| `modules/nixos/hardware.nix` | Bluetooth, графика и NVIDIA PRIME |
| `modules/nixos/desktop.nix` | Plasma, экран входа, звук, Flatpak и мышь |
| `modules/nixos/services.nix` | Ollama с CUDA |
| `modules/nixos/virtualisation.nix` | Podman и libvirt |
| `modules/nixos/users.nix` | Системный пользователь, группы и shell |
| `modules/nixos/programs.nix` | Системная интеграция программ |
| `modules/nixos/nix-ld.nix` | Библиотеки для сторонних бинарников и обходной путь для SVG loader |
| `packages/user.nix` | Пакеты пользователя |
| `modules/home-manager.nix` | Подключение Home Manager к NixOS |
| `home.nix` | Пользовательские настройки программ через Home Manager |

Новые настройки добавляйте в соответствующий модуль. Новый системный модуль
подключайте в `configuration.nix`. Аппаратные настройки находятся в `secrets/hardware-configuration.nix`.

## Проверка и применение

В каталоге конфигурации:

```sh
nix flake check --no-update-lock-file path:.
nix eval --no-write-lock-file path:.#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
sudo nixos-rebuild switch --flake path:.#nixos
```

`path:.` явно выбирает файлы текущего каталога, в том числе если они ещё не
добавлены в Git. Проверка вычисления не заменяет сборку и проверку на машине.
Команда `switch` применяет конфигурацию; запускайте её после проверки изменений.

`system.stateVersion` и `home.stateVersion` сохранены: их не следует менять
при обычном обновлении пакетов. Зависимости обновляются отдельно через
`nix flake update`.

## Локальные настройки вне Git

Каталог `secrets/` исключён через `.gitignore` и обязателен для сборки:

| Файл | Содержимое |
| --- | --- |
| `secrets/default.nix` | Имя пользователя и хоста (также имя flake-конфигурации) |
| `secrets/nixos.nix` | Имя хоста, ZeroTier, Windows, PCI-адреса GPU и описание пользователя |
| `secrets/home.nix` | Имя пользователя, домашний каталог, Git-имя и почта |
| `secrets/hardware-configuration.nix` | Диски, UUID, модули ядра и аппаратная платформа |
| `examples/local-settings/` | Публичные шаблоны без персональных данных |

На новой машине создайте локальный каталог из шаблонов:

```sh
install -d -m 700 secrets
cp examples/local-settings/*.nix secrets/
chmod 600 secrets/*.nix
```

Замените значения в шаблонах своими. Аппаратный конфиг лучше получить через
`nixos-generate-config --show-hardware-config` и сохранить в
`secrets/hardware-configuration.nix`. Проверьте PCI-адреса, запись Windows,
сеть ZeroTier перед применением. Локаль, часовой пояс, раскладка и
`system.stateVersion` заданы в `configuration.nix`, `home.stateVersion` — в
`home.nix`, открытые порты — в `modules/nixos/networking.nix`, группы
пользователя — в `modules/nixos/users.nix`. При переносе на другую машину
сверяйте версии состояния с её существующей конфигурацией.

Команды выше используют текущее имя конфигурации `nixos`. Если измените
`hostName` в `secrets/default.nix`, замените его и в командах.
Используйте именно `path:.`: Git-flake не включает игнорируемые файлы.
Сохраняйте резервную копию `secrets/` отдельно от репозитория.

Это разделение для публикации общего конфига, а не защищённое хранилище:
`path:.` копирует локальные файлы в `/nix/store`, доступный другим локальным
пользователям. Пароли, приватные ключи и токены сюда помещать нельзя;
для них нужен отдельный механизм вроде sops-nix или agenix.
`.gitignore` не удаляет файлы из истории Git, если они уже были опубликованы.
