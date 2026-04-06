# Features of the NixOS Test Driver

The NixOS integration test driver is a powerful tool with many advanced features.

- [**Virtual Machine (VM) Tests**](./vm.md): The default way to run tests, providing full isolation and kernel customization.
- [**Container Tests**](./container.md): A lighter and faster alternative to VMs for tests that don't require custom kernels.
- [**Interactive Mode**](./interactive.md): A way to debug tests in real-time.
- [**Linting**](./linting.md): Automatically check your `testScript` for Python errors.
- [**Error Hooks**](./error-hook.md): Collect screenshots, logs, and other artifacts when a test fails.
