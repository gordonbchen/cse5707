import gurobipy as gp
from gurobipy import GRB
import numpy as np


m = gp.Model("matrix1")

x = m.addMVar(shape=6, vtype=GRB.CONTINUOUS, name="x")
m.addConstr(x <= 8000, name="max stock production")

y = m.addMVar(shape=(3,6), vtype=GRB.CONTINUOUS, name="y")

demand = np.array([5000, 6000, 6500, 7000, 8000, 9500], dtype=np.float64)
m.addConstr(y.sum(axis=0) == demand, name="meet demand")


stock = [500, 2000, 1000]
DIE_RATES = [1, 0.47, 0.11]

dead_product = 0
held_product = 0

for month in range(3, 9):
    for i, t in enumerate(range(month-3, month)):
        # Deteriorate: end of prev month.
        dead_product += stock[t] * DIE_RATES[i]
        stock[t] *= 1 - DIE_RATES[i]

        # Storage: start of month.
        held_product += stock[t]

    # Produce.
    stock.append(x[month-3])
    for i, t in enumerate(range(month-2, month+1)):
        # Constrain and sell product.
        m.addConstr(y[i][month-3] <= stock[t], name="sell in stock")
        stock[t] -= y[i][month-3]

m.setObjective((15 * x.sum()) + 25*dead_product + 0.75*held_product, GRB.MINIMIZE)
m.optimize()

print(x.X.round(5))
print(y.X.round(5))