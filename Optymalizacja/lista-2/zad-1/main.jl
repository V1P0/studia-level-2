using JuMP, GLPK

# Dane przykładowe
n = 5 # Liczba miejsc
m = 3 # Liczba cech
T = [2, 3, 1, 5, 4] # Czas potrzebny na przeszukanie każdego miejsca
Q = [1 0 1 0 1; # Macierz qij
     0 1 1 0 0;
     1 0 0 1 0]

# Model
model = Model(GLPK.Optimizer)

# Zmienne decyzyjne
@variable(model, x[1:n], Bin)

# Funkcja celu
@objective(model, Min, sum(T[j] * x[j] for j in 1:n))

# Ograniczenia
for i in 1:m
    @constraint(model, sum(Q[i,j] * x[j] for j in 1:n) >= 1)
end

# Rozwiązanie
optimize!(model)

# Wyniki
println("Status: ", termination_status(model))
println("Minimalny czas: ", objective_value(model))
println("Miejsca do przeszukania: ", [j for j in 1:n if value(x[j]) > 0.5])