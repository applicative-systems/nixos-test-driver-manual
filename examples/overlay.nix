let
  hello-bye = _final: prev: {
    # (1)
    hello = prev.hello.overrideAttrs (_old: {
      postPatch = ''
        substituteInPlace src/hello.c \
          --replace-fail "Hello, world!" "Bye, world!"
      '';
      doCheck = false;
    });
  };
in
{
  name = "Test with overlays";

  node.pkgsReadOnly = false; # (2)

  containers.machine =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ hello-bye ]; # (3)
      environment.systemPackages = [ pkgs.hello ];
    };

  testScript = ''
    output = machine.succeed("hello")
    t.assertIn("Bye, world!", output, "Patched GNU Hello must output bye")
  '';
}
