#!/usr/bin/env bash
set -euo pipefail

# Edit only encrypted files in the working checkout, never in the Nix store.
config_dir="${NIXOS_CONFIG_DIR:-$HOME/.nixos-config}"
identity="${AGENIX_IDENTITY:-$HOME/.ssh/id_ed25519}"

if [[ $# -gt 1 ]]; then
  echo "Usage: edit-secret [name]" >&2
  exit 2
fi
if [[ ${1:-} == --help || ${1:-} == -h ]]; then
  echo "Usage: edit-secret [name]"
  echo "Without a name, choose a secret from a menu. The .age suffix is optional."
  echo "Overrides: NIXOS_CONFIG_DIR, AGENIX_IDENTITY, EDITOR."
  exit 0
fi

cd "$config_dir/secrets"
export AGENIX_RULES="$PWD/agenix-rules.nix"
if [[ ! -f $AGENIX_RULES || ! -r $identity ]]; then
  echo "Rules or SSH identity unavailable: $AGENIX_RULES, $identity" >&2
  exit 1
fi

if [[ $# == 0 ]]; then
  shopt -s nullglob
  secrets=(*.age)
  if [[ ${#secrets[@]} == 0 ]]; then
    echo "No encrypted secrets found." >&2
    exit 1
  fi
  PS3="Choose a secret (Ctrl+C to cancel): "
  select secret in "${secrets[@]}"; do
    if [[ -n $secret ]]; then
      break
    fi
    echo "Choose a number from the menu." >&2
  done
  [[ -n ${secret:-} ]] || exit 0
else
  secret="${1%.age}.age"
fi

if [[ $secret == */* || ! -f $secret ]]; then
  echo "Unknown secret: $secret" >&2
  exit 2
fi
export EDITOR="${EDITOR:-vim}"
exec nix run "$config_dir#agenix" -- -e "$secret" -i "$identity"
