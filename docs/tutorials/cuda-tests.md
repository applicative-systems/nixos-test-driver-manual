# CUDA tests in containers

!!! warning "Special host setup necessary, see [Feature: containers](../features/container.md#host-configuration)"

!!! example "Run this example test yourself"

    To run this test directly from the example repository, run:

    ```console
    nix build -L github:applicative-systems/nixos-test-driver-manual#test-cuda-nvidia
    ```

<figure markdown="span">
  ![CUDA in the test driver demo](../assets/cuda-demo.gif)
  <figcaption>CUDA saxpy example app output in a test driver container</figcaption>
</figure>

```nix title="cuda/generic.nix"
--8<-- "examples/cuda/generic.nix"
```

```nix title="cuda/nvidia.nix"
--8<-- "examples/cuda/nvidia.nix"
```

<!-- prettier-ignore-start -->
<!-- prettier-ignore-end -->
