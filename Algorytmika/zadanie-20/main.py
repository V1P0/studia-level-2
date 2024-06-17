import mmh3
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter

def hs(word, seed):
    return mmh3.hash(word, seed) % 21

def read_book(file_path):
    with open(file_path, 'r', encoding='utf8') as f:
        text = f.read()
    words = text.split()
    return set(words)

def generate_histogram(words, seed):
    hashes = [hs(word, seed) for word in words]
    counter = Counter(hashes)
    return counter

def plot_histogram(counter, seed):
    values = list(counter.values())
    keys = list(counter.keys())
    plt.bar(keys, values)
    plt.xlabel('Hash values')
    plt.ylabel('Frequency')
    plt.title(f'Histogram of hash values for seed {seed}')
    plt.savefig(f'histogram_seed_{seed}.png')
    plt.clf()

def count_collisions(word_a, word_b, num_seeds):
    collisions = 0
    for _ in range(num_seeds):
        seed = np.random.randint(0, 2**32)
        if hs(word_a, seed) == hs(word_b, seed):
            collisions += 1
    return collisions

def main():
    # Wczytanie książki z pliku ASCII
    file_path = 'zadanie-20/book.txt'
    words = read_book(file_path)
    
    # Generowanie i wyświetlanie histogramów dla różnych wartości ziarna
    for seed in [0, 1, 42, 100, 1234]:
        counter = generate_histogram(words, seed)
        plot_histogram(counter, seed)
    
    # Testowanie liczby kolizji dla dwóch słów
    word_a = 'its'  # Przykładowe słowo a
    word_b = 'bee'   # Przykładowe słowo b
    num_seeds = 1000
    collisions = count_collisions(word_a, word_b, num_seeds)
    print(f'Number of collisions for {num_seeds} seeds: {collisions}')

if __name__ == "__main__":
    main()