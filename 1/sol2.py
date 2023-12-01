import re

def get_digits(line):
    digits = ''

    i = 0
    while i < len(line):
        character = line[i:i+1]
        if character.isdigit():
            digits += character
            i += 1
            continue

        chunk = line[i:i+3]
        if chunk == 'one':
            digits += '1'
        elif chunk == 'two':
            digits += '2'
        elif chunk == 'six':
            digits += '6'

        chunk = line[i:i+4]
        if chunk == 'four':
            digits += '4'
        elif chunk == 'five':
            digits += '5'
        elif chunk == 'nine':
            digits += '9'

        chunk = line[i:i+5]
        if chunk == 'seven':
            digits += '7'
        elif chunk == 'eight':
            digits += '8'
        elif chunk == 'three':
            digits += '3'

        i += 1

    return digits

numbers = []

with open('input1.txt') as file:
    for line in file:
        line = get_digits(line)

        first_number = None
        last_number = None
        for character in line:
            if character.isdigit():
                if first_number is None: first_number = character
                last_number = character
        numbers.append(int(str(first_number) + str(last_number)))

total = 0
for number in numbers:
    total += number

print(total)

