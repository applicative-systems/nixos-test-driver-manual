{ pkgs, ... }:
let
  tls-cert = # (1)
    pkgs.runCommand "selfSignedCerts"
      {
        buildInputs = [ pkgs.openssl ];
      }
      ''
        openssl req \
          -x509 -newkey rsa:2048 -sha256 -days 365 \
          -nodes -out cert.pem -keyout key.pem \
          -subj '/CN=control' -addext "subjectAltName=DNS:control"
        mkdir -p $out
        cp key.pem cert.pem $out
      '';

  # IPv4 prefix headscale allocates tailnet IPs from. Single source of truth
  # for both the headscale allocator and the nginx allow-list.
  tailnetCidrV4 = "100.64.0.0/10";

  helloVhost = # (2)
    { config, ... }:
    {
      services.nginx = {
        enable = true;
        virtualHosts.hello = {
          default = true;
          extraConfig = ''
            allow ${tailnetCidrV4};
            deny all;
          '';
          locations."/".return = "200 'hello from ${config.networking.hostName}\\n'";
        };
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 80 ];
    };

  tailscaleJoin = # (3)
    { config, ... }:
    {
      services.tailscale = {
        enable = true;
        authKeyFile = "/var/lib/tailscale/preauthkey";
        extraUpFlags = [
          "--login-server=https://control"
          "--hostname=${config.networking.hostName}"
        ];
      };
    };

  headscaleControlPlane = # (4)
    { config, ... }:
    {
      services.headscale = {
        enable = true;
        settings = {
          server_url = "https://control";
          derp = {
            # (5)
            urls = [ ];
            server = {
              enabled = true;
              region_id = 999;
              stun_listen_addr = "0.0.0.0:${toString config.services.tailscale.derper.stunPort}";
              # Pin IPv4 so tailscaled's netcheck doesn't need to DNS-resolve
              # the test-VLAN hostname.
              ipv4 = config.networking.primaryIPAddress;
            };
          };
          dns = {
            base_domain = "acme.internal";
            override_local_dns = false;
          };
          prefixes.v4 = tailnetCidrV4;
        };
      };

      networking.firewall.allowedUDPPorts = [ config.services.tailscale.derper.stunPort ];

      environment.systemPackages = [
        config.services.headscale.package
        pkgs.jq
      ];
    };

  tlsReverseProxy = # (6)
    { config, ... }:
    {
      services.nginx = {
        enable = true;
        virtualHosts.control = {
          onlySSL = true;
          sslCertificate = "${tls-cert}/cert.pem";
          sslCertificateKey = "${tls-cert}/key.pem";
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 443 ];
    };
in
{
  name = "headscale-tailnet-3node";

  # Every node must trust the self-signed control-plane certificate.
  defaults.security.pki.certificateFiles = [ "${tls-cert}/cert.pem" ];

  nodes = {
    control = {
      # (7)
      imports = [
        helloVhost
        tailscaleJoin
        headscaleControlPlane
        tlsReverseProxy
      ];
    };

    app = {
      imports = [
        helloVhost
        tailscaleJoin
      ];
    };

    client = {
      services.tailscale.enable = true;
    };
  };

  testScript = ''
    auth_key_path = "/var/lib/tailscale/preauthkey"

    start_all()

    control.wait_for_unit("headscale.service")
    control.wait_for_open_port(443)
    control.wait_for_unit("nginx.service")
    control.wait_for_unit("tailscaled.service")
    app.wait_for_unit("nginx.service")
    app.wait_for_unit("tailscaled.service")
    client.wait_for_unit("tailscaled.service")

    # In a real deployment, all servers would be freshly provisioned and
    # tailscaled-autoconnect would fail at boot because the pre-auth key
    # has not been distributed yet. The bootstrap therefore happens once
    # per deployment, in three steps:
    # 1.) the admin creates a user and an infra-wide pre-auth key.
    #     `headscale preauthkeys create` takes the numeric user ID, not
    #     the name, so we grab it from the user-creation JSON output.
    user_id = control.succeed(
        "headscale users create infra --output json | jq -r .id"
    ).strip()
    auth_key = control.succeed(
        f"headscale preauthkeys create --user {user_id} --reusable --expiration 24h "
        "--output json | jq -r .key"
    ).strip()

    # 2.) the admin ships the key via a secret-management tool (e.g. agenix)
    #     and redeploys. We emulate that by writing the key to disk with
    #     restrictive permissions and restarting the autoconnect unit:
    for s in [control, app]:
        s.succeed(
            f"umask 077 && mkdir -p $(dirname {auth_key_path}) && "
            f"echo {auth_key} > {auth_key_path}"
        )
        s.succeed("systemctl restart tailscaled-autoconnect.service")

    # 3.) all infra nodes are now members of the tailnet.

    # End-user devices (laptops, phones) usually join through the browser.
    # We emulate that flow on the CLI:
    client_key = control.succeed(
        f"headscale preauthkeys create --user {user_id} --reusable --expiration 24h "
        "--output json | jq -r .key"
    ).strip()
    client.execute(
        f"tailscale up --login-server 'https://control' "
        f"--auth-key {client_key} --hostname=client"
    )

    # Wait for an actual working tailnet path to each server.
    client.wait_until_succeeds("tailscale ping --c 1 --timeout 2s control")
    client.wait_until_succeeds("tailscale ping --c 1 --timeout 2s app")

    # Reach both nginx instances via MagicDNS over the tailnet.
    out1 = client.succeed("curl --fail --max-time 5 http://control.acme.internal/")
    assert "hello from control" in out1, f"unexpected: {out1!r}"

    out2 = client.succeed("curl --fail --max-time 5 http://app.acme.internal/")
    assert "hello from app" in out2, f"unexpected: {out2!r}"

    # nginx must NOT be reachable over the unsecured test LAN.
    client.fail("curl --fail --max-time 5 http://control/")
    client.fail("curl --fail --max-time 5 http://app/")
  '';
}
