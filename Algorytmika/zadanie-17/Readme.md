Rozważamy następujący algorytm przybliżonego zliczania liczby stacji w środowisku bezprzewodowym:
1. każda stacja v ∈ V generuje niezależnie liczbą losową ζv ∈ [0, 1];
2. zbieramy (nie ważne jak) listę L = {ζv : v ∈ V };
3. sortujemy listę L i otrzymujemy ciąg x1 ¬ x2 ¬ . . . ¬ xn;
4. jeśli n ¬ 400 to zwracamy n
5. jeśli n > 400 to zwracamy liczbę 399/x400
Zbadaj eksperymentalnie dokładność tego algorytmu dla liczby stacji n ¬ 10000