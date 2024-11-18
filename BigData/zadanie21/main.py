import random
import hashlib
import heapq

def kmv_cardinality(stream, k):
    h = hashlib.md5()
    L1, L2 = [], []

    for element in stream:
        # Hashowanie elementu do wartości z przedziału (0,1]
        encoded_element = str(element).encode('utf-8')
        h.update(encoded_element)
        hash_value = int(h.hexdigest(), 16)
        u = hash_value / 2**127  # Normalizacja do przedziału [0,1)
        if u == 0:
            u = 1e-10  # Unikamy zera
        # Jeśli mamy mniej niż k wartości, dodajemy do kopca
        if(random.random() < 0.5):
            L = L1
        else:
            L = L2
        if len(L) < k/2:
            heapq.heappush(L, -u)  # Używamy kopca maksymalnego
        else:
            # Jeśli nowy hash jest mniejszy niż największy w kopcu, zastępujemy go
            if u < -L[0]:
                heapq.heappushpop(L, -u)

    if len(L1) + len(L2) < k:
        print("Za mało unikalnych elementów w strumieniu.")
        return len(L1) + len(L2)

    R = -max(L1[0], L2[0])  # k-ta najmniejsza wartość hash
    estimate = (k - 1) / R
    return estimate

def test_kmv():
    import matplotlib.pyplot as plt

    true_cardinalities = [1000, 5000, 10000, 20000, 50000, 100000]
    estimated_cardinalities = []

    k = 400

    for N in true_cardinalities:
        # Generowanie strumienia z N unikalnymi elementami
        stream = list(range(N))
        # Dodanie duplikatów do strumienia
        stream.extend(random.choices(stream, k=N))
        random.shuffle(stream)
        # Szacowanie liczności unikalnych elementów
        estimate = kmv_cardinality(stream, k)
        estimated_cardinalities.append(estimate)
        print(f"Prawdziwa liczność: {N}, Szacowana liczność: {estimate:.2f}")

    # Wykres porównawczy
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
