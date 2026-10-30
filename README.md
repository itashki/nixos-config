# NixOS configuration

Модульная конфигурация NixOS. Настройки машины хранятся в Git,
пользовательские данные Git зашифрованы через agenix.

## Структура

| Файл | Назначение |
| --- | --- |
| `flake.nix`, `flake.lock` | Сборка системы и зафиксированные зависимости |
| `configuration.nix` | Системные модули, Nix, локаль, безопасность и system.stateVersion |
| `hosts/nixos/settings.nix` | Имя пользователя и хоста |
| `hosts/nixos/default.nix` | ZeroTier, Windows, PCI-адреса GPU и описание пользователя |
| `hosts/nixos/home.nix` | Имя пользователя и домашний каталог Home Manager |
| `hardware-configuration.nix` | Диски, UUID, модули ядра и аппаратная платформа |
| `modules/nixos/` | Загрузчик, сеть, рабочий стол, оборудование, службы и программы |
| `modules/nixos/networking.nix` | NetworkManager и входящие порты firewall |
| `modules/nixos/users.nix` | Права, группы и shell пользователя |
| `packages/user.nix` | Пакеты без подходящего модуля NixOS/Home Manager |
| `modules/home-manager.nix` | Интеграция Home Manager и agenix |
| `home.nix` | Пользовательские программы через опции Home Manager, плагины Fish и home.stateVersion |
| `modules/home-secrets.nix` | Расшифровка Git identity и подключение к Git |
| `secrets/git-identity.age` | Зашифрованные Git-имя и email |
| `secrets/agenix-rules.nix`, `secrets/recipients.nix` | Правила agenix и публичные ключи получателей |

Имена хоста и пользователя, UUID дисков, PCI-адреса и сеть ZeroTier нужны
при вычислении Nix и доступны в Git. Git identity читается Git из отдельного
файла во время работы и поэтому может быть зашифрован через agenix.
Сетевой идентификатор ZeroTier не является ключом авторизации в сети.

## Проверка и применение

```sh
nix flake check --no-update-lock-file
nix eval --no-write-lock-file .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
sudo nixos-rebuild switch --flake .#nixos
```

Игнорируемые локальные Nix-файлы больше не нужны: обычный `--flake .` работает.
При добавлении новых файлов сначала добавляйте их в Git, чтобы flake их видел.
Для обновления зависимостей запускайте `nix flake update` без sudo.
`system.stateVersion` и `home.stateVersion` не повышайте при обычном обновлении.

## Графические сессии

В Ly доступны KDE Plasma (по умолчанию) и Niri. После применения конфигурации
выйдите из текущей сессии и выберите Niri в Ly. Стандартные сочетания Niri:
`Super+T` — Alacritty, `Super+D` — Fuzzel, `Super+Alt+L` — блокировка
через Swaylock, `Super+Shift+E` — выход. Ghostty также остаётся доступен.
Пользовательские настройки Niri находятся в `~/.config/niri/config.kdl`.

В Niri запускаются помощник разблокировки KWallet, KDE NetworkManager agent
через `kded6` и агент Polkit. Пароли Wi-Fi используются из того же кошелька,
что и в Plasma. Для автоматической разблокировки пароль кошелька должен
совпадать с паролем входа через Ly. GNOME Keyring отключён, портал секретов
Niri использует KWallet.

Установлены Waybar, brightnessctl и Xwayland Satellite (Niri запускает его
по требованию). Codex можно открыть через `Super+D` → `Codex` в Ghostty
или командой `codex` в терминале. Браузеры и порталы выбора файлов/демонстрации
экрана доступны в обеих сессиях.

Для гибридной графики Home Manager задаёт `KWIN_ALLOW_VULKAN_MGPU_COPIES=1`
в `~/.config/environment.d/90-kwin-mgpu.conf`. После применения настройки
нужно выйти из Plasma и войти снова.

## Релаксачер

Input `relaksacher` предоставляет Nix-модуль, зависимости и модели речи.
Сам бот запускается из локальной AOT-сборки `dist/relaksacher`: проект
сервис видит только для чтения через `/run/relaksacher/source`.
В Nix store локальный бинарник и настройки не копируются.
Домашний каталог остаётся закрытым; монтирование существует только внутри сервиса.
Настройка находится в `modules/nixos/services.nix`.

Настоящий путь к проекту хранится только в зашифрованном секрете
`secrets/relaksacher-source-directory.age`. Перед запуском root читает его
и создаёт ссылку в закрытом каталоге `/run/relaksacher-checkout` (права `0700`).
В открытом конфиге, unit-файлах и Nix store нет настоящего пути.
Для изменения расположения отредактируйте этот секрет через `edit-secret
relaksacher-source-directory` и примените конфигурацию.

systemd перед каждым запуском читает `.env` проекта от root.
Факты и личность читаются из `facts.json5` и `personality.json5` той же
рабочей папки. Содержимое этих файлов не включается в Nix store или Git.
Прежние `secrets/relaksacher-*.age` сохранены, но сервис больше их не использует;
команды `edit-facts` и `edit-personality` редактируют эти прежние зашифрованные
копии. Для действующих настроек редактируйте файлы непосредственно в проекте.

После правок кода пересоберите проект и перезапустите сервис:

