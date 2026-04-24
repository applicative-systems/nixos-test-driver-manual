# Changelog

A curated index of upstream nixpkgs PRs that touched the NixOS test driver, so you don't have to watch the PR firehose yourself.
Entries are grouped by month and tagged as **bugfix**, **new feature** (with pointers into the relevant section of this manual), or **maintenance** (brief by design).

## 2026-04

### [PR #512733 — unbreak eval on macOS](https://github.com/NixOS/nixpkgs/pull/512733)

!!! bug "Bugfix: restore evaluation of NixOS tests on macOS."

Eval on macOS (`darwin`) broke because the driver pulled in Linux-only dependencies (`vhost-device-vsock`) and QEMU shared-memory settings unconditionally. The fix:

- only depend on vsock packages on Linux
- only set `sharedMemory` QEMU option on Linux
- use `hostPkgs` (not `pkgs`) to build the test script and config file, so eval doesn't try to build Linux things for the guest system on a Darwin host.

Typical error messages looked roughly like `error: Package 'vhost-device-vsock-...' is not available on the requested hostPlatform`, or `attribute 'vhost-device-vsock' missing` while evaluating a NixOS test on `aarch64-darwin` / `x86_64-darwin`.

Contributors: [@tfc](https://github.com/tfc), [@vcunat](https://github.com/vcunat)

### [PR #511413 — extra `requiredFeatures` options](https://github.com/NixOS/nixpkgs/pull/511413)

!!! tip "New feature: declare extra required builder features and opt into the `/dev/net` sandbox check."

Adds a new option tree `requiredFeatures.*` on tests:

- `requiredFeatures.cuda` — request arbitrary Nix builder features (`"cuda"` is just an example) so the builder selection routes the test to machines with GPUs.
- `requiredFeatures.devnet` — If a test combines VMs with containers make it an error if the builder is not configured to provide the `"devnet"` feature string. This is to provide a better error message than leaving the user with VMs and containers that can't connect to each other. See also [Features: Container](features/container.md) for more explanation.

This is also interesting for anyone running **CUDA / GPU tests**: [see CUDA test tutorial](tutorials/cuda-tests.md).

Contributors: [@tfc](https://github.com/tfc)

### [PR #511225 — fix type-check-disabled case](https://github.com/NixOS/nixpkgs/pull/511225)

!!! bug "Bugfix: restore tests that run with type-checking disabled."

Follow-up fix to [PR #510385](https://github.com/NixOS/nixpkgs/pull/510385) (the config-file refactor). The branch that handled tests with type-checking disabled was broken, causing some Hydra failures.

Contributors: [@mdaniels5757](https://github.com/mdaniels5757)

### [PR #510385 — JSON driver config file](https://github.com/NixOS/nixpkgs/pull/510385)

!!! abstract "Maintenance: replace multiple env vars with a single JSON driver config file."

Historically, the old Perl implementation of the test driver used multiple environment variables as a way to provide named parameters in the test driver.
This change introduced a comprehensive [configuration attribute set](https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/testing/driver-configuration.nix) that is provided to the driver as a JSON file.
As a side benefit, the resolved configuration is now inspectable via `test.driver.config.driverConfiguration`, which is a nice debugging hook.

Contributors: [@tfc](https://github.com/tfc)

### [PR #510559 — skip sandbox prep outside sandbox](https://github.com/NixOS/nixpkgs/pull/510559)

!!! bug "Bugfix: don't run sandbox-setup code when the driver runs outside the sandbox."

The driver was unconditionally running sandbox-preparation code (mount/bind-mount setup). This broke container tests when the driver was invoked **outside** the Nix sandbox — specifically `driverInteractive` or `nix run ...#<test>.driverInteractive`, and any non-sandboxed invocation.

Typical error messages look roughly like `mount: permission denied`, `mount: /run/...: not a directory`, or Python's `PermissionError: [Errno 13]` during container startup when running a test interactively (e.g. `sudo $(nix build ...driverInteractive)/bin/nixos-test-driver --interactive`).

Contributors: [@tfc](https://github.com/tfc)

### [PR #510699 — add remaining `passthru.tests`](https://github.com/NixOS/nixpkgs/pull/510699)

!!! abstract "Maintenance: wire the remaining internal driver tests into `passthru.tests` so CI runs them on every driver change."

Contributors: [@m1-s](https://github.com/m1-s)

### [PR #510561 — driver tidy-up](https://github.com/NixOS/nixpkgs/pull/510561)

!!! abstract "Maintenance: drop an unused `SENTINEL` object and stop documenting `_`-prefixed internal methods."

Contributors: [@tfc](https://github.com/tfc), [@m1-s](https://github.com/m1-s)

### [PR #509488 — hide VDE switch log noise](https://github.com/NixOS/nixpkgs/pull/509488)

!!! tip "New feature: suppress noisy VDE switch log output from test runs."

The [VDE (virtual distributed ethernet) switch](https://github.com/virtualsquare/vde-2) used for test networking was polluting test logs with implementation-detail messages. These are now suppressed.

Interesting for anyone who reads test logs — less noise, easier to find real issues.

Contributors: [@m1-s](https://github.com/m1-s)

### [PR #453305 — `vhost-device-vsock` SSH backdoor](https://github.com/NixOS/nixpkgs/pull/453305)

!!! tip "New feature: SSH backdoor via `vhost-device-vsock` — no more `/dev/vhost-vsock` in `sandbox-paths`, no more CID conflicts."

Rewires the SSH backdoor to use `vhost-device-vsock` ([AF_VSOCK](https://man7.org/linux/man-pages/man7/vsock.7.html) over a UNIX socket on the host side) instead of the kernel's vsock device. Two big user-visible wins:

1. **You no longer need `--option sandbox-paths /dev/vhost-vsock`** to debug tests inside the Nix sandbox. That means **untrusted users** can now debug these tests.
2. **No more CID conflicts** — `sshBackdoor.vsockOffset` becomes unnecessary.

Requires systemd 258 and openssh 10.2p1 for best UX (fast login), but works with older systemd via manual SSH config.

Interesting for everyone using `sshBackdoor.enable = true;` and/or `enableDebugHook = true;` when [connecting to machines in interactive mode](tutorials/connecting-to-nodes-in-interactive.md) or [when debugging sandboxed tests with the error hook](features/error-hook.md).

Contributors: [@Ma27](https://github.com/Ma27)

### [PR #509553 — `qemu.forceAccel` option](https://github.com/NixOS/nixpkgs/pull/509553)

!!! tip "New feature: `qemu.forceAccel` fails fast when KVM/HVF is unavailable instead of silently falling back to slow TCG."

Adds `qemu.forceAccel = true;` — when enabled, if [KVM (Linux)](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine) or [HVF (macOS)](https://wiki.qemu.org/Features/HVF) isn't available, the test **fails fast with a clear error** instead of silently falling back to [TCG](https://www.qemu.org/docs/master/devel/index-tcg.html) (which makes tests ~10x slower).

Error message when it trips:

```
forceAccel is enabled but /dev/kvm is not accessible (permission denied).
Check that your user is in the 'kvm' group or that /dev/kvm has the correct permissions.
```

Interesting for anyone who want tests to fail instead of getting mysteriously slow after a inadvertendt host reconfiguration.
See also the [testing host setup chapter](setup.md).

Contributors: [@m1-s](https://github.com/m1-s), [@tfc](https://github.com/tfc)

### [PR #509867 — driver log levels](https://github.com/NixOS/nixpkgs/pull/509867)

!!! tip "New feature: proper log levels in the test driver's Python logger."

Users can now control verbosity rather than getting firehose log output.

Interesting for anyone tired of sifting through driver debug logs, and for CI log hygiene.

See the new [Driver log levels](features/log-levels.md) feature page.

Contributors: [@m1-s](https://github.com/m1-s)

### [PR #504626 — fix `create_machine()` return type](https://github.com/NixOS/nixpkgs/pull/504626)

!!! bug "Bugfix: `create_machine()` return type now correctly annotated as `QemuMachine`."

Type-annotation fix: `create_machine()` always returns a `QemuMachine`, but the type annotation was still referring to the abstract type, which meant callers couldn't invoke QEMU-specific methods without a type-check error.

Contributors: [@alyssais](https://github.com/alyssais)

## 2026-03

### [PR #503686 — driver is overridable](https://github.com/NixOS/nixpkgs/pull/503686)

!!! tip "New feature: the Python test driver is now a proper package (`pkgs.nixos-test-driver`) that can be overridden via overlays."

Packages the Python test driver as `pkgs.nixos-test-driver` and exposes it as `config.pythonTestDriverPackage` in the test module system. That means users can now **override the driver** via overlays — e.g. apply patches to the driver Python code for experimental features (exactly [what the CUDA tutorial does](tutorials/cuda-tests.md)).

Interesting for advanced users who want to patch the driver (CUDA folks, people implementing new machine backends, people testing driver PRs).

See the [Overriding the test driver itself](tutorials/applying-overlays.md#overriding-the-test-driver-itself) section in the overlays tutorial.

Contributors: [@tfc](https://github.com/tfc)

### [PR #503070 — fix `testScript` regressions](https://github.com/NixOS/nixpkgs/pull/503070)

!!! bug "Bugfix: restore `testScript` linting and expose a generic `machines` variable after the nspawn refactor."

Cleanup of regressions introduced by [the big nspawn PR #478109](https://github.com/NixOS/nixpkgs/pull/478109): provides a generic `machines` variable to `testScript` (union of QEMU and nspawn) plus `BaseMachine` / `QemuMachine` / `NspawnMachine` types for linting, and fixes several nixpkgs tests' type annotations.

Contributors: [@kmein](https://github.com/kmein)

### [PR #501599 — fix `testScript` without ellipsis](https://github.com/NixOS/nixpkgs/pull/501599)

!!! bug "Bugfix: restore `testScript = { nodes }: ...` (strict pattern match without `...`) which broke after the nspawn PR added a `containers` argument."

The nspawn PR added a `containers` argument to the `testScript` function caller. Tests whose `testScript = { nodes }: ...` used strict pattern matching (no `...`) broke, because Nix rejected the unexpected `containers` arg. Fixed with `builtins.intersectAttrs`.

Contributors: [@Mic92](https://github.com/Mic92)

### [PR #501294 — fix `extract-docstrings` types](https://github.com/NixOS/nixpkgs/pull/501294)

!!! bug "Bugfix: correct type annotations in the docstring-extraction script after the nspawn refactor."

Fixup for #479968 — the docstring-extraction script used for rendering the machine API reference had bad type annotations after the nspawn refactor.

Typical error messages look roughly like a manual build failure with `mypy: error: Incompatible types in assignment`, or an `AttributeError` in `extract-docstrings.py` when `nix-build nixos/release.nix -A manual.x86_64-linux` runs.

Contributors: [@kmein](https://github.com/kmein)

### [PR #479968 — document nspawn in NixOS manual](https://github.com/NixOS/nixpkgs/pull/479968)

!!! tip "New feature: upstream NixOS manual now documents the systemd-nspawn test backend."

Adds/restructures the upstream NixOS manual section for systemd-nspawn test containers: when to choose containers vs VMs, host setup (`auto-allocate-uids`, sandbox-paths), writing container tests, debugging them.

This is the **upstream** equivalent of what this manual covers in [Features: Containers](features/container.md).

Contributors: [@kmein](https://github.com/kmein)

### [PR #478109 — nspawn container backend](https://github.com/NixOS/nixpkgs/pull/478109)

!!! tip "New feature: systemd-nspawn as a second machine backend alongside QEMU — ~25% faster, no bare-metal required, enables GPU/device bind-mounts."

The big one. Adds `systemd-nspawn` as a second machine backend next to QEMU:

- **~25% faster** test execution in benchmarks vs QEMU.
- Runs in cheap VMs (no bare-metal with KVM required).
- Allows **device bind-mounts** — enabling [CUDA/GPU testing inside NixOS tests](tutorials/cuda-tests.md) for the first time.
- Lays the groundwork for further machine backends.

New things exposed to users:

- `containers.<name>` alongside `nodes.<name>` in test definitions
- `machines`, `machines_qemu`, `machines_nspawn` in `testScript`
- `BaseMachine` / `QemuMachine` / `NspawnMachine` Python types
- `--keep-machine-state` replacing `--keep-vm-state` (deprecation)
- `copy_from_machine` replacing `copy_from_vm` (deprecation)
- `/etc/hosts` is now VLAN-aware
- Limitations: no kernel tests, no setuid wrappers, no graphical tests, limited `/dev` access.

Extensively documented in this manual (with references to [original NixOS manual](https://nixos.org/nixos/manual)):

- [Testing host setup](setup.md).
- [Features: Containers](features/container.md)
- [Tutorials: CUDA tests](tutorials/cuda-tests.md)

Contributors: [@kmein](https://github.com/kmein), [@jfly](https://github.com/jfly), [@KiaraGrouwstra](https://github.com/KiaraGrouwstra), [@roberth](https://github.com/roberth)

## 2026-02

### [PR #487754 — fix `nix-shell` for driver](https://github.com/NixOS/nixpkgs/pull/487754)

!!! bug "Bugfix: `nix-shell` now works in `nixpkgs/nixos/lib/test-driver` again."

Fixes `nix-shell` in `nixpkgs/nixos/lib/test-driver` — it was failing because `shell.nix` called `callPackage` instead of `python3Packages.callPackage`, so `buildPythonApplication` wasn't in scope.

Typical error messages look roughly like:

```
error: evaluation aborted with the following error message:
'lib.customisation.callPackageWith: Function called without required
argument "buildPythonApplication" at […]/nixos/lib/test-driver/default.nix:4'
```

Only relevant to people hacking on the test driver itself (entering its dev shell), not to test authors.

Contributors: [@l0b0](https://github.com/l0b0), [@tfc](https://github.com/tfc)

## 2026-01

### [PR #470248 — `nspawn-container` profile](https://github.com/NixOS/nixpkgs/pull/470248)

!!! tip "New feature: standalone `nspawn-container` NixOS profile — the foundation for container-based tests."

Adds the standalone `nspawn-container` NixOS profile (`${modulesPath}/virtualisation/nspawn-container`) that builds a runnable `run-<name>-nspawn` script — analogous to `qemu-vm.nix`. Shares networking options (`virtualisation.vlans`, `virtualisation.allInterfaces`) with `qemu-vm.nix` via a factored-out module.

This is **the foundation** on which [PR #478109](https://github.com/NixOS/nixpkgs/pull/478109) was then built to enable container tests.

Not documented _as a standalone profile_ in this manual (we document its use via the test driver, not as a general-purpose NixOS profile). The profile is mostly internal plumbing.

Contributors: [@jfly](https://github.com/jfly), [@kmein](https://github.com/kmein), [@arianvp](https://github.com/arianvp)
