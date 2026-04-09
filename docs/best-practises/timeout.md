# Always set timeouts

always set timeouts

- top-level attribute `globalTimeout` exists
  - nixos manual link: https://nixos.org/manual/nixos/stable/#test-opt-globalTimeout
  - explanation: A global timeout for the complete test, expressed in seconds. Beyond that timeout, every resource will be killed and released and the test will fail. default is 1 hour.

machine methods with timeouts (list these as a nice table):

the list is rather long and the nixos manual already lists them here: https://nixos.org/manual/nixos/stable/#ssec-machine-objects

show these as an example:

these methods are typically used without timeouts but individual timeouts can be set. see the manual for all the other functions with timeouts.

- wait_for_open_port(port, addr, timeout)
- wait_for_closed_port(port, addr, timeout)

why would you want to use timeouts:

- make tests fail faster if they take much too long
- developers get faster feedback loops this way
- when tests fail earlier in the CI, resources are freed for other tests. better overall throughput.
