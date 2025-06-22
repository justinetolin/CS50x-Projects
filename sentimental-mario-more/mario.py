get_num = True
while get_num:
    h = input("Height: ")
    try:
        h = int(h)
        get_num = False
    except:
        pass
    finally:
        if h not in range(1, 8+1):
            get_num = True

sp = h - 1

for i in range(1, h+1):
    for j in range(1, sp+1):
        print(" ", end="")

    for j in range(1, i+1):
        print("#", end="")

    print("  ", end="")

    for j in range(1, i+1):
        print("#", end="")
    sp -= 1
    print()
