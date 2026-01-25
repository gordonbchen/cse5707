import os
import sys
import subprocess
import glob

def main():
    # python ks_bench.py bb_bs.cpp [num_runs]
    if len(sys.argv) < 2:
        print("use python ks_bench.py <source.cpp> [runs=3]")
        sys.exit(1)

    cpp_file = sys.argv[1]
    num_runs = int(sys.argv[2]) if len(sys.argv) > 2 else 3
    exe_name = "./" + cpp_file.split('.')[0] + ".out"
    subprocess.run(["g++", "-O3", "-std=c++17", cpp_file, "-o", exe_name], check=True)
    files = glob.glob("data/*.txt")
    print(f"{'DATASET':<25} {'SOLUTION':<15} {'MEDIAN TIME OVER'} {num_runs} {'RUNS (ms)'}")

    for f_path in files:
        d_name = os.path.basename(f_path)
        run_times = []
        solution = "?"
        failed = False

        for i in range(num_runs):
            try:
                with open(f_path, 'r') as infile:
                    # 5 seconds timeout
                    res = subprocess.run(
                        [exe_name],
                        stdin=infile,
                        capture_output=True,
                        text=True,
                        timeout=5
                    )

                    lines = res.stdout.strip().split('\n')
                    solution = lines[0].strip()
                    run_time = float(lines[-1].strip())
                    run_times.append(run_time)

            except subprocess.TimeoutExpired:
                print(f"{d_name:<25} {'SKIPPED':<15} >5s")
                failed = True
                break
            except Exception as e:
                print(f"{d_name:<25} error: {e}")
                failed = True
                break

        if not failed:
            avg_time_ms = 1000 * run_times[num_runs // 2]
            print(f"{d_name:<25} {solution:<15} {avg_time_ms:.5f} ms")

    if os.path.exists(exe_name):
        os.remove(exe_name)

if __name__ == "__main__":
    main()
