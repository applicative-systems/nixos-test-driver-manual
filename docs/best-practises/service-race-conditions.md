# Avoid race conditions

It can happen that a NixOS test fails only on some machines, or only in CI, because it starts asserting on a service before the system is actually ready.
The usual fix is not more retries, but better synchronization.

## Wait for the right events in the right order

For networked services, a reliable test usually has three phases:

1. Ensure the required machines are online.
2. Wait for the relevant systemd unit to start.
3. Wait for the service port to become reachable before exercising it.

This pattern is robust on both slow and fast hardware:

```nix title="test.nix"
{
  name = "HTTP test";

  nodes = {
    server = {
      services.httpd.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
    client = { };
  };

  testScript = ''
    start_all()

    # Make sure network target is reached on all machines
    for m in [server, client]:
      m.systemctl("start network-online.target")
      m.wait_for_unit("network-online.target")

    # Wait until the service in question is ready
    server.wait_for_unit("httpd.service")

    # Wait until the port has actually opened
    server.wait_for_open_port(80)

    client.succeed("curl http://server")
  '';
}
```

??? question "Why wait for the port too?"

    Waiting for `httpd.service` alone is often not enough.
    A systemd unit can report as started while the process is still finishing initialization and is not *yet* ready to accept connections.

    That timing gap is exactly the kind of race that may pass on a laptop and fail in a much bigger and faster CI machine.
    `wait_for_open_port` closes that gap by synchronizing on actual network readiness.

??? question "Why not only wait for the port?"

    This version is weaker:

    ```python
    server.wait_for_open_port(80)
    client.succeed("curl http://server")
    ```

    If the service never starts because of a configuration error, the test now sits in a timeout loop and reports the failure later and with less context.

    Waiting for the systemd unit first gives you faster and more informative failures:

    - if the service crashes during startup, `wait_for_unit` fails early
    - if the unit starts but the socket is not ready yet, `wait_for_open_port` handles the remaining synchronization

    Use both checks when you test a network service.

!!! note "A Note on Networking"

    If your test depends on networking, it is often worth explicitly waiting for `network-online.target` on the participating machines.
    That reduces another common source of flaky behavior, especially in multi-node tests.
