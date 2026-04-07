{ pkgs, ... }:
let
  nixpkgs = pkgs.path;
in
{
  name = "Browser test";
  globalTimeout = 500;

  enableOCR = true; # (1)

  nodes = {
    server = {
      services.httpd.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
    client =
      { pkgs, ... }:
      {
        imports = [
          (nixpkgs + "/nixos/tests/common/x11.nix") # (2)
        ];

        programs.firefox.enable = true;

        environment.systemPackages = [
          pkgs.xdotool
        ];

        virtualisation.resolution = {
          # (3)
          x = 800;
          y = 600;
        };
      };
  };

  testScript = ''
    start_all()

    server.systemctl("start network-online.target")
    client.systemctl("start network-online.target")
    server.wait_for_unit("network-online.target")
    client.wait_for_unit("network-online.target")

    server.succeed("ping -c 1 client")
    client.succeed("ping -c 1 server")

    client.wait_for_x()

    with subtest("open and close firefox"):
      client.succeed("xterm -e 'firefox about:welcome' >&2 &")
      client.wait_for_window("Firefox")
      client.sleep(5)
      client.succeed("xdotool key ctrl+q")
      client.wait_for_text(".uit .irefox")
      client.succeed("xdotool key space")
      client.sleep(2)

    with subtest("open website on server"):
      client.succeed("xterm -e 'firefox http://server' >&2 &")
      client.wait_for_window("Firefox")
      client.sleep(2)
      client.screenshot("it-works")

      screen_content = client.get_screen_text()
      t.assertIn("It works!", screen_content, "It works! page is on screen")
  '';
}
