{ pkgs, ... }:
{
  hardware = {
    i2c.enable = true;
    bluetooth.enable = true;

    graphics.enable = true;
    graphics.enable32Bit = true;
    graphics.extraPackages = [ pkgs.intel-media-driver ];

    nvidia = {
      open = true;
      modesetting.enable = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
      nvidiaSettings = true;

      powerManagement.enable = true;
      nvidiaPersistenced = true;
    };
  };
}
