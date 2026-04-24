# Fail Fast When KVM Is Unavailable

When QEMU cannot access the host's [KVM](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine) (Linux) or [HVF](https://wiki.qemu.org/Features/HVF) (macOS) accelerator, it silently falls back to the [TCG](https://www.qemu.org/docs/master/devel/index-tcg.html) interpreter.
Tests still pass, but they run roughly an order of magnitude slower.
The only hint in the output is a QEMU log line buried between other driver messages.

## Why This Matters

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

- :material-speedometer-slow: Silent TCG fallback can turn a 2-minute test into a 20-minute test.
- :material-alert-circle-outline: Suddenly-slow CI runs are often misattributed to the code under test rather than to a host reconfiguration.
- :octicons-stopwatch-16: Longer runs collide with `globalTimeout` and mask real regressions.

</div>

<!-- prettier-ignore-end -->

A missing accelerator is almost always a host-level problem (wrong group membership, virtualization disabled in BIOS, nested-virt not available in a CI runner).
It is far more useful to surface this as an explicit test failure than to pay the price on every run.

## Use `qemu.forceAccel`

Set `qemu.forceAccel = true;` at the top level of your test.
If neither KVM (Linux) nor HVF (macOS) is available at runtime, the test aborts immediately with an actionable error message.

```nix title="test.nix"
{
  name = "example-test";

  qemu.forceAccel = true;

  nodes.machine = { ... }: {
    # configuration
  };

  testScript = ''
    start_all()
  '';
}
```

Typical error message when the option trips:

```console
forceAccel is enabled but /dev/kvm is not accessible (permission denied).
Check that your user is in the 'kvm' group or that /dev/kvm has the correct permissions.
```

## When to Use It

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   :material-server-network: **CI**

    ---

    Always enable `qemu.forceAccel` in CI.
    A silent TCG fallback there is essentially a hidden bug in the runner configuration.

-   :material-laptop: **Local development**

    ---

    Enable it whenever you rely on KVM being present.
    You will notice host-level regressions (group membership lost after a rebuild, device permissions changed) immediately, instead of chasing phantom slowdowns.

</div>

<!-- prettier-ignore-end -->

See also: [Testing host setup — Linux KVM](../setup.md#linux-kvm).
