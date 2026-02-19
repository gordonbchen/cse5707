import gurobipy as gp
from gurobipy import GRB
import numpy as np

# Create a model.
m = gp.Model("matrix1")

# Vars.
N_CARGO = 4
N_HOLD = 3
w = m.addMVar(shape=(N_CARGO,N_HOLD), vtype=GRB.CONTINUOUS, name="w")

# Objective.
PROFITS = np.array([310, 380, 350, 285], dtype=np.float64)
m.setObjective((w.T @ PROFITS).sum(), GRB.MAXIMIZE)

# Constraints.
MAX_CARGO_WEIGHTS = np.array([18, 15, 23, 12], dtype=np.float64)
m.addConstr(w.sum(axis=1) <= MAX_CARGO_WEIGHTS, name="cargo weight")

MAX_HOLD_WEIGHTS = np.array([10, 16, 8], dtype=np.float64)
m.addConstr(w.sum(axis=0) <= MAX_HOLD_WEIGHTS, name="hold weight")

VOLUMES = np.array([480, 650, 580, 390], dtype=np.float64)
MAX_HOLD_VOLUMES = np.array([6800, 8700, 5300], dtype=np.float64)
m.addConstr(w.T @ VOLUMES <= MAX_HOLD_VOLUMES, name="hold volumes")

hold_weights = w.sum(axis=0)
m.addConstr(16 * hold_weights[0] == 10 * hold_weights[1], "prop_fc")
m.addConstr(8 * hold_weights[0] == 10 * hold_weights[2], "prop_fc")

# Optimize.
m.optimize()

print(w.X)
print(m.ObjVal)

# Checks.
print("\nhold volumes:", w.X.T @ VOLUMES)
print("max hold volumes:", MAX_HOLD_VOLUMES)

print("\nhold weights:", w.X.sum(axis=0))
print("max hold weights:", MAX_HOLD_WEIGHTS)

print("\ncargo weights:", w.X.sum(axis=1))
print("max cargo weights:", MAX_CARGO_WEIGHTS)

hold_weights = w.X.sum(axis=0)
print("\nhold ratio:", (hold_weights / hold_weights.sum()) * 34)
print("required ratio:", [10, 16, 8])
