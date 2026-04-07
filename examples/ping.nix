{
  name = "ping test";

  nodes = {
    machine1 = { };
    machine2 = { };
  };

  defaults = {
    # ongoing discussion if this should be default in the test driver
    networking.dhcpcd.enable = false;
  };

  globalTimeout = 20;

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
  '';
}
