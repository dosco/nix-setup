{config, ...}:
{
  boot.initrd.luks.devices = [{
    name = "rootdev";
    device = "/dev/vda2";
    preLVM = true;
  }];
}
