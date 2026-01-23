#include <iostream>
#include <cstdlib>
#include <algorithm>
#include <chrono>

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

    // DP.
    int* T = (int*)malloc(sizeof(int) * ((N+1) * (C+1)));

    int idx, prev;
    for (int i = 1; i < N + 1; ++i) {
        for (int c = 1; c < C + 1; ++c) {
            idx = i*(C+1) + c;
            prev = idx - (C+1);
            if (c < ws[i-1]) {
                T[idx] = T[prev];
            }
            else {
                T[idx] = std::max(T[prev], T[prev - ws[i-1]] + vs[i-1]);
            }
        }
    }
    std::cout << T[(N+1)*(C+1) - 1] << "\n1\n";

    auto stop = std::chrono::high_resolution_clock::now();
    double seconds = std::chrono::duration<double>(stop - start).count();
    std::cout << seconds << '\n';

    // Free mallocs.
    free(vs);
    vs = NULL;
    ws = NULL;

    free(T);
    T = NULL;
}
