{config, ...}:
{
  boot.initrd.luks.devices = {
    rootdev = {
        device = "/dev/vda2";
        preLVM = true;
    };
  };
}
