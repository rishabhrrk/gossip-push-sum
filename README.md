# Gossip and Push-Sum Simulation using Elixir

This project implements the gossip and push-sum distributed computing
algorithms using Elixir to simulate multiple ditributed nodes arranged
in different topologies.

## Running the program

You can run the program by

```
$ mix escript.build
$ ./gossip_simulator
Usage: mix run gossip_simulator.exs num_nodes topology algorithm

Available topologies:
- full
- line
- rand2D
- 3Dtorus
- honeycomb
- randhoneycomb

Available algorithms:
- gossip
- push-sum
```

or

```
$ mix run gossip_simulator.exs
Usage: mix run gossip_simulator.exs num_nodes topology algorithm

Available topologies:
- full
- line
- rand2D
- 3Dtorus
- honeycomb
- randhoneycomb

Available algorithms:
- gossip
- push-sum
```
