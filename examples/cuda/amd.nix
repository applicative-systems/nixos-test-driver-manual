{
  imports = [ ./generic.nix ];

  requiredFeatures.amd-gpu = true; # (1)

  containers.container = {
    virtualisation.systemd-nspawn.options = [
      "--bind=/dev/kfd:/dev/kfd"
      "--bind=/sys/devices/virtual/kfd:/sys/devices/virtual/kfd"
    ];
  };
}
