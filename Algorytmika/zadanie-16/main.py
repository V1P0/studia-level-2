import numpy as np
import matplotlib.pyplot as plt

# Parametry
m = 106  # liczba kul
n = 103  # liczba kubełków

# Proces losowy
def random_allocation(m, n):
    buckets = np.zeros(n)
    for _ in range(m):
        bucket = np.random.randint(0, n)
        buckets[bucket] += 1
    return buckets

# Proces dwóch wyborów
def two_choices_allocation(m, n):
    buckets = np.zeros(n)
    for _ in range(m):
        bucket1, bucket2 = np.random.randint(0, n, 2)
        if buckets[bucket1] <= buckets[bucket2]:
            buckets[bucket1] += 1
        else:
            buckets[bucket2] += 1
    return buckets

# Symulacja
random_buckets = random_allocation(m, n)
two_choices_buckets = two_choices_allocation(m, n)

# Rysowanie histogramów
fig, axs = plt.subplots(1, 2, figsize=(14, 5))

axs[0].hist(random_buckets, bins=range(int(random_buckets.max())+2), edgecolor='black')
axs[0].set_title('Random Allocation')
axs[0].set_xlabel('Number of balls in bucket')
axs[0].set_ylabel('Frequency')

axs[1].hist(two_choices_buckets, bins=range(int(two_choices_buckets.max())+2), edgecolor='black')
axs[1].set_title('Two Choices Allocation')
axs[1].set_xlabel('Number of balls in bucket')
axs[1].set_ylabel('Frequency')

plt.tight_layout()
plt.savefig("buckets.png")
