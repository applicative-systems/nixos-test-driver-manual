from test_driver.machine import QemuMachine


def mytest(machine1: QemuMachine, machine2: QemuMachine) -> None:
    machine1.start()
    machine2.start()

    machine1.systemctl("start network-online.target")
    machine2.systemctl("start network-online.target")

    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    machine1.succeed("ping -c 1 machine2")
    machine2.succeed("ping -c 1 machine1")
