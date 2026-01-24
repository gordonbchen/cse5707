#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <queue>
#include <tuple>
#include <vector>

struct Item {
    int v;
    int w;
    double r;
};

double frac_ks(const std::vector<Item>& items, int item_i, int c, int N) {
    double sol = 0.0;
    for (int i = item_i; i < N; ++i) {
        if (c >= items[i].w) {
            c -= items[i].w;
            sol += items[i].v;
            continue;
        }
        sol += (static_cast<double>(c) / static_cast<double>(items[i].w)) * items[i].v;
        break;
    }
    return sol;
}

int main() {
    auto start = std::chrono::high_resolution_clock::now();

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

    // Solve.
    using Node = std::tuple<double, int, int, int>;  // ub, item_i, v, c.
    std::priority_queue<Node, std::vector<Node>> pq;
    pq.push({1.0, 0, 0, C});

    int lb = 0;
    double cand_ub;
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

        cand_ub = v + frac_ks(items, item_i+1, c, N);
        if (cand_ub > lb) {
            pq.push({cand_ub, item_i+1, v, c});
        }

        if (c < items[item_i].w) { continue; }
        v += items[item_i].v;
        lb = std::max(lb, v);
        c -= items[item_i].w;
        cand_ub = v + frac_ks(items, item_i+1, c, N);
        if (cand_ub > lb) {
            pq.push({cand_ub, item_i+1, v, c});
        }
    }

    std::cout << lb << "\n1\n";

    auto stop = std::chrono::high_resolution_clock::now();
    double seconds = std::chrono::duration<double>(stop - start).count();
    std::cout << seconds << '\n';
}
