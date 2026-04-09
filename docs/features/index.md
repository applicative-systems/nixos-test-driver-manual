# Features of the NixOS Test Driver

The NixOS integration test driver is a powerful tool with many advanced features:

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   [:simple-qemu: **Virtual machines**](./vm.md)

    ---

    The default way to run tests, providing full isolation and kernel customization.

-   [:octicons-container-16: **Containers**](./container.md)

    ---

    A lighter and faster alternative to VMs for tests that don't require custom kernels.

-   [:keyboard: **Interactive mode**](./interactive.md)

    ---

    Effortless local debugging of tests.

-   [:material-puzzle-heart: **Test modules**](./module-composition.md)

    ---

    How to compose test modules efficiently for reduced code duplication.

-   [:desktop: **Screenshots and OCR**](./screenshots-and-ocr.md)

    ---

    Set up graphics support and optical character recognition for graphical tests.

-   [:white_check_mark: **Test script linting**](./linting.md)

    ---

    Automatically check your `testScript` for Python errors before the tests run.

-   [:hook: **Breakpoint hook**](./error-hook.md)

    ---

    Can't reproduce rare flaky test failures? Hook into the test sandbox when it happens!

</div>

<!-- prettier-ignore-end -->
