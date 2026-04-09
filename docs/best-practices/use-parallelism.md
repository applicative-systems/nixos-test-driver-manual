# Use Parallelism

Multi-node tests have a natural advantage: many setup steps can run on several machines at the same time.
If you accidentally serialize that work, the test becomes slower than necessary.

Still, this is not a hard rule.
Sometimes sequential execution is the better choice, for example when you want to fail early before starting more machines and consuming more CPU, memory, or I/O.
Most of the time, however, independent setup work should be started in parallel.

## A common serial pattern

This loop is simple, but it fully finishes one machine before the next machine even starts the same work:

```python
machines = [machine1, machine2, machine3]

for m in machines:
    m.systemctl("start network-online.target")
    m.wait_for_unit("network-online.target")
```

If `network-online.target` takes a few seconds per machine, the total runtime becomes roughly the sum of all three waits.

`network-online.target` is only an example here.
The same pattern appears with other long-running and independent setup work, such as:

- starting services
- triggering initialization jobs
- warming caches
- waiting for background preparation to finish

## The parallel version

When each machine can make progress independently, it is usually better to split the operation into two phases:

1. Start the work everywhere.
2. Wait for completion everywhere.

```python
machines = [machine1, machine2, machine3]

for m in machines:
    m.systemctl("start network-online.target")

for m in machines:
    m.wait_for_unit("network-online.target")
```

This allows all machines to work at the same time.
The total runtime is then closer to the slowest machine instead of the sum of all machines.

## Why this is faster

The timing difference looks like this:

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   **Sequential setup**

    ```python
    machines = [machine1, machine2, machine3]

    for m in machines:
        m.systemctl("start network-online.target")
        m.wait_for_unit("network-online.target")
    ```

    ```plantuml
    @startuml
    scale 1 as 100 pixels

    rectangle "machine1" as m1
    rectangle "machine2" as m2
    rectangle "machine3" as m3

    @0
    m1 is idle
    m2 is idle
    m3 is idle

    @1
    m1 is "start + wait" #lightgreen
    m2 is idle #yellow
    m3 is idle #yellow

    @2
    m1 is ready
    m2 is "start + wait" #lightgreen
    m3 is idle

    @3
    m1 is ready
    m2 is ready
    m3 is "start + wait" #lightgreen

    @4
    m1 is ready
    m2 is ready
    m3 is ready
    @enduml
    ```

    Here, `machine2` does not even begin until `machine1` is done, and `machine3` waits for both.

-   **Parallel setup**

    ```python
    machines = [machine1, machine2, machine3]

    for m in machines:
        m.systemctl("start network-online.target")

    for m in machines:
        m.wait_for_unit("network-online.target")
    ```

    ```plantuml
    @startuml
    scale 1 as 100 pixels

    rectangle "machine1" as m1
    rectangle "machine2" as m2
    rectangle "machine3" as m3

    @0
    m1 is idle
    m2 is idle
    m3 is idle

    @1
    m1 is "start + wait" #lightgreen
    m2 is "start + wait" #lightgreen
    m3 is "start + wait" #lightgreen

    @2
    m1 is ready
    m2 is ready
    m3 is ready

    @enduml
    ```

    Here, all three machines make progress at the same time.

</div>

<!-- prettier-ignore-end -->

## When sequential execution is still reasonable

Parallelism is usually the better default, but there are cases where sequential execution is intentional:

- you want to fail fast on the first machine before starting more expensive work
- later machines depend on an earlier machine becoming healthy first
- starting everything at once would create avoidable resource pressure on the host

For example, if `machine1` fails to come up cleanly, it can be better to stop there instead of also booting and preparing several more machines that are not yet needed.

The best practice is not "Always parallelize".
It is: "Always parallelize independent work unless you have a concrete reason not to."

## A practical rule of thumb

If an operation on several nodes is:

- independent across machines
- expected to take noticeable time
- needed on all machines anyway

then this pattern is usually a good choice:

```python
for m in machines:
    start_some_long_running_step(m)

for m in machines:
    wait_until_that_step_finished(m)
```

That keeps the test readable while still taking advantage of the parallelism available in a multi-node setup.
