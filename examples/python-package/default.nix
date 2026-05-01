{
  name = "Test using a custom python package";

  nodes = {
    machine1 = { };
    machine2 = { };
  };

  defaults = {
    networking.dhcpcd.enable = false;
  };

  globalTimeout = 60;

  extraPythonPackages = p: [
    (p.callPackage ./usertest { })
  ];

  testScript = ''
    from usertest import mytest

    mytest(machine1=machine1, machine2=machine2)
  '';
}
