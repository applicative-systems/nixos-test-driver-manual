# Always Set Timeouts

Timeouts are one of the simplest ways to make NixOS tests more practical to work with.
Without them, a broken service or unreachable port can leave a test hanging until the full build timeout is reached.

## Why This Matters

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

- :octicons-loop-16: Faster failures give developers a tighter feedback loop.
- :material-run-fast: Shorter failing runs free CI capacity for other jobs.

</div>

<!-- prettier-ignore-end -->

Use the global timeout as a safety net and smaller per-operation timeouts where you know the expected behavior more precisely.

## Use a Global Timeout

The top-level `globalTimeout` option limits the total runtime of the test.
It is documented in the [NixOS manual](https://nixos.org/manual/nixos/stable/#test-opt-globalTimeout).

```nix title="test.nix"
{
  name = "example-test";
  globalTimeout = 600;

  nodes.machine = { ... }: {
    # configuration
  };

  testScript = ''
    # test code
  '';
}
```

`globalTimeout` is expressed in seconds and defaults to one hour.
That default is safe, but it is often longer than you actually want during development or in CI.

## Individual per-operation timeouts

Many machine methods also accept explicit timeouts.
The full list is documented in the [machine objects reference](https://nixos.org/manual/nixos/stable/#ssec-machine-objects).

These two are especially common in service tests:

| Method                                      | Typical use                                                       |
| ------------------------------------------- | ----------------------------------------------------------------- |
| `wait_for_open_port(port, addr, timeout)`   | Wait until a service is ready to accept connections               |
| `wait_for_closed_port(port, addr, timeout)` | Wait until a service has fully stopped or a restart has completed |

Example:

```python
machine.wait_for_open_port(8080, timeout=20)
machine.wait_for_closed_port(8080, timeout=20)
```

Per-operation timeouts are useful when you know a condition should become true quickly and want failures to surface immediately.
