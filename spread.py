import math


xs = [(1, 3), (2, 6), (3, 9)]
print(f"xs: {xs}")


# bs: sorted bounds.
bs = sorted([x[i] for x in xs for i in range(2)])
bs = list(set(bs))
print(f"\nbs: {bs}")


# b+: |{xi | xmax == bi}|.
# b-: |{xi | xmin == bi}|.
b_plus = [0] * len(bs)
b_minus = [0] * len(bs)
b_idxs = {b: i for (i, b) in enumerate(bs)}
for (xmin, xmax) in xs:
    b_plus[b_idxs[xmax]] += 1
    b_minus[b_idxs[xmin]] += 1
print(f"\nb_plus: {b_plus}")
print(f"b_minus: {b_minus}")


n_left = []  # num xs with max <= interval [b1, b2].
n_right = []  # num xs with min >= interval.
l = 0
r = len(xs)

intervals = []
n_in = []  # num xs in interval.
for i in range(1, len(bs)):
    intervals.append((bs[i-1], bs[i]))

    l += b_plus[i-1]
    r -= b_minus[i-1]
    n_left.append(l)
    n_right.append(r)
    
    n_in.append(len(xs) - l - r)

print(f"\nintervals: {intervals}")
print(f"n_in: {n_in}")
print(f"n_left: {n_left}")
print(f"n_right: {n_right}")


extreme_sums = []
extreme_sums2 = []
es = sum(x[0] for x in xs)
es2 = sum(x[0]*x[0] for x in xs)
for i in range(len(intervals)):
    p = n_left[i] - (0 if i == 0 else n_left[i-1])
    q = (len(xs) if i == 0 else n_right[i-1]) - n_right[i]  # TODO: not sure why this works.
    d = (p - q) * (intervals[0][0] if i == 0 else intervals[i-1][1])
    es += d
    es2 += d * d * (-1 if d < 0 else 1)  # TODO: does this work?
    extreme_sums.append(es)
    extreme_sums2.append(es2)
print(f"\nextreme_sums: {extreme_sums}")
print(f"extreme_sums2: {extreme_sums2}")


s = 10  # target sum.
def calc_min_sum_squares_Q(s: int, intervals: list[tuple[int, int]], n_in: list[int], extreme_sums: list[int], extreme_sums2: list[int]):
    min_sum_squares = float("inf")
    for i, (interval_min, interval_max) in enumerate(intervals):
        sum_interval_min = extreme_sums[i] + n_in[i] * interval_min
        sum_interval_max = extreme_sums[i] + n_in[i] * interval_max
        if s < sum_interval_min or s > sum_interval_max:
            continue

        v = (s - extreme_sums[i]) / n_in[i]
        sum_squares = extreme_sums2[i] + n_in[i] * v*v
        min_sum_squares = min(sum_squares, min_sum_squares)
    return min_sum_squares
print(f"min_sum_squares: {calc_min_sum_squares_Q(s, intervals, n_in, extreme_sums, extreme_sums2)}")


# Computing the min sum of squares when x are ints.
def calc_min_sum_squares_Z(s: int, intervals: list[tuple[int, int]], n_in: list[int], extreme_sums: list[int], extreme_sums2: list[int]):
    min_sum_squares = float("inf")
    for i, (interval_min, interval_max) in enumerate(intervals):
        sum_interval_min = extreme_sums[i] + n_in[i] * interval_min
        sum_interval_max = extreme_sums[i] + n_in[i] * interval_max
        if s < sum_interval_min or s > sum_interval_max:
            continue

        v = (s - extreme_sums[i]) / n_in[i]
        v_plus = (s - extreme_sums[i]) % n_in[i]
        v_minus = (n_in[i] - v_plus) % n_in[i]

        sum_squares = extreme_sums2[i] + v_plus * math.ceil(v)**2 + v_minus * math.floor(v)**2
        min_sum_squares = min(sum_squares, min_sum_squares)
    return min_sum_squares
print(f"min_sum_squares: {calc_min_sum_squares_Z(s, intervals, n_in, extreme_sums, extreme_sums2)}")