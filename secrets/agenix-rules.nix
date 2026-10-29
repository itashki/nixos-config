# Правила CLI agenix; содержит только публичные ключи.
let
  recipients = import ./recipients.nix;
in
{
  "git-identity.age".publicKeys = recipients;
  "relaksacher-environment.age".publicKeys = recipients;
  "relaksacher-source-directory.age".publicKeys = recipients;
  "relaksacher-facts.age".publicKeys = recipients;
  "relaksacher-personality.age".publicKeys = recipients;
}
