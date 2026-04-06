# A minimal NixOS test

## Defining the test file

```nix title="test.nix"
{
  name = "A minimal NixOS test";

  nodes = { # (1)
    machine = { pkgs, ... }: { 
      environment.systemPackages = [
        pkgs.hello
      ];
    };
  }

  testScript = ''
    machine.succeed("hello")
  '';
}
```

1. :man_raising_hand: bla!

## Running the test

### With flakes

### Without flakes