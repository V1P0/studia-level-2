Aby narysować wykres przedstawiający objętości \( V_n(r) \) kul o promieniu \( r \) w przestrzeni \( \mathbb{R}^n \) dla \( r = 0.5, 1, 2 \) oraz \( n = 1, \ldots, 50 \), możemy skorzystać z poniższego wzoru na objętość n-wymiarowej kuli:

\[
V_n(r) = \frac{\pi^{n/2} \, r^n}{\Gamma\left(\frac{n}{2} + 1\right)},
\]

gdzie \( \Gamma \) to funkcja gamma.

Poniżej przedstawiam kod w języku Python wykorzystujący biblioteki `numpy`, `matplotlib` oraz `scipy.special` do obliczenia i narysowania wykresu:

```python
import numpy as np
import matplotlib.pyplot as plt
from scipy.special import gamma

def sphere_volume(n, r):
    return (np.pi ** (n / 2) * r ** n) / gamma(n / 2 + 1)

# Zakres wymiarów n
n_values = np.arange(1, 51)  # n od 1 do 50

# Promienie kul
radii = [0.5, 1, 2]

# Tworzenie wykresu
plt.figure(figsize=(12, 8))

for r in radii:
    volumes = sphere_volume(n_values, r)
    plt.plot(n_values, volumes, label=f'Promień r = {r}')

plt.title('Objętość n-wymiarowej kuli o promieniu r')
plt.xlabel('Wymiar przestrzeni n')
plt.ylabel('Objętość Vₙ(r)')
plt.legend()
plt.grid(True)
plt.show()
```

**Opis wykresu:**

- **Oś X (pozioma):** Wymiar przestrzeni \( n \) (od 1 do 50).
- **Oś Y (pionowa):** Objętość \( V_n(r) \) kuli o promieniu \( r \) w \( \mathbb{R}^n \).
- **Krzywe na wykresie:** Każda krzywa odpowiada innej wartości promienia \( r \) (0.5, 1, 2).

**Interpretacja:**

- Objętość kuli w n-wymiarowej przestrzeni początkowo rośnie wraz ze wzrostem \( n \), osiąga maksimum, a następnie maleje do zera.
- Dla większych promieni \( r \) maksymalna objętość występuje przy wyższym \( n \).
- Wysokość i położenie maksimum na wykresie zależy od wartości \( r \).

**Dodatkowe informacje:**

- Funkcja gamma \( \Gamma \) jest uogólnieniem silni dla liczb rzeczywistych i zespolonych.
- Wykres pokazuje ciekawe własności geometryczne wyższych wymiarów, gdzie intuicja z niskowymiarowych przestrzeni może być myląca.

**Aby uruchomić kod:**

1. Upewnij się, że masz zainstalowane biblioteki `numpy`, `matplotlib` i `scipy`.
2. Skopiuj kod do pliku z rozszerzeniem `.py`.
3. Uruchom skrypt w środowisku Python.

**Przykładowy wynik wykresu:**

(Ze względu na ograniczenia tekstowe nie mogę bezpośrednio załączyć wykresu, ale po uruchomieniu powyższego kodu zostanie wygenerowany opisany wykres.)

**Wnioski:**

- W miarę wzrostu wymiaru przestrzeni, objętość kuli o stałym promieniu staje się coraz mniejsza po przekroczeniu pewnego wymiaru.
- To zjawisko jest istotne w analizie danych wysokowymiarowych i teorii informacji.
