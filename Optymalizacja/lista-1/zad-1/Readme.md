## Zadanie 1

### Problem

Problem polega na rozwiązaniu następującego zadania programowania liniowego:

```
min    c^Tx
```
pod warunkiem
```
Ax = b,
x >= 0,
```

gdzie $a_{ij} = \frac{1}{i + j - 1}$, $c_i = b_i = \sum_{j=1}^{n} \frac{1}{i + j - 1}$ dla $i,j = 1,...,n$. Rozwiązaniem tego problemu jest $x_i = 1$ dla $i = 1,...,n$. Macierz $A$ występująca w tym teście, zwana macierzą Hilberta, powoduje złe uwarunkowanie problemu nawet dla niedużego $n$.

### Rozwiązanie

Rozwiązujemy ten problem, tworząc model GNU MathProg i uruchamiając go przy użyciu glpsol. Model wygląda następująco:

```plaintext
param n, integer, > 0;

set I := 1..n;

param a{i in I, j in I} := 1 / (i + j - 1);
param b{i in I} := sum{j in I} a[i,j];
param c{i in I} := b[i];

var x{i in I} >= 0;

minimize obj: sum{i in I} c[i] * x[i];

s.t. constraints{i in I}: sum{j in I} a[i,j] * x[j] = b[i];

solve;

param exact{i in I} := 1;
param computed{i in I} := x[i];
param error := sqrt(sum{i in I} (computed[i] - exact[i])^2) / sqrt(sum{i in I} exact[i]^2);

printf "n = %d\n", n;
printf {i in I} "x[%d] = %g\n", i, x[i];
printf "Objective = %g\n", obj;
printf "Relative error = %g\n", error;
```

### Wyniki

| $n$ | Błąd względny |
|-----|---------------|
| 1   | 0             |
| 2   | 1.05325e-15   |
| 3   | 3.67158e-15   |
| 4   | 3.27016e-13   |
| 5   | 3.3514e-12    |
| 6   | 6.83336e-11   |
| 7   | 1.67869e-08   |
| 8   | 0.514059      |
| 9   | 0.682911      |
| 10  | 0.990388      |

Patrząc na błędy, możemy wnioskować, że wynik będzie dokładny do 2 miejsc po przecinku aż do $n=7$.
