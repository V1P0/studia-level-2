# Mateusz Jończak
set Materials := 1..3;
set FirstClassProducts := {'A', 'B'};
set SecondClassProducts := {'C', 'D'};
set Products := FirstClassProducts union SecondClassProducts;

param minBuy{Materials} >= 0;
param maxBuy{Materials} >= 0;

param value{Products} >= 0;
param price{Materials} >= 0;
param wasteCost{Materials, FirstClassProducts} >= 0;
param wasteRatio{Materials, FirstClassProducts} >= 0, <= 1;

var materialUsed{Materials, Products} >= 0;
var wasteProduced{Materials, FirstClassProducts} >= 0;
var wasteUsed {Materials, SecondClassProducts} >= 0;
var wasteDisposed {Materials, FirstClassProducts} >= 0;

s.t. MaterialMin {m in Materials}:
  sum{p in Products} materialUsed[m,p] >= minBuy[m];
s.t. MaterialMax {m in Materials}:
  sum{ p in Products} materialUsed[m,p] <= maxBuy[m];

s.t. BlueprintA1:
  materialUsed[1,'A'] >= 0.2 * sum{m in Materials} materialUsed[m,'A'];
s.t. BlueprintA2:
  materialUsed[2,'A'] >= 0.4 * sum{m in Materials} materialUsed[m,'A'];
s.t. BlueprintA3:
  materialUsed[3,'A'] <= 0.1 * sum{m in Materials} materialUsed[m,'A'];

s.t. BlueprintB1:
  materialUsed[1,'B'] >= 0.1 * sum{m in Materials} materialUsed[m,'B'];
s.t. BlueprintB2:
  materialUsed[3,'B'] <= 0.3 * sum{m in Materials} materialUsed[m,'B'];

s.t. BlueprintC1:
  materialUsed[1,'C'] = 0.2 * ((sum{m in Materials} wasteUsed[m,'C']) + materialUsed[1,'C']);
s.t. BlueprintC2:
  materialUsed[2,'C'] = 0;
s.t. BlueprintC3:
  materialUsed[3,'C'] = 0;

s.t. BlueprintD1:
  materialUsed[2,'D'] = 0.3 * ((sum{m in Materials} wasteUsed[m,'D']) + materialUsed[2,'D']);
s.t. BlueprintD2:
  materialUsed[1,'D'] = 0;
s.t. BlueprintD3:
  materialUsed[3,'D'] = 0;

s.t. WasteUsedC{m in Materials}:
  wasteUsed[m,'C'] + wasteDisposed[m, 'A'] = wasteProduced[m,'A'];
s.t. WasteUsedD{m in Materials}:
  wasteUsed[m,'D'] + wasteDisposed[m, 'B'] = wasteProduced[m,'B'];

s.t. Waste{m in Materials, p in FirstClassProducts}:
  wasteProduced[m,p] = wasteRatio[m,p] * materialUsed[m,p];

maximize TotalValue:
  sum{p in FirstClassProducts} (value[p] * sum{m in Materials} (materialUsed[m,p] * (1 - wasteRatio[m,p]))) +
  sum{p in SecondClassProducts} (value[p] * (sum{m in Materials} (materialUsed[m,p] + wasteUsed[m,p]))) -
  sum{m in Materials, p in FirstClassProducts} (wasteCost[m,p] * wasteDisposed[m,p]) -
  sum{m in Materials, p in Products} (price[m] * materialUsed[m,p]);

solve;

# Display results in an organized format
printf "\n--- Production and Material Usage Plan ---\n";
for {p in Products} {
  printf "Product %s - Produced: %g kg\n", p, sum{m in Materials} materialUsed[m,p];
  for {m in Materials} {
    printf "\tMaterial %d - Used: %g kg\n", m, materialUsed[m,p];
  }
}

printf "\n--- Waste Utilization ---\n";
for {m in Materials, p in FirstClassProducts} {
  printf "Material %d - Waste Produced from %s: %g kg\n", m, p, wasteProduced[m,p];
  printf "\tWaste Used for Second-Class Products: %g kg\n", sum{p2 in SecondClassProducts} wasteUsed[m,p2];
  printf "\tWaste Disposed: %g kg\n", wasteDisposed[m,p];
}

printf "\n--- Financial Summary ---\n";
printf "Total Revenue from Products: $%g\n", sum{p in Products} value[p] * sum{m in Materials} materialUsed[m,p];
printf "Total Material Cost: $%g\n", sum{m in Materials, p in Products} price[m] * materialUsed[m,p];
printf "Total Waste Disposal Cost: $%g\n", sum{m in Materials, p in FirstClassProducts} wasteCost[m,p] * wasteDisposed[m,p];
printf "Total Profit: $%g\n", TotalValue;

end;
