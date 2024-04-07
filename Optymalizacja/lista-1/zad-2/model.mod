param n := 13; # Przyjmujemy 12 miast na potrzeby przykładu

set CITIES := 1..n; # Zestaw miast numerowanych od 1 do n
set TYPES := {'Standard', 'VIP'}; # Typy camperów

param demand {CITIES, TYPES};
param supply {CITIES, TYPES};
param distance {CITIES, CITIES};



var x {CITIES, CITIES, TYPES} >= 0; # Zmienne decyzyjne reprezentujące liczbę camperów

# Define a parameter to account for the type cost difference
param type_cost{t in TYPES}, > 0; # Define the parameter with a set of indices


minimize Cost:
    sum {i in CITIES, j in CITIES, t in TYPES} distance[i,j] * x[i,j,t] * type_cost[t];


# Ograniczenia zapotrzebowania
s.t. DemandVIP {k in CITIES}:
    supply[k, 'VIP'] + sum {i in CITIES} x[i,k,'VIP'] - sum {j in CITIES} x[k,j,'VIP'] >= demand[k, 'VIP'];

s.t. DemandStandard {k in CITIES}:
    (sum {i in CITIES} x[i,k,'Standard'] - sum {j in CITIES} x[k,j,'Standard'] - demand[k, 'Standard'] + supply[k, 'Standard']) + 
    (sum {i in CITIES} x[i,k,'VIP'] - sum {j in CITIES} x[k,j,'VIP']) - demand[k, 'VIP'] + supply[k, 'VIP'] >= 0;

# Ograniczenia dostawy
s.t. SupplyUse {k in CITIES, t in TYPES}:
    sum {j in CITIES} x[k,j,t] <= supply[k,t];

solve;

printf "Plan przemieszczenia camperów:\n";
printf{ (i, j, t) in CITIES cross CITIES cross TYPES : x[i,j,t] > 0 } 
"Przesuń %d camperów typu %s z miasta %d do miasta %d\n", x[i,j,t], t, i, j;


printf "Całkowity koszt: %g\n", Cost;



end;
