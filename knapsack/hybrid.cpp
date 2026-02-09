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

long long ks_greedy(const std::vector<Item>& items, int c, int N, int* remc, bool &early_stop) {
    auto iterator = std::upper_bound(PS_WEIGHTS.begin(), PS_WEIGHTS.end(), c);
    int idx = std::distance(PS_WEIGHTS.begin(), iterator) - 1;

    *remc = c - (int)PS_WEIGHTS[idx];
    long long value = PS_VALUES[idx];

    if (*remc == 0) {
        early_stop = true;
        return value;
    }

    for (int i = idx + 1; i < N; ++i) {
        if (items[i].w <= *remc) {
            value += items[i].v;
            *remc -= items[i].w;
        }
    }

    return value;
}

long long frac_ks(const std::vector<Item>& items, int item_i, int c, int N, int* endi, int* remc) {
    long long current_weight_offset = PS_WEIGHTS[item_i];
    long long target_weight = current_weight_offset + c;

    auto iterator = std::upper_bound(PS_WEIGHTS.begin() + item_i, PS_WEIGHTS.end(), target_weight);
    int idx = std::distance(PS_WEIGHTS.begin(), iterator) - 1;

    long long solution = (PS_VALUES[idx] - PS_VALUES[item_i]);

    if (idx == N) {
        *endi = N;
        *remc = c - (int)(PS_WEIGHTS[N] - PS_WEIGHTS[item_i]);
        return (long long)solution;
    }

    *endi = idx;

    long long weight_used = PS_WEIGHTS[idx] - PS_WEIGHTS[item_i];
    int local_rem = c - (int) weight_used;

    solution += ((long long)local_rem*items[idx].v) / items[idx].w;

    *remc = local_rem;
    return solution;
}

long long frac_ks_rev(const std::vector<Item>& items, int starti, int endi, int N, int c, int remc) {
    long long sol = 0;
    if (endi == N) {  // end of items, leftover capacity.
        if (remc >= c) { return 0; }
        c -= remc;
    }
    else if (remc > 0) {  // fractional was used.
        if (remc >= c) {
            return (long long)(c * items[endi].r);
        }
        sol += (long long)(remc * items[endi].r);
        c -= remc;
    }
    // endi-1: end of list (N-1), fractional (handled), fully took last item (endi not used).
    for (int i = endi - 1; i >= starti; --i) {
        if (c >= items[i].w) {
            c -= items[i].w;
            sol += items[i].v;
            continue;
        }
        sol += (long long)(c*items[i].r);
        break;
    }
    return sol;
}

long long dp(const std::vector<Item>& items, int C, int N) {
    std::vector<long long> prev_dp(C+1, 0);
    std::vector<long long> curr_dp(C+1, 0);

    for (int item_idx = 0; item_idx < N; ++item_idx) {
        for (int cap = 0; cap <= C; ++cap) {
            long long take, skip;
            skip = prev_dp[cap];
            take = 0;

            bool item_fits_bag = (cap >= items[item_idx].w);
            if (item_fits_bag) {
                take = prev_dp[cap - items[item_idx].w] + items[item_idx].v;
            }

            curr_dp[cap] = std::max(skip, take);
        }
        // swap the rows
        prev_dp = curr_dp;
    }
    return prev_dp[C];
}

