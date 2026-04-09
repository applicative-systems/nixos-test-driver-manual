# Overlays in tests

!!! example "Run this example test yourself"

    To run this test directly from the example repository, run:

    ```console
    nix build -L github:applicative-systems/nixos-test-driver-manual#test-overlay
    ```

This tutorial shows how to use [nixpkgs overlays](https://nixos.org/manual/nixpkgs/stable/#chap-overlays) inside tests.

The example describes an overlay that patches [GNU Hello](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.gnu.org/software/hello/) to print "Bye, world!" instead of "Hello, world!" and then tests this output.

```nix title="overlay.nix"
--8<-- "examples/overlay.nix"
```

1.  **Defining overlays**

    This is an example overlay.
    In this tutorial, we don't explain how overlays in nixpkgs work.

    If you are interested in learning about overlays, please refer to the [guides at the end of this page](#further-references)

2.  **Disabling read-only `pkgs`**

    If we don't disable this setting which is `true` by default, we will get the error message from [here (next section)](#setting-nodepkgsreadonly).

3.  **Adding the overlay**

    At this point, we are setting the overlay for the machine, and only this machine.

??? note "Testing app output with other testers"

    Using the NixOS test driver for this particular scenario can be considered over-engineering.
    For the sake of simplicity, this is just a minimal example scenario to explain test driver mechanics.

    To test CLI-app output in isolation in such simple cases in production, please have a look at the other [tester functions in nixpkgs](https://nixos.org/manual/nixpkgs/stable/#chap-testers).

## Setting `node.pkgsReadOnly`

If we forget setting `node.pkgsReadOnly` to `false` (as also [described in the NixOS manual](https://nixos.org/manual/nixos/stable/#test-opt-node.pkgsReadOnly)), we will get an error message like this:

```console
error: The option `containers.machine.nixpkgs.overlays' is defined multiple times while it's expected to be unique.
nixpkgs.overlays is set to read-only
```

??? question "Why does this option even exist?"

    The [`pkgs.testers.runNixOSTest`](https://nixos.org/manual/nixos/stable/#sec-call-nixos-test-outside-nixos) performs a certain optimization:
    It evaluates `pkgs` only once for all machines and then injects it read-only into all node configurations.

    As a clear majority of tests does not use overlays per node, this saves a lot of evaluation time.

## Further references

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   **Mastering Nixpkgs Overlays: Techniques and Best Practice**

    ---

    ![Mastering Nixpkgs Overlays: Techniques and Best Practice](../assets/blog/hand-paints-itself.jpg){ width=200 align=left }

     Overlays in Nixpkgs are a powerful mechanism, but they are also complex to grasp.
     We tell you everything you need to know about Nixpkgs overlays.

    [**Visit**](https://nixcademy.com/posts/mastering-nixpkgs-overlays-techniques-and-best-practice/)

-   **What You Need to Know About Lazy Evaluation in Nix**

    ---

    ![What You Need to Know About Lazy Evaluation in Nix](../assets/blog/lazy-dude.jpg){ width=200 align=left }

    If you have no prior experience with functional programming, don't miss this article which explains the most important intricacies of lazy evaluation!

    [**Visit**](https://nixcademy.com/posts/what-you-need-to-know-about-laziness/)

</div>

<!-- prettier-ignore-end -->
