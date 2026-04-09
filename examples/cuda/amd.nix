{
  imports = [ ./generic.nix ];

  containers.container = {
    virtualisation.systemd-nspawn.options = [
      "--bind=/dev/kfd:/dev/kfd"
      "--bind=/sys/devices/virtual/kfd:/sys/devices/virtual/kfd"
    ];
  };
}
