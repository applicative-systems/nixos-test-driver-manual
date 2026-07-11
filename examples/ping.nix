{ pkgs, ... }:
{
  name = "ping test";

  # changing the `nixpkgs....` settings witihin a VM necessitates
  # disabling this. Auto-enabled because evaluating pkgs only ONCE
  # for all systems is a good evaluation performance optimization.
  node.pkgsReadOnly = false;

  # pkgs.qemu_test is the default, which has specific nixos test runner
  # settings, but it also disables other cpu targets which we need now.
  qemu.package = pkgs.qemu;

  # The whole example here assumes that we're building and running this
  # test on an x86_64-linux machine.
  # of course we could set the hostPlatform in both VMs to be more
  # explicit or even portable in the sense that we could run this
  # on an aarch64-linux machine where machine1 is the software-emulated
  # one.
  nodes = {
    machine1 = { };
    machine2 = {
      nixpkgs = {
        # This setting makes the VM an aarch64 vm.
        # everything else around it is just follow-up to make it work.
        hostPlatform = "aarch64-linux";

        # real cross compilation or pseudo-crosscompilation with binfmt?
        # remove comment for real cross compilation
        #buildPlatform = pkgs.hostPlatform;
      };
    };
  };

  defaults = {
    # ongoing discussion if this should be default in the test driver
    networking.dhcpcd.enable = false;

    # fix the network-online target, otherwise it doesn't work
    # properly as a synchronization mechanism.
    systemd.targets.network-online = {
      wants = [ "network-addresses-eth1.service" ];
      after = [ "network-addresses-eth1.service" ];
    };
  };

  # beware of slower software emulation
  globalTimeout = 200;

  testScript = ''
    start_all()

    # First, start network-online.target
    machine1.systemctl("start network-online.target")
    machine2.systemctl("start network-online.target")

    # Wait for the network to be online
    # Otherwise, we could get errors like
    #   `ping: connect: Network is unreachable`
    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    machine1.succeed("ping -c 1 machine2")
    machine2.succeed("ping -c 1 machine1")

    arch1 = machine1.succeed("uname -m")
    t.assertIn("x86_64", arch1, "machine1 is an intel VM")
    arch2 = machine2.succeed("uname -m")
    t.assertIn("aarch64", arch2, "machine1 is an ARM VM")
  '';
}
