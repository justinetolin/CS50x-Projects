import re
from math import floor

input = input("Number: ")
# input = "378282246310005"
card = int(re.findall(r"\d+", input)[0])

# number list that will be multiplied
firsts_sum = 0

# sum of the second lit of numbers only for last addition
seconds = []

# position and length tracker
pos = 0

# get last digit and append to the list or sum
OGcard = card
while card > 0:
    digit = card % 10

    if pos % 2 == 0:
        firsts_sum += digit
    else:
        seconds.append(digit)

    card = floor(card / 10)
    pos += 1

card = OGcard

# multiply the firsts list with 2 ensuring that any 2dgt is separated
seconds_sum = 0
for i in range(len(seconds)):
    x = seconds[i]
    x *= 2
    if x > 9:
        last_digit = x % 10
        last_digit += floor(x / 10)
        seconds_sum += last_digit
    else:
        seconds_sum += x

checksum = seconds_sum + firsts_sum
cs_last = checksum % 10

# retrieve card service param digits for validation
first_one = card
first_two = card
while first_one >= 10:
    first_one /= 10

while first_two >= 100:
    first_two /= 10

# floor the nums to remove decimal
first_one = floor(first_one)
first_two = floor(first_two)

# identify card service
clen = pos

if cs_last == 0:
    if clen == 15 and first_two in [34, 37]:
        print("AMEX")
    elif clen == 16 and first_two in range(51, 55+1):
        print("MASTERCARD")
    elif clen in [13, 16] and first_one == 4:
        print("VISA")
    else:
        print("INVALID")
else:
    print("INVALID")
