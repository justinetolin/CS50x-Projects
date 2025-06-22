import csv
import sys


def main():

    # TODO: Check for command-line usage
    if len(sys.argv) != 3:
        print( "Missing command-tine argument")
        sys.exit(1)
    db_path = sys.argv[1]
    sq_path = sys.argv[2]

    # TODO: Read database file into a variable
    database = []
    with open(db_path) as file:
        reader = csv.DictReader(file)

        for row in reader:
            database.append(row)

    # TODO: Read DNA sequence file into a variable
    sequence = ''
    with open(sq_path) as file:
        sequence = file.read()

    # Extract strs and remove 'name'
    keys = list(database[0].keys())
    keys.pop(0)
    # print(keys)

    # Extract names
    names = []
    for row in database:
        names.append(row["name"])
    # print(names)


    # TODO: Find longest match of each STR in DNA sequence
    # Store the matches
    str_counts = []
    for i in range(len(keys)):
        value = longest_match(sequence, keys[i])
        str_counts.append(value)

    # TODO: Check database for matching profiles
    # Identify the matches
    matched = ""
    for row in database:
        # make the values into a list
        row_ls = list(row.values())

        # extract the name while removing it
        name = row_ls.pop(0)

        # turn the str to int
        for i in range(len(row_ls)):
            row_ls[i] = int(row_ls[i])

        # compare 2 lists
        if row_ls == str_counts:
            matched = name

    if len(matched):
        print(matched)
    else:
        print("No match")

    return


def longest_match(sequence, subsequence):
    """Returns length of longest run of subsequence in sequence."""

    # Initialize variables
    longest_run = 0
    subsequence_length = len(subsequence)
    sequence_length = len(sequence)

    # Check each character in sequence for most consecutive runs of subsequence
    for i in range(sequence_length):

        # Initialize count of consecutive runs
        count = 0

        # Check for a subsequence match in a "substring" (a subset of characters) within sequence
        # If a match, move substring to next potential match in sequence
        # Continue moving substring and checking for matches until out of consecutive matches
        while True:

            # Adjust substring start and end
            start = i + count * subsequence_length
            end = start + subsequence_length

            # If there is a match in the substring
            if sequence[start:end] == subsequence:
                count += 1

            # If there is no match in the substring
            else:
                break

        # Update most consecutive matches found
        longest_run = max(longest_run, count)

    # After checking for runs at each character in seqeuence, return longest run found
    return longest_run


main()
