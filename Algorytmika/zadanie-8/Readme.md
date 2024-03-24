Jaka jest wartość oczekiwana E [lcs(x, y)], gdzie x, y są losowymi {0, 1} - ciągami długości 5 (rozważamy rozkład jednostajny)?

Rozważając wszystkie możliwe ciągi o długości 5 dla {0,1}, mamy 2^5 = 32 unikalne ciągi. Dla każdej pary ciągów (x, y), możemy obliczyć ich najdłuższy wspólny podciąg (LCS). Następnie obliczamy wartość oczekiwaną (średnią) dla wszystkich tych wartości LCS.

`Wartość oczekiwana E [lcs(x, y)] wynosi: 3.24609375`