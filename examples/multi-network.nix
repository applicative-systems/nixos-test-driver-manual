{
  name = "multi-network test";

  nodes = {
    machine1 = {
      virtualisation.vlans = [ 1 ];
    };
    machine2 = {
      virtualisation.vlans = [
        1
        2
      ];
    };
    machine3 = {
      virtualisation.vlans = [ 2 ];
    };
  };

  defaults = {
    # ongoing discussion if this should be default in the test driver
    networking.dhcpcd.enable = false;
  };

  globalTimeout = 30;

  testScript = ''
    start_all()

    # First, start network-online.target
    machine1.systemctl("start network-online.target")
    machine2.systemctl("start network-online.target")
    machine3.systemctl("start network-online.target")

    # Wait for the network to be online
    # Otherwise, we could get errors like
    #   `ping: connect: Network is unreachable`
    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")
    machine3.wait_for_unit("network-online.target")

    # the neighboring nodes should be able to ping each other
    machine1.succeed("ping -c 1 machine2")
    machine2.succeed("ping -c 1 machine1")

    machine2.succeed("ping -c 1 machine3")
    machine3.succeed("ping -c 1 machine2")

    # As we have no routing setup, 1 and 3 should not be able to ping each other
    machine1.fail("ping -c 1 machine3")
    machine3.fail("ping -c 1 machine1")
  '';
}
