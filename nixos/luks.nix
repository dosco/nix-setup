{config, ...}:
{
  boot.initrd.luks.devices = {
    "env-pv" = {
        device = "/dev/vda2";
        preLVM = true;
    };
  };
}
