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

    int idx, v, w;
    for (int i = 0; i < N; ++i) {
        std::cin >> idx >> v >> w;
        vs[i] = v;
        ws[i] = w;
    }

    int C;
    std::cin >> C;

    // DP.
    int* T = (int*)malloc(sizeof(int) * ((N+1) * (C+1)));

    for (int i = 1; i < N + 1; ++i) {
        for (int c = 1; c < C + 1; ++c) {
            if (c < ws[i-1]) {
                T[i*(C+1) + c] = T[(i-1)*(C+1) + c];
            }
            else {
                T[i*(C+1) + c] = std::max(T[(i-1)*(C+1) + c], T[(i-1)*(C+1) + c - ws[i-1]] + vs[i-1]);
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
