Rozważmy następujący BARDZO KIEPSKI algorytm sużący wygenerowania ciągu długości n składającego się z samych zer:
for i = 1 to n {
X[i] = randomBit
}
return X
Prawdopodobieństwo sukcesu tego algorytmu wynosi 1/2n , co jest raczej kiepskim wynikiem. Przeprowadź
derandomizację tego algorytmu metodą prawdopodobieństw warunkowych, czyli rozważ ciąg funkcji
c(x1, . . . , xk) = Pr[Sukces|X1 = x1, . . . , Xk = xk] .