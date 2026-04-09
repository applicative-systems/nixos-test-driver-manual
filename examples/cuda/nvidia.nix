{
  imports = [ ./generic.nix ];

  containers.container = {
    virtualisation.systemd-nspawn.options = [
      "--bind=/dev/nvidia-modeset:/dev/nvidia-modeset"
      "--bind=/dev/nvidia-uvm-tools:/dev/nvidia-uvm-tools"
      "--bind=/dev/nvidiactl:/dev/nvidiactl"
      "--bind=/dev/nvidia-uvm:/dev/nvidia-uvm"
      "--bind=/dev/nvidia0:/dev/nvidia0"
      "--bind=/dev/nvidiactl:/dev/nvidiactl"
    ];
  };
}
