#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <queue>
#include <tuple>
#include <vector>

// global prefix sum arrs
std::vector<long long> PS_WEIGHTS;
std::vector<long long> PS_VALUES;

struct Item {
    int v;
    int w;
    double r;
};

int ks_greedy(const std::vector<Item>& items, int c, int N, int* remc, bool &early_stop) {
    auto iterator = std::upper_bound(PS_WEIGHTS.begin(), PS_WEIGHTS.end(), c);
    int idx = std::distance(PS_WEIGHTS.begin(), iterator) - 1;

    *remc = c - (int)PS_WEIGHTS[idx];
    int value = (int)PS_VALUES[idx];

    // if frac_knap finds solution with all integer values ==> optimal solution
    // early stop is true
    // note: greedy knapsack (IFF ALLOW SKIPS) can return a non-optimal solution
    // even if all capacity is exhausted.
    // EX]
    // weights = [1,  10, 9]
    // values  = [2,  15, 10]
    // ratios  = [2, 1.5, 1.11]
    // capacity = 10
    // GREEDY (w/ skips)
    // item1 (2) + skips item2 (over cap) + item3 (10) = 12
    // but optimal is to just grab item2 (15) = 15
    if (*remc == 0) {
        early_stop = true;
        return value;
    }

    // fill the rest of capacity to tighten bound
    for (int i = idx + 1; i < N; ++i) {
        if (items[i].w <= *remc) {
            value += items[i].v;
            *remc -= items[i].w;
        }
    }

    return value;
}

int frac_ks(const std::vector<Item>& items, int item_i, int c, int N, int* endi, int* remc) {
    long long current_weight_offset = PS_WEIGHTS[item_i];
    long long target_weight = current_weight_offset + c;

    // binary search
    auto iterator = std::upper_bound(PS_WEIGHTS.begin() + item_i, PS_WEIGHTS.end(), target_weight);
    int idx = std::distance(PS_WEIGHTS.begin(), iterator) - 1;

    // sum of fully taken items
    double solution = (double) (PS_VALUES[idx] - PS_VALUES[item_i]);

    if (idx == N) {
        *endi = N;
        *remc = c - (int)(PS_WEIGHTS[N] - PS_WEIGHTS[item_i]);
        return (int)solution;
    }

    // update ending idx
    *endi = idx;

    long long weight_used = PS_WEIGHTS[idx] - PS_WEIGHTS[item_i];
    int local_rem = c - (int) weight_used;

    // add fractional if exists
    solution += local_rem*items[idx].r;

    *remc = local_rem;
    return (int)solution;
}

int frac_ks_rev(const std::vector<Item>& items, int starti, int endi, int N, int c, int remc) {
    double sol = 0.0;
    if (endi == N) {  // end of items, leftover capacity.
        if (remc >= c) { return 0.0; }
        c -= remc;
    }
    else if (remc > 0) {  // fractional was used.
        if (remc >= c) { return c * items[endi].r; }
        sol = remc * items[endi].r;
        c -= remc;
    }
    // endi-1: end of list (N-1), fractional (handled), fully took last item (endi not used).
    for (int i = endi - 1; i >= starti; --i) {
        if (c >= items[i].w) {
            c -= items[i].w;
            sol += items[i].v;
            continue;
        }
        sol += (int)(c * items[i].r);
        break;
    }
    return (int)sol;
}

int knapsack() {
    // Parse data.
    int N;
    std::cin >> N;

    std::vector<Item> items(N);

    int idx, v, w;
    for (int i = 0; i < N; ++i) {
        std::cin >> idx >> v >> w;
        items[i].v = v;
        items[i].w = w;
        items[i].r = static_cast<double>(v) / static_cast<double>(w);
    }

    int C;
    std::cin >> C;

    // Sort descending by v/w.
    std::sort(items.begin(), items.end(), [](const Item& a, const Item& b) { return a.r > b.r; });

    PS_WEIGHTS.resize(N+1,0);
    PS_VALUES.resize(N+1,0);
    for (int i=0; i<N; i++) {
        PS_WEIGHTS[i+1] = PS_WEIGHTS[i] + items[i].w;
        PS_VALUES[i+1] = PS_VALUES[i] + items[i].v;
    }

    // Init lb.
    int remc;
    bool early_stop = false;
    int lb = ks_greedy(items, C, N, &remc, early_stop);
    if (early_stop) { return lb; }
    // Solve.
    using Node = std::tuple<double, int, int, int>;  // ub, item_i, v, c.
    std::priority_queue<Node, std::vector<Node>> pq;
    pq.push({lb + 1, 0, 0, C});

    double cand_ub;
    int endi;

    while (!pq.empty()) {
        auto [ub, item_i, v, c] = pq.top();
        pq.pop();

        if (ub <= lb) { break; }

        if (item_i == (N-1)) {
            if (c >= items[item_i].w) {
                v += items[item_i].v;
            }
            lb = std::max(lb, v);
            continue;
        }

        // for the exclusion branch, exclude contiguous items w/ same value (removes some dupes)
        int next_i = item_i + 1;
        while (next_i < N && items[next_i].v == items[item_i].v && items[next_i].w == items[item_i].w) {
            next_i++;
        }

        cand_ub = v + frac_ks(items, item_i+1, c, N, &endi, &remc);
        if (cand_ub > lb) {
            pq.push({cand_ub, next_i, v, c});
        }

        if (c < items[item_i].w) { continue; }
        v += items[item_i].v;
        lb = std::max(lb, v);
        c -= items[item_i].w;
        cand_ub += items[item_i].v - frac_ks_rev(items, item_i+1, endi, N, items[item_i].w, remc);
        if (cand_ub > lb) {
            pq.push({cand_ub, item_i+1, v, c});
        }
    }

    return lb;
}

int main() {
    auto start = std::chrono::high_resolution_clock::now();

    int sol = knapsack();
    std::cout << sol << "\n1\n";

    auto stop = std::chrono::high_resolution_clock::now();
    double seconds = std::chrono::duration<double>(stop - start).count();
    std::cout << seconds << '\n';
}
