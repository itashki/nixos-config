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
| `packages/user.nix` | Пакеты пользователя |
| `modules/home-manager.nix` | Интеграция Home Manager и agenix |
| `home.nix` | Пользовательские программы и home.stateVersion |
| `modules/home-secrets.nix` | Расшифровка Git identity и подключение к Git |
| `secrets/git-identity.age` | Зашифрованные Git-имя и email |
| `secrets/secrets.nix`, `secrets/recipients.nix` | Правила agenix и публичные ключи получателей |

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

## Секреты agenix

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

Для новых секретов добавляйте правила в `secrets/secrets.nix`, создавайте `.age`
через CLI и подключайте путь расшифрованного файла к программе или службе.
Не используйте `builtins.readFile` для расшифрованных секретов.
При смене ключей обновите `secrets/recipients.nix` и выполните из `secrets/`
`nix run ..#agenix -- -r -i ~/.ssh/id_ed25519`, пока старый ключ ещё доступен.

На новой машине нужен соответствующий приватный ключ; без него расшифровка
не работает. Сохраните резервную копию ключа отдельно от репозитория.
Метаданные Git-коммитов (включая автора и email) остаются открытыми независимо
от шифрования пользовательского конфига.
