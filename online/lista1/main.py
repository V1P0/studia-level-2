import random
import math
import matplotlib.pyplot as plt


# ----- FUNKCJE GENERUJĄCE LOSOWE WARTOŚCI -----

def harmonic_number(n):
    """Oblicza n-tą liczbę harmoniczną: H(n) = 1 + 1/2 + ... + 1/n"""
    return sum(1.0 / i for i in range(1, n + 1))


H_100 = harmonic_number(100)

def two_harmonic_number(n):
    """Oblicza n-tą liczbę dwuharmoniczną"""
    return sum(1.0 / i**2 for i in range(1, n + 1))

H2_100 = two_harmonic_number(100)

def rand_uniform():
    """Losuje element z {1,...,100} z rozkładem jednorodnym."""
    return random.randint(1, 100)


def rand_harmonic():
    """
    Losuje element z {1,...,100} według rozkładu harmonicznego:
    P(X = i) = 1 / (i * H_100)
    """
    r = random.random()
    cumulative = 0.0
    for i in range(1, 101):
        p_i = 1.0 / (i * H_100)
        cumulative += p_i
        if r <= cumulative:
            return i
    return 100


def rand_2_harmonic():
    """
    Losuje element z {1,...,100} według rozkładu harmonicznego:
    P(X = i) = 1 / (i^2 * H2_100)
    """
    r = random.random()
    cumulative = 0.0
    for i in range(1, 101):
        p_i = 1.0 / (i**2 * H2_100)
        cumulative += p_i
        if r <= cumulative:
            return i
    return 100

def rand_geometric():
    """
    Losuje element z {1,...,100} z prawdopodobieństwem:
    P(X = i) = 1 / 2^i dla i < 100 oraz P(X=100)=1/2^99
    """
    r = random.random()
    cumulative = 0.0
    for i in range(1, 100):
        p_i = 1.0 / (2**i)
        cumulative += p_i
        if r <= cumulative:
            return i
    return 100


# ----- IMPLEMENTACJE LIST -----

class StaticList:
    """
    Lista statyczna (bez samoorganizacji).
    Przeszukiwanie odbywa się sekwencyjnie. Jeśli element nie zostanie znaleziony,
    zostaje dodany na końcu listy, ale nie zmieniamy kolejności.
    """

    def __init__(self):
        self.data = []

    def access(self, x):
        cost = 0
        found_index = -1
        for i, val in enumerate(self.data):
            cost += 1
            if val == x:
                found_index = i
                break
        if found_index == -1:
            self.data.append(x)
            cost += 1  # koszt "sprawdzenia poza listą"
        return cost


class SelfOrganizingListMTF:
    """Lista samoporządkująca z heurystyką Move-To-Front."""

    def __init__(self):
        self.data = []

    def access(self, x):
        cost = 0
        found_index = -1
        for i, val in enumerate(self.data):
            cost += 1
            if val == x:
                found_index = i
                break
        if found_index == -1:
            self.data.append(x)
            cost += 1
            found_index = len(self.data) - 1
        # Przenosimy element na początek
        elem = self.data.pop(found_index)
        self.data.insert(0, elem)
        return cost


class SelfOrganizingListTranspose:
    """Lista samoporządkująca z heurystyką Transpose (zamiana z poprzednikiem)."""

    def __init__(self):
        self.data = []

    def access(self, x):
        cost = 0
        found_index = -1
        for i, val in enumerate(self.data):
            cost += 1
            if val == x:
                found_index = i
                break
        if found_index == -1:
            self.data.append(x)
            cost += 1
            found_index = len(self.data) - 1
        # Jeśli element nie jest na początku, zamieniamy go z poprzednikiem
        if found_index > 0:
            self.data[found_index], self.data[found_index - 1] = \
                self.data[found_index - 1], self.data[found_index]
        return cost


