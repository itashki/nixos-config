# Правила CLI agenix; содержит только публичные ключи.
let
  recipients = import ./recipients.nix;
in
{
  "git-identity.age".publicKeys = recipients;
  "wireguard-pc.age".publicKeys = recipients;
  "relaksacher-source-directory.age".publicKeys = recipients;
}
