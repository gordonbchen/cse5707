# Knapsack

Team: Gordon Chen, Juan Wu-Lin Diego, Kevin Chen

### TLDR
`bb_bs2.cpp` is our fastest knapsack solver.

All `.cpp` files are knapsack solvers, `data/` contains test cases. Compile and run:

```
g++ -O3 -o bb_bs2 bb_bs2.cpp
bb_bs2 < data/canon.txt
```

| filename          | solution                                                                      |
| ----------------- | ----------------------------------------------------------------------------- |
| `dp.cpp`          | dynamic programming (table)                                                   |
| `recur.cpp`       | recursion (cached)                                                            |
| `bb.cpp`          | branch and bound                                                              |
| `bb_rev.cpp`      | `bb.cpp` + compute reversed ks for faster take branch upper bound             |
| `bb_rev_init.cpp` | `bb_rev.cpp` + init lower bound to greedy                                     |
| `bb_bs.cpp`       | `bb_rev_init.cpp` + compute upper bound using binary search                   |
| `bb_bs2.cpp`      | `bb_bs.cpp` + tighten init lb, floor frac knapsack, skip duplicates           |
| `hybrid.cpp`      | `bb_bs2.cpp` + switching to a DP solution if too many nodes are created (WIP) |

### Solution evolution
`dp.cpp` is a DP knapsack solver that fills out the knapsack DP table.

We came up with a pathological example `data/sparse.txt` where the weights and capacity are very large. This makes the DP table huge and take a long time to fill in. We call this example "sparse" since most ending knapsack weights are impossible to make. Our example has weights of all $10^6$, so only multiples of $10^6$ are possible knapsack ending weights, but `dp.cpp` still fills in all values in the table.

`recur.cpp` is a recursive knapsack solver that just uses a cache to avoid recomputing knapsack subproblems. It fixes the DP's problem with very sparse inputs since it only computes values in the table that can be reached, instead of the DP building the entire table up. However, for dense problems, `recur.cpp` is slower than dp.

`bb.cpp` uses branch and bound with the upper bound from fractional knapsack. `bb.cpp` uses a max heap to explore the node with the highest upper bound first.

`bb_rev.cpp` optimizes `bb.cpp` by not recomputing the entire fractional knapsack problem for the node that takes the item. `bb_rev.cpp` uses the fractional knapsack upper bound from the node that does not take the item, and runs fractional knapsack backwards from the ending item to correct for the take node using the additional item weight.

`bb_rev_init.cpp` improves upon `bb_rev.cpp` by setting the initial lower bound to the greedy knapsack solution (not fractional), instead of 0. That way, the inital lower bound will be higher and more nodes will be pruned more quickly.

`bb_bs.cpp` optimizes `bb_rev_init.cpp` by using binary search to compute the fractional knapsack upper bound. `bb_bs.cpp` first computes the running sum of weights and values (after sorting items by value / weight ratio). Then, to compute the fractional knapsack upper bound, `bb_bs.cpp` can just binary search, $\text{O}(\log n)$, for the additional residual capacity instead of having to linearly accumulate upwards each time.

We came up with a pathological example `data/corr200.txt` for all of our branch and bound solutions. Compared to our other generated test cases like the massive `data/hard.txt`, this example was very small, but our branch and bound implementations struggled with it a lot. While `data/hard.txt` has uniform random, uncorrelated weights and values, `data/corr200.txt` sets values = weights + random, making the value/weight ratios all about equal. Branch and bound struggles with this because when the ratios are all the same, the fractional knapsack upper bound barely moves depending on if you take or leave an item. The heuristic to take items with a higher ratio does not apply anymore because all of the ratios are the same. Branch and bound can't prune as quickly, and ends up exploring far more nodes.

`bb_bs2.cpp` includes some minor changes to `bb_bs.cpp` to make it perform better on correlated data, skipping identical items (same weight and value) in the exclusion branch. `bb_bs2.cpp` also tries to tighten the initial lower bound by filling in the rest of the max capacity with items, and uses the floor of the fractional knapsack solution as the upper bound. `bb_bs2.cpp` also uses a minor C++ fast IO optimization.

`hybrid.cpp` is still a work in progess. We came up with pathological examples for branch and bound that even our `bb_bs2.cpp` could not solve in a reasonable amount of time, so our idea was to make a hybrid program that started using the branch and bound solver, but if too many nodes in the branch and bound tree are created, then it switches to a DP solver. `hybrid.cpp` also tries to prevent 32-bit int overflow, but again this is still WIP.

### Datasets
| `data/`             | description                                                                        | items | capacity |
| ------------------- | ---------------------------------------------------------------------------------- | ----- | -------- |
| `canon.txt`         | canonical example from the assignment                                              | 32    | 770      |
| `tiny.txt`          | tiny example from the slides                                                       | 5     | 17       |
| `sparse.txt`        | few items, very large weight and capacity. pathological for DP.                    | 10    | 10M      |
| `hard.txt`          | very large example (hence "hard")                                                  | 50K   | 625M     |
| `corr{N}.txt`       | correlated examples (value = weights + random), pathological for branch and bound. |       |          |
| `HARD_corr10k.txt`  | correlated example with fewer repeated values                                      | 10K   | 25238058 |

`ks_gen.py` is a python script that generated uncorrelated examples (for `hard.txt`). We generated correlated examples by just slightly modifying `ks_gen.py` to generate values = weights + random.

### Benchmarks