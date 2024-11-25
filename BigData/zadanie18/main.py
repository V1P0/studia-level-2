import random
import hashlib
import heapq

def kmv_cardinality(stream, k):
    X = [1 for _ in range(k)]

    for element in stream:
        u = int(hashlib.md5(str(element).encode()).hexdigest(), 16) / (2**128-1)
        if u == 0:
            u = 1e-10
        if u < X[k-1] and u not in X:
            X.append(u)
            X.sort()
            X.pop(-1)
    
    L = X.count(1)
    if L > 0:
        return k - L
    else:
        return (k-1)/X[k-1]


def test_kmv():
    import matplotlib.pyplot as plt

    true_cardinalities = [1000, 5000, 10000, 20000, 50000, 100000]
    estimated_cardinalities = []

    k = 400

    for N in true_cardinalities:
        stream = list(range(N))
        # Dodanie duplikatów do strumienia
        stream.extend(random.choices(stream, k=5*N))
        random.shuffle(stream)
        estimate = kmv_cardinality(stream, k)
        estimated_cardinalities.append(estimate)
        print(f"Prawdziwa liczność: {N}, Szacowana liczność: {estimate:.2f}")

    plt.figure(figsize=(10, 6))
    plt.plot(true_cardinalities, estimated_cardinalities, marker='o', label='Szacowana liczność')
    plt.plot(true_cardinalities, true_cardinalities, linestyle='--', color='red', label='Prawdziwa liczność')
    plt.xlabel('Prawdziwa liczność unikalnych elementów')
    plt.ylabel('Szacowana liczność unikalnych elementów')
    plt.title('Porównanie prawdziwej i szacowanej liczności dla k = 400')
    plt.legend()
    plt.grid(True)
    plt.savefig('kmv_cardinality.png')

if __name__ == "__main__":
    test_kmv()
