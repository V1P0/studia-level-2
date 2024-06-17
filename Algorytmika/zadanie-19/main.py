import math
import random

def vitter_sequence(length):
    if length <= 0:
        return None
    sequence = [0] * length
    sequence[0] = 1
    for i in range(1, length):
        prev = sequence[i-1]
        rng = random.random()
        sequence[i] = prev + math.ceil(rng * prev / (1 - rng))
    return sequence

def main():
    sequence = vitter_sequence(50)
    print(sequence)

if __name__ == "__main__":
    main()