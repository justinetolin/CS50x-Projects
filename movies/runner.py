import subprocess
import os

output_file = "temp_output.txt"
results = []

for i in range(1, 14):
    sql_file = f"{i}.sql"

    # Run the SQL query and redirect output to the temp file
    with open(output_file, 'w') as out:
        subprocess.run(
            f"cat {sql_file} | sqlite3 movies.db",
            shell=True, stdout=out
        )

    # Count lines in output file
    with open(output_file, 'r') as f:
        line_count = sum(1 for _ in f)

    # Subtract 4 for headers and formatting lines
    results.append(max(0, line_count - 4))

# Clean up: delete the temporary output file
os.remove(output_file)

# Print the final result
print(results)
