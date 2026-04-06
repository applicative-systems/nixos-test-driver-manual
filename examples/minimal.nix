{
  name = "Minimal hello test";

  nodes = {
    vm =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.hello
        ];
      };
  };

  testScript = ''
    start_all()

    output = vm.succeed("hello")

    t.assertIn("Hello, world", output, "GNU Hello should print hello world")
  '';
}
