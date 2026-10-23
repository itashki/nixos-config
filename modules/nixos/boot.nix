{ ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        edk2-uefi-shell = {
          enable = true;
          sortKey = "z_edk2";
        };
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
