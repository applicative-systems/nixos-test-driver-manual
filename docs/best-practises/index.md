# Best Practises

These guides collect operational advice for writing NixOS tests that are fast to debug, robust in CI, and portable across different environments.

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   [:material-timer-alert: **Always set timeouts**](./timeout.md)

    ---

    Use global and per-operation timeouts so broken tests fail quickly instead of burning CI time.

-   [:material-traffic-light-outline: **Avoid race conditions**](./service-race-conditions.md)

    ---

    Wait for the right units and ports before asserting on a service.

-   [:material-timeline-clock-outline: **Use parallelism across machines**](./use-parallelism.md)

    ---

    Start long-running setup on all nodes first, then wait for completion so multi-node tests do not serialize unnecessary work.

-   [:material-package-variant: **Use the right `pkgs` attribute**](./pkgs-attribute.md)

    ---

    Keep host packages and guest packages separate so tests stay portable.

</div>

<!-- prettier-ignore-end -->
