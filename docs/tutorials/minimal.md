# A minimal NixOS test

Let's define a minimal test that boots a machine and runs a command.

There is a bit of explanation in tooltips scattered over the code examples, but the primary goal of this page is to help you get a test running and then pick up in the other pages.

!!! Prerequisites

    Please make sure you have Nix and KVM set up correctly to run this test.
    If unsure, consult the [Setup](../setup.md) guide first.

    You can also just run this test and see if it "just works".
    If the tests runs longer than ~30 seconds or you get error messages, these are signs of misconfiguration.

!!! example "Run this example test yourself"

    To run this test directly from the example repository, run:

    ```console
    nix build -L github:applicative-systems/nixos-test-driver-manual#test-minimal
    ```

## Defining the test

Create a file named `minimal.nix`.

It configures a virtual machine that comes with [GNU Hello](https://www.gnu.org/software/hello/) preinstalled.
The test itself boots the machine and then runs `hello` on the terminal and tests if the output contains "Hello, world!":

```nix title="minimal.nix"
--8<-- "examples/minimal.nix"
```

<!-- prettier-ignore-start -->

1.  **Test name** (mandatory)

    Every test needs a name.
    It also becomes part of the output path later.

2.  **Top-level attribute set `nodes`**

    This is the _declarative_ part of the test that defines the existing infrastructure.

    For every key-value entry here, the test driver will later create a VM, a Python variable, and a DNS entry.
    The key is used to name the VM, the value represents the NixOS configuration of the VM.

    For an entry like `my-machine`, the test driver creates the following:

    - VM with the host name `my-machine`
    - Python variable `my-machine` for use in the test script
    - DNS setup so you can reach `my-machine` via network from other machines.

3.  **NixOS configuration**

    Every node name gets assigned a full NixOS configuration.
    The normal NixOS configuration rules apply.
    You can use `imports = [ ./some/module.nix  ];` and everything else that's allowed in normal NixOS configurations.

    Setting this to an empty configuration (`{}`) creates a VM with default settings, network support, and a password-less `root` user account.

4.  **Test script**

    This is the _imperative_ part of the test that describes the steps and stimulation that the infrastructure shall go to and conform with.

<!-- prettier-ignore-end -->

## Running the test

For a quick and dirty test run, we can run the test through the [`runNixOSTest` function](https://nixos.org/manual/nixos/stable/#sec-call-nixos-test-outside-nixos) on the command line:

```console
nix-build -E "(import <nixpkgs> {}).testers.runNixOSTest ./minimal.nix"
```

`runNixOSTest` returns a derivation that runs the test in the sandbox and returns its result in the output folder (typically linked to by the `result/` symlink).
For most tests, this folder is empty.

### Boiler plate code

If you intend to make the test part of a project, the minimal boiler plate code would look like this:

=== "Flakes"

    ```nix title="flake.nix"
    {
      inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      outputs =
        inputs:
        let
          system = "x86_64-linux";
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        {
          packages.${system}.test = pkgs.testers.runNixOSTest ./minimal.nix;
        };
    }
    ```

=== "Non-Flakes"

    ```nix title="run-test.nix"
    let
      pkgs = import <nixpkgs> { };
    in
    pkgs.testers.runNixOSTest ./minimal.nix
    ```

Run the test:

=== "Flakes"

    ```console
    nix build -L .#test
    ```

=== "Non-Flakes"

    ```console
    nix-build run-test.nix
    ```

## Great, it works. Where to from here?

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   [:playground_slide: **Tutorials**](../tutorials/index.md)

    ---

    Discover more complex tests with networking, graphics, etc.

-   [:map: **Features**](../features/index.md)

    ---

    Deep dives into the driver's capabilities like VMs and containers, the interactive mode, graphics, OCR, test linting.

-   [:tools: **Best Practices**](../best-practices/index.md)

    ---

    Dos and don'ts from experience.

-   [:bookmark: **The test driver chapter of the NixOS manual**](https://nixos.org/manual/nixos/stable/#sec-nixos-tests)

    ---

    Trust us, it's worth reading from top to bottom! Also, add a bookmark!

</div>

<!-- prettier-ignore-end -->
