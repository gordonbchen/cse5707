#include <iostream>
#include <cstdlib>
#include <algorithm>
#include <chrono>
#include <unordered_map>

int T(int i, int c, int* vs, int* ws, int C) {
    static std::unordered_map<int, int> cache;
    int idx = i*(C+1) + c;
    if (auto it = cache.find(idx); it != cache.end()) {
        return it->second;
    }

    if ((i == 0) || (c == 0)) {
        cache[idx] = 0;
        return 0;
    }
    if (c < ws[i-1]) {
        return T(i-1, c, vs, ws, C);
    }
    int v = std::max(T(i-1, c, vs, ws, C), T(i-1, c-ws[i-1], vs, ws, C) + vs[i-1]);
    cache[idx] = v;
    return v;
}

int main() {
    auto start = std::chrono::high_resolution_clock::now();

    // Parse data.
    int N;
    std::cin >> N;

    int* vs = (int*)malloc(2 * sizeof(int) * N);
    int* ws = vs + N;

    int dummy, v, w;
    for (int i = 0; i < N; ++i) {
        std::cin >> dummy >> v >> w;
        vs[i] = v;
        ws[i] = w;
    }

    int C;
    std::cin >> C;

    // Solve.
    int sol = T(N, C, vs, ws, C);
    std::cout << sol << "\n1\n";

    auto stop = std::chrono::high_resolution_clock::now();
    double seconds = std::chrono::duration<double>(stop - start).count();
    std::cout << seconds << '\n';

    // Free mallocs.
    free(vs);
    vs = NULL;
    ws = NULL;
}
