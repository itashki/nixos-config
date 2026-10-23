{ ... }:
{
  hardware = {
    bluetooth.enable = true;

    graphics.enable = true;
    graphics.enable32Bit = true;

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