```sh
# Из рабочего каталога проекта:
nix shell path:.#bun-canary --command bun run build
sudo systemctl restart relaksacher
```

После изменения `.env`, модели, личности или фактов достаточно только
`sudo systemctl restart relaksacher`.

Обновлять input и пересобирать NixOS для таких правок не требуется.
После изменения JS-зависимостей выполните `bun install` и AOT-сборку в проекте.
Сохраните `scripts/silero-tts.py`: Python запускает его из локального checkout.
Для изменений Nix-модуля, пакета запуска или системных зависимостей по-прежнему
нужны обновление input и `nixos-rebuild switch`. Мягкий рестарт из TUI не
перечитывает окружение systemd и в этом режиме не обновляет граф модулей.

Память и журнал остаются в `/var/lib/relaksacher`.
Whisper small и Silero v5_6_ru/v3_en предоставляет Nix-пакет, включая Python.
Сервис исключает `WHISPER_MODEL`, `SILERO_MODEL`, `SILERO_MODEL_EN`
и `SILERO_PYTHON` из локального `.env`, чтобы домашние пути разработки
не перекрывали доступные сервису модели и Python из пакета.

После подготовки секретов и данных примените конфигурацию обычной
командой выше. Проверка и подключение к панели:

```sh
systemctl status relaksacher
journalctl -u relaksacher -f
sudo -u relaksacher relaksacher tui
```

Перед запуском сервиса завершите ранее запущенный экземпляр бота с теми же
токенами. Закрытие панели клавишей `q` оставляет сервис работающим.

Пользовательские приложения с модулем подключаются через `programs.<имя>.enable`
в `home.nix`; остальные остаются в `packages/user.nix`. Плагины Fish задаются
через `home.packages` в `home.nix`: штатный vendor-механизм Fish в NixOS
загружает готовые пакеты с патчами Nixpkgs. Стандартная Fish-интеграция fzf
отключена в пользу
`fzf-fish`. Модуль Java сохраняет OpenJDK 25 и задаёт `JAVA_HOME`; модуль Bun
добавляет интеграцию Git для бинарных lock-файлов. Наличие серверного модуля
(например, для dnsmasq или qBittorrent) не заменяет установку CLI/GUI-клиента.

## Переход существующих настроек под Home Manager

Перед установкой управляемых файлов Home Manager сохраняет конфликтующие
обычные файлы с расширением `.before-home-manager`. Например, прежний
`~/.config/fish/config.fish` станет `~/.config/fish/config.fish.before-home-manager`.
Если такая резервная копия уже существует, сохраните её под другим именем
перед повторной активацией. Пользовательские настройки Fish в дальнейшем
добавляйте через `programs.fish` в `home.nix`.

## Секреты agenix

После применения конфигурации доступны команды из любой папки:

```sh
edit-secret                 # Выбор секрета из меню
edit-facts                  # Факты Релаксачера
edit-personality            # Личность Релаксачера
edit-git-identity           # Git identity
edit-secret git-identity    # Выбор по имени, суффикс .age необязателен
```

До применения можно запустить `bash ~/.nixos-config/scripts/edit-secret.sh`.
Редактор задаётся через `EDITOR` (по умолчанию Vim), каталог конфига — через
`NIXOS_CONFIG_DIR` (по умолчанию `~/.nixos-config`), ключ — через
`AGENIX_IDENTITY` (по умолчанию `~/.ssh/id_ed25519`). Скрипт явно задаёт
`AGENIX_RULES`, а agenix расшифровывает файл для редактирования и шифрует
после сохранения. Применение конфигурации и перезапуск служб выполняются отдельно.

Зашифрованные `.age` и публичные правила хранятся в Git. Прочие файлы в
`secrets/` игнорируются. Приватный SSH-ключ остаётся вне репозитория:
`~/.ssh/id_ed25519`. Его строковый путь используется при запуске пользовательской
службы agenix; ключ и расшифрованное содержимое не копируются в Nix store.

Home Manager подключает службу `agenix.service` к пользовательской сессии.
Она расшифровывает Git identity в пользовательский runtime-каталог и создаёт
ссылку `~/.config/git/identity`, которую читает Git. После первого переключения
проверьте службу; если она ещё не запущена, запустите её:

```sh
systemctl --user start agenix.service
systemctl --user status agenix.service
```

Для редактирования Git identity из корня репозитория:

```sh
cd secrets
nix run ..#agenix -- -e git-identity.age -i ~/.ssh/id_ed25519
```

Формат расшифрованного файла — Git config с секцией `[user]`, полями `name`
и `email`. После изменения снова примените конфигурацию и перезапустите
пользовательскую службу `agenix.service`.

Для новых секретов добавляйте правила в `secrets/agenix-rules.nix`, создавайте `.age`
через CLI и подключайте путь расшифрованного файла к программе или службе.
Не используйте `builtins.readFile` для расшифрованных секретов.
При смене ключей обновите `secrets/recipients.nix` и выполните из `secrets/`
`nix run ..#agenix -- -r -i ~/.ssh/id_ed25519`, пока старый ключ ещё доступен.

На новой машине нужен соответствующий приватный ключ; без него расшифровка
не работает. Сохраните резервную копию ключа отдельно от репозитория.
Метаданные Git-коммитов (включая автора и email) остаются открытыми независимо
от шифрования пользовательского конфига.
