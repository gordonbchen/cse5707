# Production Planning
Month | 0  | 1    | 2
------|----|----- |------
Stock |500 | 2000 | 1000


Month  | 3    | 4    | 5    | 6    | 7    | 8
-------|------|------|------|------|------|---------
Demand | 5000 | 6000 | 6500 | 7000 | 8000 | 9500


Max produced stock per month = 8000 units

$15 to produce, $0.75 to hold (calculated at the start of the month)

deterioriation: costs $25 per unit


Month         | t-2  | t-1 | t
--------------|------|-----|------
deterioration | 100% | 47% | 11%


Inspection for month 2 is coming.

Objectives: satisfy demand, minimize costs.

deterioriation cost -> holding cost -> production cost


# LP Formulation
## Vars
$d_t$: demand for month $t$.

$x_t$: units produced in month $t$.

$y_{i,j}$: units from month $i$ taken in month $j$.


## Constraints
Max stock production constraint: $x_t \le 8000$ <br><br>


Amount taken per month must equal demand.

$y_{1,3} + y_{2,3} + y_{3,3} = d_3$

$y_{2, 4} + y_{3, 4} + y_{4, 4} = d_4$

$y_{3, 5} + y_{4, 5} + y_{5, 5} = d_5$ <br><br>


Cannot take more than remaining.

$y_{1,3} \le 0.53 x_1 \qquad y_{2,3} \le 0.89 x_2 \qquad y_{3,3} \le x_3$

$y_{2,4} \le 0.53 (0.89 x_2 - y_{2,3}) \qquad y_{3,4} \le 0.89 (x_3 - y_{3,3}) \qquad y_{4,4} \le x_4$

$y_{3,5} \le 0.53 (0.89 (x_3 - y_{3,3}) - y_{3,4})) \qquad y_{4,5} \le 0.89 (x_4 - y_{4,4}) \qquad y_{5,5} \le x_5$


## Objective
production cost: $\qquad 15 \sum_{t} x_t$ <br><br>


deterioration cost:

End of month 2: $\qquad 25 (0.47 x_1 + 0.11 x_2)$

End of month 3: $\qquad 25 ((0.53 x_1 - y_{1,3}) + 0.47 (0.89 x_2 - y_{2,3}) + 0.11 (x_3 - y_{3,3}))$

End of month 4: $\qquad 25 (0.53 ((0.89 x_2 - y_{2,3}) - y_{2,4}) + 0.47 (0.89 (x_3 - y_{3,3}) - y_{3,4}) + 0.11 (x_4 - y_{4,4}))$

End of month 5: $\qquad 25 (0.53 (0.89 (x_3 - y_{3,3}) - y_{3,4}) - y_{3,5}) + 0.47 (0.89 (x_4 - y_{4,4}) - y_{4,5}) + 0.11 (x_5 - y_{5,5}))$ <br><br>


storage cost:

Start of month 3: $\qquad 0.75 (0.53 x_1 + 0.89 x_2)$

Start of month 4: $\qquad 0.75 (0.53 (0.89 x_2 - y_{2,3}) + 0.89 (x_3 - y_{3,3})$

Start of month 5: $\qquad 0.75 (0.53 (0.89 (x_3 - y_{3,3}) - y_{3,4}) + 0.89 (x_4 - y_{4,4}))$

Start of month 6: $\qquad 0.75 (0.53 (0.89 (x_4 - y_{4,4}) - y_{4,5}) + 0.89 (x_5 - y_{5,5}))$ <br><br>


objective: minimize production_cost + deterioration_cost + storage cost


# Solution
In an environment with `gurobi`, `gurobipy` and `numpy`, run `python3 prod_plan.py`.

Gurobi finds the following solution:

month            | 3    | 4    | 5          | 6    | 7    | 8
---------------- | ---- | ---- | ---------- | ---- | ---- | ----
units to produce | 3050 | 6000 | 7504.15763 | 8000 | 8000 | 8000

The minimum total (production + storage + deterioration) cost is $664188.1253.


# Gurobi Output
```
$ python3 prod_plan/prod_plan.py
Optimize a model with 30 rows, 24 columns and 71 nonzeros (Min)
Model fingerprint: 0xd809a249
Model has 21 linear objective coefficients and an objective constant of 89316.275
Coefficient statistics:
  Matrix range     [5e-01, 1e+00]
  Objective range  [3e+00, 4e+01]
  Bounds range     [0e+00, 0e+00]
  RHS range        [5e+02, 1e+04]

Presolve removed 11 rows and 4 columns
Presolve time: 0.00s
Presolved: 19 rows, 20 columns, 58 nonzeros

Iteration    Objective       Primal Inf.    Dual Inf.      Time
       0   -5.6815363e+05   7.680403e+03   0.000000e+00      0s
      11    6.6418813e+05   0.000000e+00   0.000000e+00      0s

Solved in 11 iterations and 0.00 seconds (0.00 work units)
Optimal objective  6.641881253e+05
[3050.      6000.      7504.15763 8000.      8000.      8000.     ]
[[1060.         0.         0.         0.         0.         0.     ]
 [ 890.         0.         0.       893.70029 1685.39326 1500.     ]
 [3050.      6000.      6500.      6106.29971 6314.60674 8000.     ]]
```