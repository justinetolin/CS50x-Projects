import subprocess
import csv

sort_programs = ["./sort1", "./sort2", "./sort3"]
input_files = [
    "random5000.txt", "random10000.txt", "random50000.txt",
    "reversed5000.txt", "reversed10000.txt", "reversed50000.txt",
    "sorted5000.txt", "sorted10000.txt", "sorted50000.txt"
]

results = {}

for program in sort_programs:
    program_results = {}
    for input_file in input_files:
        print(f"Running {program} on {input_file}...")
        try:
            # Use shell 'time' built-in via bash
            cmd = f'time {program} {input_file}'
            result = subprocess.run(
                ["bash", "-c", cmd],
                stderr=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                text=True
            )

            time_seconds = None
            for line in result.stderr.splitlines():
                if line.startswith("real"):
                    try:
                        # Format: real 0m0.123s
                        parts = line.strip().split()
                        if len(parts) == 2 and 'm' in parts[1] and 's' in parts[1]:
                            mins, secs = parts[1].split('m')
                            secs = secs.rstrip('s')
                            time_seconds = float(mins) * 60 + float(secs)
                        elif len(parts) == 2:
                            time_seconds = float(parts[1])  # fallback
                        break
                    except ValueError:
                        pass

            if time_seconds is None:
                print(
                    f"[!] Warning: Could not parse time for {program} on {input_file}")
                print("    stderr was:\n" + result.stderr)

            program_results[input_file] = time_seconds if time_seconds is not None else "N/A"

        except Exception as e:
            print(f"Error running {program} on {input_file}: {e}")
    results[program] = program_results

# Print table
print("\n=== Benchmark Results (in seconds) ===")
header = ["Program"] + input_files
print("{:<10}".format("Program"), end="")
for fname in input_files:
    print("{:>20}".format(fname), end="")
print()

for program, timings in results.items():
    print("{:<10}".format(program), end="")
    for file in input_files:
        time_val = timings.get(file, "N/A")
        print("{:>20}".format(time_val), end="")
    print()

# Save to CSV
csv_filename = "sort_benchmark_results.csv"
with open(csv_filename, mode="w", newline="") as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(header)
    for program, timings in results.items():
        row = [program]
        for file in input_files:
            row.append(timings.get(file, "N/A"))
        writer.writerow(row)

print(f"\n[✔] Results saved to {csv_filename}")