long long dfs(const std::vector<Item>& items, int C, int N, long long lb, int &nodes_limit, int &is_complete) {
    using Node = std::tuple<long long, int, long long, int>;  // ub, item_i, v, c
    std::vector<Node> stack;
    stack.reserve(3*N);
    stack.push_back({lb + 1, 0, 0, C});

    long long cand_ub;
    int endi, remc, nodes_processed;
    nodes_processed = 0;

    while (!stack.empty()) {
        // force stop
        if (++nodes_processed >= nodes_limit) {
            is_complete = 0;
            return lb;
        }

        auto [ub, item_i, v, c] = stack.back();
        stack.pop_back();

        // continue instead of break
        if (ub <= lb) { continue; }

        if (item_i == (N-1)) {
            if (c >= items[item_i].w) {
                v += items[item_i].v;
            }
            lb = std::max(lb, v);
            continue;
        }

        // use take_endi, remc to save state for take branch
        int take_endi, take_remc;
        cand_ub = v + frac_ks(items, item_i+1, c, N, &endi, &remc);
        take_endi = endi;
        take_remc = remc;

        // for the exclusion branch, exclude contiguous items w/ same value
        int next_i = item_i + 1;
        while (next_i < N && items[next_i].v == items[item_i].v && items[next_i].w == items[item_i].w) {
            next_i++;
        }

        long long ub_skip;
        if (next_i == item_i+1) {
            ub_skip = cand_ub;
        }
        else {
            ub_skip = v + frac_ks(items, next_i, c, N, &endi, &remc);
        }

        if (ub_skip > lb) {
            stack.push_back({ub_skip, next_i, v, c});
        }

        if (c < items[item_i].w) { continue; }
        v += items[item_i].v;
        lb = std::max(lb, v);
        c -= items[item_i].w;
        cand_ub += items[item_i].v - frac_ks_rev(items, item_i+1, take_endi, N, items[item_i].w, take_remc);
        if (cand_ub > lb) {
            stack.push_back({cand_ub, item_i+1, v, c});
        }
    }
    return lb;
}
long long knapsack(int &is_complete) {
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
    int endi, remc;
    bool early_stop = false;
    long long lb = ks_greedy(items, C, N, &remc, early_stop);
    if (early_stop) { return lb; }

    // calculate global upperbound, if global upperbound <= LB, then LB is optimal
    // (early stop 2)
    long long ub_start = frac_ks(items, 0, C, N, &endi, &remc);
    if (ub_start <= lb) { return lb; }

    // Solve.
    using Node = std::tuple<long long, int, long long, int>;  // ub, item_i, v, c.
    std::priority_queue<Node, std::vector<Node>> pq;
    pq.push({lb + 1, 0, 0, C});

    long long cand_ub;
    int nodes_processed = 0;

    while (!pq.empty()) {
        // force stop
        if (++nodes_processed >= 10'000'000) {
            // only DP bottleneck is memory, O(2C) memory ==> O(C)
            if (C <= 500'000) { return dp(items, C, N); }
            // return an approximation, and set is_complete to false
            is_complete = 0;
            int dfs_nodes_limit = 5'000'000;
            // pivot to dfs first, for possibly a better approximation
            // since best first likely gone into a branch in depth
            return dfs(items, C, N, lb, dfs_nodes_limit, is_complete);
        }
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

        // use take_endi, remc to save state for take branch
        int take_endi, take_remc;
        // moved up, so can use later
        cand_ub = v + frac_ks(items, item_i+1, c, N, &endi, &remc);
        take_endi = endi;
        take_remc = remc;

        // for the exclusion branch, exclude contiguous items w/ same value (removes some dupes)
        int next_i = item_i + 1;
        while (next_i < N && items[next_i].v == items[item_i].v && items[next_i].w == items[item_i].w) {
            next_i++;
        }

        long long ub_skip;
        if (next_i == item_i+1) {
            ub_skip = cand_ub;
        }
        else {
            ub_skip = v + frac_ks(items, next_i, c, N, &endi, &remc);
        }

        if (ub_skip > lb) {
            pq.push({ub_skip, next_i, v, c});
        }

        if (c < items[item_i].w) { continue; }
        v += items[item_i].v;
        lb = std::max(lb, v);
        c -= items[item_i].w;
        cand_ub += items[item_i].v - frac_ks_rev(items, item_i+1, take_endi, N, items[item_i].w, take_remc);
        if (cand_ub > lb) {
            pq.push({cand_ub, item_i+1, v, c});
        }
    }

    return lb;
}

int main() {
    auto start = std::chrono::high_resolution_clock::now();

    // Fast IO.
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(NULL);
    std::cout.tie(NULL);

    int is_complete = 1;
    // int --> long long
    long long sol = knapsack(is_complete);
    std::cout << sol << "\n" << is_complete << "\n";

    auto stop = std::chrono::high_resolution_clock::now();
    double seconds = std::chrono::duration<double>(stop - start).count();
    std::cout << seconds << '\n';
}
