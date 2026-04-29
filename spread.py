import math


def calc_intervals(xs: list[tuple[int, int]]) -> tuple[list[tuple[int, int]], list[int], list[int],
                                                       list[int], list[int], list[int], list[tuple[int, int]]]:
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

    sum_ranges = [(es[i] + n_in[i] * imin, es[i] + n_in[i] * imax) for i, (imin, imax) in enumerate(intervals)]
    print(f"\nsum_ranges: {sum_ranges}")
    return intervals, n_in, n_left, n_right, es, es2, sum_ranges


def calc_min_ssq(s: int, sum_ranges: list[tuple[int, int]], n_in: list[int], es: list[int], es2: list[int]) -> tuple[float, float]:
    min_ssq = float("inf")
    for i, sum_range in enumerate(sum_ranges):
        if not s in range(*sum_range):
            continue

        v = (s - es[i]) / n_in[i]
        sum_squares = es2[i] + n_in[i] * v*v
        min_ssq = min(sum_squares, min_ssq)
    return min_ssq, v


def calc_min_ssz(s: int, sum_ranges: list[tuple[int, int]], n_in: list[int], es: list[int], es2: list[int]) -> tuple[int, float]:
    min_ssz = float("inf")
    for i, sum_range in enumerate(sum_ranges):
        if not s in range(*sum_range):
            continue

        v = (s - es[i]) / n_in[i]
        v_plus = (s - es[i]) % n_in[i]
        v_minus = (n_in[i] - v_plus) % n_in[i]

        sum_squares = es2[i] + v_plus * math.ceil(v)**2 + v_minus * math.floor(v)**2
        min_ssz = min(sum_squares, min_ssz)
    return min_ssz, v


def clamp(x, l, u):
    return min(max(x, l), u)


# TODO: finish.
def update_x_max(intervals: list[tuple[int, int]], n_in: list[int], n_left: list[int], n_right: list[int], es: list[int],
                 es2: list[int], sum_ranges: list[tuple[int, int]], x: tuple[int, int], vq: float) -> int:
    x_min, x_max = x
    for i_min, i_max in intervals:
        # No filtering if x is in the left since x_max is the value.
        if x_max <= i_min:
            return x_max


if __name__ == "__main__":
    xs = [(1, 3), (2, 6), (3, 9)]
    print(f"xs: {xs}")

    intervals, n_in, n_left, n_right, es, es2, sum_ranges = calc_intervals(xs)

    s = 10  # target sum.
    print(f"\ns: {s}")

    min_ssq, vq = calc_min_ssq(s, sum_ranges, n_in, es, es2)
    assert min_ssq == 33.5
    print(f"\nmin_ssq: {min_ssq}")
    print(f"vq: {vq}")

    vs = [clamp(vq, l, u) for (l, u) in xs]
    print(f"vs: {vs}")

    min_ssz, vz = calc_min_ssz(s, sum_ranges, n_in, es, es2)
    assert min_ssz == 34
    print(f"\nmin_ssz: {min_ssz}")
    print(f"vz: {vz}")
