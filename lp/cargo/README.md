# Cargo Problem
Hold    | Max Weight (Tonnes) | Space capacity (Cubic Meters)
------- | ------------------- | ------------------------------
Front   | 10                  | 6800
Center  | 16                  | 8700
Back    | 8                   | 5300

weight of cargo in hold must be proportional to max weight


Cargo  | Weight (Tonnes) | Volume (Cubic meters) |  Profit / Tonne ($)
-------|-----------------|-----------------------|---------------------
C1     | 18              | 480                   |  310
C2     | 15              | 650                   |  380
C3     | 23              | 580                   |  350
C4     | 12              | 390                   |  285



# LP Formulation
```
idx:
    cargo type x (1,2,3,4)
    hold y (h,c,b)

variables:
    w_xy = weight of cargo x in hold y
    C_x = max cargo weight
    H_y = max weight of hold y

    p_x = per-ton profit of cargo x

    v_x = per-ton volume of cargo x
    V_y = max volume of hold y


objective:
    maximize    sum_xy (w_xy * p_x)        sum of all profits

subject to:
    for each x:    sum_y w_xy <= C_x       max cargo weight

    for each y:    sum_x w_xy <= H_y       max hold weight

    proportions:
        16 sum_x w_xf = 10 sum_x w_xc
        8 sum_x w_xc = 16 sum_x w_xb

    for each y:    sum_x w_xy v_x <= V_y   max volume in hold
```


# Solution
In an environment with gurobi and numpy, run: `python3 cargo.py`

Gurobi finds the following solution:

-   | Front   | Center       | Back
--- | ------- | ------------ | -----
C1  | 0       | 0            | 0
C2  | 10      | 0            | 5
C3  | 0       | 12.94736842  | 3
C4  | 0       | 3.05263158   | 0

Optimal objective: profit = 12151.57894736842


# Gurobi Output
```
$ python3 cargo.py
Model has 12 linear objective coefficients
Coefficient statistics:
  Matrix range     [1e+00, 6e+02]
  Objective range  [3e+02, 4e+02]
  Bounds range     [0e+00, 0e+00]
  RHS range        [8e+00, 9e+03]

Presolve time: 0.00s
Presolved: 12 rows, 12 columns, 52 nonzeros

Iteration    Objective       Primal Inf.    Dual Inf.      Time
       0    1.2421875e+32   3.215234e+31   1.242188e+02      0s
       6    1.2151579e+04   0.000000e+00   0.000000e+00      0s

Solved in 6 iterations and 0.00 seconds (0.00 work units)
Optimal objective  1.215157895e+04
[[ 0.          0.          0.        ]
 [10.          0.          5.        ]
 [ 0.         12.94736842  3.        ]
 [ 0.          3.05263158  0.        ]]
12151.57894736842

hold volumes: [6500. 8700. 4990.]
max hold volumes: [6800. 8700. 5300.]

hold weights: [10. 16.  8.]
max hold weights: [10. 16.  8.]

cargo weights: [ 0.         15.         15.94736842  3.05263158]
max cargo weights: [18. 15. 23. 12.]

hold ratio: [10. 16.  8.]
required ratio: [10, 16, 8]
```
