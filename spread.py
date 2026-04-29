import math


def calc_intervals(xs: list[tuple[int, int]]) -> tuple[list[tuple[int, int]], list[int], list[int],
                                                       list[int], list[int], list[int]]:
    bs = sorted([x[i] for x in xs for i in range(2)])  # sorted bounds.
    bs = list(set(bs))
    print(f"\nbs: {bs}")

    b_plus = [0] * len(bs)   # num xs with max = bi.
    b_minus = [0] * len(bs)  # num xs with min = bi.
    b_idxs = {b: i for (i, b) in enumerate(bs)}
    for (xmin, xmax) in xs:
        b_plus[b_idxs[xmax]] += 1
        b_minus[b_idxs[xmin]] += 1
    print(f"\nb_plus: {b_plus}")
    print(f"b_minus: {b_minus}")

    intervals = []
    n_in = []     # num xs in interval.
    n_left = []   # num xs with max <= interval.
    n_right = []  # num xs with min >= interval.
    l = 0
    r = len(xs)
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

    es = []   # sum of extreme values (max for left and min for right) for every interval.
    es2 = []  # sum of squared extreme values.
    cur_es = sum(x[0] for x in xs)
    cur_es2 = sum(x[0]*x[0] for x in xs)
    for i in range(len(intervals)):
        # es gained = (new lefts (value is now their max) - no longer extreme rights) * min of new interval.
        left_gained = n_left[i] - (0 if i == 0 else n_left[i-1])
        right_lost = (len(xs) if i == 0 else n_right[i-1]) - n_right[i]
        d = (left_gained - right_lost) * intervals[i][0]
        cur_es += d
        cur_es2 += d * d * (-1 if d < 0 else 1)  # TODO: does this work?
        es.append(cur_es)
        es2.append(cur_es2)
    print(f"\nes: {es}")
    print(f"es2: {es2}")
    return intervals, n_in, n_left, n_right, es, es2


def calc_min_ssq(s: int, intervals: list[tuple[int, int]], n_in: list[int], es: list[int], es2: list[int]) -> tuple[float, float]:
    min_ssq = float("inf")
    for i, (imin, imax) in enumerate(intervals):
        sum_min = es[i] + n_in[i] * imin
        sum_max = es[i] + n_in[i] * imax
        if s < sum_min or s > sum_max:
            continue

        v = (s - es[i]) / n_in[i]
        sum_squares = es2[i] + n_in[i] * v*v
        min_ssq = min(sum_squares, min_ssq)
    return min_ssq, v


def calc_min_ssz(s: int, intervals: list[tuple[int, int]], n_in: list[int], es: list[int], es2: list[int]) -> tuple[int, float]:
    min_ssz = float("inf")
    for i, (imin, imax) in enumerate(intervals):
        sum_min = es[i] + n_in[i] * imin
        sum_max = es[i] + n_in[i] * imax
        if s < sum_min or s > sum_max:
            continue

        v = (s - es[i]) / n_in[i]
        v_plus = (s - es[i]) % n_in[i]
        v_minus = (n_in[i] - v_plus) % n_in[i]

        sum_squares = es2[i] + v_plus * math.ceil(v)**2 + v_minus * math.floor(v)**2
        min_ssz = min(sum_squares, min_ssz)
    return min_ssz, v


if __name__ == "__main__":
    xs = [(1, 3), (2, 6), (3, 9)]
    print(f"xs: {xs}")

    intervals, n_in, n_left, n_right, es, es2 = calc_intervals(xs)

    s = 10  # target sum.
    print(f"\ns: {s}")

    min_ssq, vq = calc_min_ssq(s, intervals, n_in, es, es2)
    assert min_ssq == 33.5
    print(f"\nmin_ssq: {min_ssq}")
    print(f"vq: {vq}")

    min_ssz, vz = calc_min_ssz(s, intervals, n_in, es, es2)
    assert min_ssz == 34
    print(f"\nmin_ssz: {min_ssz}")
    print(f"vz: {vz}")
