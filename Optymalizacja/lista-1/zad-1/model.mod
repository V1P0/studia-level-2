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
end;
