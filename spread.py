import math


def calc_intervals(xs: list[tuple[int, int]], s: int) -> tuple[list[tuple[int, int]], list[int], list[int],
                                                               list[int], list[int], list[int], list[tuple[int, int]], int]:
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
        delta_count = left_gained - right_lost
        cur_es += delta_count * intervals[i][0]
        cur_es2 += delta_count * intervals[i][0]**2
        es.append(cur_es)
        es2.append(cur_es2)
    print(f"\nes: {es}")
    print(f"es2: {es2}")

    sum_ranges = []
    sum_interval_idx = -1  # TODO: this can be binary searched.
    for i, (imin, imax) in enumerate(intervals):
        sum_min, sum_max = (es[i] + n_in[i] * imin, es[i] + n_in[i] * imax)
        sum_ranges.append((sum_min, sum_max))
        if s in range(sum_min, sum_max+1):
            sum_interval_idx = i
            break
    assert sum_interval_idx >= 0, "Failed to find sum in sum intervals."
    print(f"\nsum_ranges: {sum_ranges}")
    print(f"sum_interval_idx: {sum_interval_idx}")
    return intervals, n_in, n_left, n_right, es, es2, sum_ranges, sum_interval_idx


def clamp(x, l, u):
    return min(max(x, l), u)


def update_x_max(
    intervals: list[tuple[int, int]], n_in: list[int], n_left: list[int], n_right: list[int], es: list[int],
    es2: list[int], s: int, sum_interval_idx: int, max_ss: float, x: tuple[int, int], v: float
) -> int:
    x_min, x_max = x
    x_cur = v

    # Cannot filter if x in left.
    if x_max <= intervals[sum_interval_idx][0]:
        return x_max

    for i in reversed(range(sum_interval_idx+1)):
        # x max is bound consistent if value is max. Cannot filter max more.
        if x_cur >= x_max:
            return x_max

        m, esi, es2i = update_interval_stats(x_cur, x, intervals[i], n_in[i], es[i], es2[i])

        # TODO: how does this case work?
        if m <= 0:
            continue

        # solve for maximum d can be increased by without violating max sum of squares.
        a = 1 + 1.0/m
        v_new = (s - esi) / m
        b = 2 * (x_cur - v_new)
        sum_squares = es2i + m*v_new*v_new
        c = sum_squares - max_ss
        d_opt = (-b + (b*b - 4*a*c)**0.5) / (2*a)

        interval_sum_min = esi + m*intervals[i][0]
        d_max = s - interval_sum_min  # maximum d can be increased by before v too small for interval.
        if d_opt > d_max:
            x_cur += d_max
            continue  # go down to next interval to keep increasing d.
        x_cur += d_opt

        # compute the maximum integral x.
        x_cur = math.floor(x_cur)
        m, esi, es2i = update_interval_stats(x_cur, x, intervals[i], n_in[i], es[i], es2[i])
        v_new = (s - esi) / m
        v_plus = (s - esi) % m
        v_minus = m - v_plus
        sum_squares = es2i + v_plus * (math.ceil(v_new)**2) + v_minus * (math.floor(v_new)**2)
        while sum_squares > max_ss:
            sum_squares += 2 * (math.ceil(v_new) - x_cur)  # TODO: wtf?
            x_cur -= 1
        break
    return min(x_cur, x_max)


def update_interval_stats(
    x_cur: float, x: tuple[int, int], interval: tuple[int, int], m: int, esi: int, es2i: int
) -> tuple[int, float, float]:
    x_min, x_max = x
    i_min, i_max = interval

    d = x_cur - x_min
    esi += d
    es2i += d*d + 2*d*x_min

    # Split interval (if x in M).
    if x_max > i_min and x_min < i_max:
        m -= 1
        esi += x_min
        es2i += x_min * x_min
    return m, esi, es2i


if __name__ == "__main__":
    xs = [(1, 3), (2, 6), (3, 9)]  # x bounds.
    print(f"xs: {xs}")

    s = 10  # target sum.
    print(f"\ns: {s}")

    intervals, n_in, n_left, n_right, es, es2, sum_ranges, sum_interval_idx = calc_intervals(xs, s)

    # Calculate the v Q center.
    vq = (s - es[sum_interval_idx]) / n_in[sum_interval_idx]
    print(f"\nvq: {vq}")

    min_ssq = es2[sum_interval_idx] + n_in[sum_interval_idx] * vq*vq
    print(f"min_ssq: {min_ssq}")
    assert min_ssq == 33.5

    vs = [clamp(vq, l, u) for (l, u) in xs]
    print(f"vs: {vs}")

    # Calculate the v Z center.
    v_plus = (s - es[sum_interval_idx]) % n_in[sum_interval_idx]
    v_minus = n_in[sum_interval_idx] - v_plus
    min_ssz = es2[sum_interval_idx] + v_plus * math.ceil(vq)**2 + v_minus * math.floor(vq)**2
    print(f"\nmin_ssz: {min_ssz}")
    assert min_ssz == 34

    max_ss = 34
    for x, v in zip(xs, vs):
        new_x_max = update_x_max(intervals, n_in, n_left, n_right, es, es2, s, sum_interval_idx, max_ss, x, v)
        print(x, new_x_max)
