
numbers = []

with open('input1.txt') as file:
    for line in file:
        first_number = None
        last_number = None
        for character in line:
            if character.isdigit():
                if first_number is None: first_number = character
                if first_number is not None: last_number = character
        numbers.append(int(str(first_number) + str(last_number)))

total = 0
for number in numbers:
    total += number

print(total)
