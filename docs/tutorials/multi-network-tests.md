# Multi-node and Multi-network Tests

NixOS integration tests excel at orchestrating complex network setups with multiple machines and networks.

## Two Nodes on the Same Network

By default, nodes in a test can communicate with each other using their hostnames.

!!! example "Run this example test yourself"

    To run this test directly from the example repository, run:

    ```console
    nix build -L github:applicative-systems/nixos-test-driver-manual#test-ping
    ```

```nix title="ping.nix"
--8<-- "examples/ping.nix"
```

## Using Multiple Networks (VLANs)

You can isolate nodes into different networks by using the `virtualisation.vlans` option (see also [official docs](https://nixos.org/manual/nixos/stable/#sec-nixos-test-nodes)).

!!! example "Run this example test yourself"

    To run this test directly from the example repository, run:

    ```console
    nix build -L github:applicative-systems/nixos-test-driver-manual#test-multi-network
    ```

```nix title="multi-network.nix"
--8<-- "examples/multi-network.nix"
```

VLANs are a powerful way to test complex network architectures like firewalls, routers, and isolated service enclaves.

If you are interested in setting up routing in your tests, please have a look at existing tests in the nixpkgs repo:

- [`bittorrent.nix` test](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/bittorrent.nix)
- [`networking/router.nix` test](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/networking/router.nix)
