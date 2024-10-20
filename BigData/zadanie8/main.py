import numpy as np
from scipy.spatial.distance import pdist

def compute_distance_ratio(n, k=50, runs=100):
    ratios = []
    for _ in range(runs):
        # Generujemy k losowych punktów w [0, 1]^n
        X = np.random.uniform(0, 1, (k, n))
        
        # Obliczamy macierz odległości między punktami
        distances = pdist(X)
        
        # Wyznaczamy d_max i d_min (pomijając odległość 0)
        d_max = distances.max()
        d_min = distances[distances > 0].min()
        
        # Obliczamy stosunek i dodajemy do listy
        ratios.append(d_max / d_min)
    # Zwracamy średnią i odchylenie standardowe
    return np.mean(ratios), np.std(ratios)


import matplotlib.pyplot as plt

n_values = [1, 10, 100, 1000, 10000]
mean_ratios = [compute_distance_ratio(n)[0] for n in n_values]

plt.figure(figsize=(10, 6))
plt.plot(n_values, mean_ratios, marker='o')
plt.xscale('log')
plt.xlabel('Wymiar n (skalowanie logarytmiczne)')
plt.ylabel('Średni stosunek $d_{\mathrm{max}} / d_{\mathrm{min}}$')
plt.yscale('log')
plt.title('Zależność między wymiarem a stosunkiem odległości')
plt.grid(True)
plt.savefig('distance_ratio.png')