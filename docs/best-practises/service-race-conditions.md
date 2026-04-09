# Avoid race-conditions

excerpt from the anti-patterns book:

#import "/globals.typ": *

== Double check service units and open ports

It can happen that a test with one or multiple VMs runs well on slower
hardware (like your laptop) but then fails on faster hardware
(like your CI).

In this example we are looking at a very typical test that will not
have this problem and discuss, why:

#code-box-good(
```nix
# file: test.nix
{
  name = "Hello Test";

  nodes = {
    server = {
      services.httpd.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
    client = { };
  };

  testScript = ''
    start_all()

    # 1. ensure networking
    for m in [server, client]:
      m.systemctl("start network-online.target")
      m.wait_for_unit("network-online.target")

    # 2. ensure service
    server.wait_for_unit("httpd.service")
    server.wait_for_open_port(80)

    # 3. test service
    client.succeed("curl http://server")
  '';
}
```
)

The Nix snippet for creating a derivation from this test is:

#code-box(
```nix
test = pkgs.testers.runNixOSTest ./test.nix;
```
)

To make this test completely reliable on slow and fast machines,
the exercise performs the following steps:

#[

#set enum(numbering: "1.a.")

+ Because networking is required, start `network-online.target` and
  wait for this systemd unit to finish.
+
  + Make sure to wait for the to-be-tested service's systemd unit startup to finish.
  + In addition to the systemd unit start, wait for the system's
    port(s) to open.
+ Test the service meaningfully.
]

#note-box[
Point 1 might be new or surprising to some:
In NixOS, the systemd target `network-online.target` is no longer a direct dependency of `multi-user.target`, which is more _correct_ but also introduced some hanging tests here and there.
]

=== Why wait for the port in addition to the systemd unit?

On slower machines, a test like this will most likely always work:

#code-box-bad(
```
server.wait_for_unit("httpd.service")
client.succeed("curl http://server")
```
)

Then, on a faster machine, the test might _often_ fail on the second
line.
Why?
Slow machines take some time between these lines, but very often, fast
machines with many cores start sending network packets to the service
while the process behind the systemd service unit is still in some
startup routine (e.g. checking config files and starting child
processes).

Waiting for the port to open is the only way to make sure that the
service is really ready for work.

=== Why not _only_ wait for the port?

Now, one might think: "It's easier and more straight-forward to just
test for the port - I am not testing to see if systemd works in
general, anyway."
and then write test code like this:

#code-box-bad(
```
server.wait_for_open_port(80)
client.succeed("curl http://server")
```
)

The nature of `wait_for_open_port` is to loop until the port is open.
A timeout will throw an exception after some time if the port does not
open.

One common reason for the port not to open is configuration errors.
In that case, this code would block the build infrastructure for a minute before it errors out -- and then even lack information on _why_ the test failed.

Waiting for the systemd unit first and _then_ waiting for the port
ensures that the service comes up at all before entering the timeout loop.
If anything happens inbetween, the test fails earlier and provides better information about the reason.
At the same time, it provides the right synchronisation to properly run on fast and slow machines.