class SelfOrganizingListCount:
    """
    Lista samoporządkująca wg liczników:
    Po każdym dostępie zwiększamy licznik danego elementu i przesuwamy go w górę listy,
    tak aby lista była uporządkowana według malejącej wartości licznika.
    """

    def __init__(self):
        self.data = []  # elementy jako pary (wartość, licznik)

    def access(self, x):
        cost = 0
        found_index = -1
        for i, (val, cnt) in enumerate(self.data):
            cost += 1
            if val == x:
                found_index = i
                break
        if found_index == -1:
            self.data.append((x, 1))
            cost += 1
            found_index = len(self.data) - 1
        else:
            val, cnt = self.data[found_index]
            cnt += 1
            self.data[found_index] = (val, cnt)
        # Przesuwamy element do odpowiedniej pozycji (uporządkowanie malejąco według licznika)
        current_val, current_cnt = self.data[found_index]
        i = found_index
        while i > 0 and self.data[i - 1][1] < current_cnt:
            self.data[i] = self.data[i - 1]
            i -= 1
        self.data[i] = (current_val, current_cnt)
        return cost


# ----- FUNKCJA POMIAROWA -----

def measure_average_cost(n, distribution_func, list_class):
    """
    Wykonuje n operacji Access(i) dla danego rozkładu (distribution_func)
    na liście implementującej daną heurystykę (list_class). Zwraca średni koszt.
    """
    sol = list_class()
    total_cost = 0
    for _ in range(n):
        x = distribution_func()
        total_cost += sol.access(x)
    return total_cost / n


# ----- KOD TESTUJĄCY I GENERUJĄCY WYKRESY -----

if __name__ == "__main__":
    random.seed(0)  # Dla powtarzalności wyników

    # Liczby operacji testowych
    test_ns = [100, 500, 1000, 5_000, 10_000, 50_000, 100_000]

    # Rozkłady do testowania
    distributions = {
        "Uniform": rand_uniform,
        "Harmonic": rand_harmonic,
        "Two-Harmonic": rand_2_harmonic,
        "Geometric": rand_geometric
    }

    # Heurystyki do testowania (dodajemy także listę statyczną)
    heuristics = {
        "Static": StaticList,
        "MoveToFront": SelfOrganizingListMTF,
        "Transpose": SelfOrganizingListTranspose,
        "Count": SelfOrganizingListCount
    }

    # Struktura przechowująca wyniki:
    # results[rozkład][heurystyka] = lista średnich kosztów dla kolejnych n
    results = {}
    for dist_name, dist_func in distributions.items():
        results[dist_name] = {}
        print(f"=== ROZKŁAD: {dist_name} ===")
        for heuristic_name, heuristic_class in heuristics.items():
            avg_costs = []
            for n in test_ns:
                avg_cost = measure_average_cost(n, dist_func, heuristic_class)
                avg_costs.append(avg_cost)
            results[dist_name][heuristic_name] = avg_costs
            print(f"  {heuristic_name}: {avg_costs}")
        print()

    # ----- GENEROWANIE WYKRESÓW -----

    # Tworzymy wykresy - jeden wykres dla każdego rozkładu
    num_distributions = len(distributions)
    fig, axs = plt.subplots(num_distributions, 1, figsize=(8, 4 * num_distributions))

    # Jeśli tylko jeden wykres, zamieniamy axs na listę dla jednolitego przetwarzania
    if num_distributions == 1:
        axs = [axs]

    for ax, (dist_name, heuristics_results) in zip(axs, results.items()):
        for heuristic_name, avg_costs in heuristics_results.items():
            ax.plot(test_ns, avg_costs, marker='o', label=heuristic_name)
        ax.set_title(f"Rozkład: {dist_name}")
        ax.set_xlabel("Liczba operacji (n)")
        ax.set_ylabel("Średni koszt")
        ax.set_xscale('log')
        ax.legend()
        ax.grid(True)
    plt.tight_layout()
    plt.show()
