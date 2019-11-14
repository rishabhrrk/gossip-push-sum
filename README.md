# Gossip and Push-Sum Simulation using Elixir

This project implements the gossip and push-sum distributed computing
algorithms using Elixir to simulate multiple distributed nodes arranged
in different topologies.

## Running the program

You can run the program by

```
$ mix escript.build
$ ./my_program
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

## The largest network the algorithm works for:

### Gossip

If a convergence of 90% is attained, i.e. more than 90% of the nodes have
received the message at least once, we conclude that the algorithm has
successfully converged.

- Line - 500 nodes
- Full - 1000 nodes
- Random 2D - 3000 nodes
- 3D Torus - 5832 nodes
- Honeycomb - 5041 nodes
- Random Honeycomb - 5041 nodes

### Push-sum

If a convergence rate of 90% is reached, i.e. more than 90% of the nodes have
three consecutive S/W ratios to have not changed by 1e-10, we conclude that the
algorithm has successfully converged.

- Line - 500 nodes
- Full - 5000 nodes
- Random 2D - 3000 nodes
- 3D Torus - 5832 nodes
- Honeycomb - 5041 nodes
- Random Honeycomb - 5041 nodes
