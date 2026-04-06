# Multi-node and Multi-network Tests

NixOS integration tests excel at orchestrating complex network setups with multiple machines and networks.

## Two Nodes on the Same Network

By default, nodes in a test can communicate with each other using their hostnames.

```nix title="ping-test.nix"
{
  name = "Two machines ping each other";
  nodes = {
    machine1 = { ... }: { };
    machine2 = { ... }: { };
  };
  testScript = ''
    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    # Ping machine2 from machine1
    machine1.succeed("ping -c 1 machine2")

    # Ping machine1 from machine2
    machine2.succeed("ping -c 1 machine1")
  '';
}
```

## Using Multiple Networks (VLANs)

You can isolate nodes into different networks by using the `virtualisation.vlans` option.

```nix title="vlan-test.nix"
{
  name = "VLAN isolation test";
  nodes = {
    client = { ... }: {
      virtualisation.vlans = [ 1 ]; # Connect to VLAN 1
    };
    server = { ... }: {
      virtualisation.vlans = [ 1 2 ]; # Connect to VLAN 1 and 2
    };
    internal = { ... }: {
      virtualisation.vlans = [ 2 ]; # Connect to VLAN 2
    };
  };
  testScript = ''
    start_all()
    client.wait_for_unit("network-online.target")
    server.wait_for_unit("network-online.target")
    internal.wait_for_unit("network-online.target")

    # client can reach server on eth1 (VLAN 1)
    client.succeed("ping -c 1 server")

    # internal can reach server on eth1 (VLAN 2)
    internal.succeed("ping -c 1 server")

    # client CANNOT reach internal
    client.fail("ping -c 1 internal")
  '';
}
```

VLANs are a powerful way to test complex network architectures like firewalls, routers, and isolated service enclaves.
