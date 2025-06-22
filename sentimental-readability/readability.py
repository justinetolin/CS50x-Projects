import re

input = input("Text: ")
words = len(re.split(r"\s", input))
# print(words)

letters = len(re.findall(r"[a-zA-Z]", input))
# print(letters)

sentences = len(re.findall("[.?!]", input))
# print(sentences)

L = (letters / words) * 100
S = (sentences / words) * 100

index = 0.0588 * L - 0.296 * S - 15.8
index = round(index)
# print(index)

if index < 1:
    print("Before Grade 1")
elif index in range(2, 16):
    print(f'Grade: {index}')
elif index >= 16:
    print("Grade 16+")
