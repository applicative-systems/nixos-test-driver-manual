{
  name = "Minimal hello test"; # (1)

  nodes = {
    # (2)
    vm =
      { pkgs, ... }: # (3)
      {
        environment.systemPackages = [
          pkgs.hello
        ];
      };
  };

  # (4)
  testScript = ''
    start_all()

    output = vm.succeed("hello")

    t.assertIn("Hello, world", output, "GNU Hello should print hello world")
  '';
}
