_: prev: {
  nixos-test-driver = prev.nixos-test-driver.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [ ./nixos-test-driver-gpu.patch ];
  });
}
