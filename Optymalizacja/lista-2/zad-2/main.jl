using JuMP, GLPK

# Dane przykładowe
m = 3 # Liczba funkcji
n = 2 # Liczba podprogramów na funkcję
I = [1, 2] # Zbiór funkcji do obliczenia
M = 10 # Maksymalna ilość pamięci
t = [3 2; # Czas wykonania dla każdego podprogramu
     1 4;
     2 3]
r = [2 3; # Zużycie pamięci dla każdego podprogramu
     4 1;
     3 2]

# Model
model = Model(GLPK.Optimizer)

# Zmienne decyzyjne
@variable(model, x[1:m, 1:n], Bin)

# Funkcja celu
@objective(model, Min, sum(t[i,j] * x[i,j] for i in 1:m, j in 1:n))

# Ograniczenia
for i in I
    @constraint(model, sum(x[i,j] for j in 1:n) == 1)
end

@constraint(model, sum(r[i,j] * x[i,j] for i in 1:m, j in 1:n) <= M)

# Rozwiązanie
optimize!(model)

# Wyniki
println("Status: ", termination_status(model))
println("Minimalny czas wykonania: ", objective_value(model))
for i in 1:m
    for j in 1:n
        if value(x[i,j]) > 0.5
            println("Wybrany podprogram dla funkcji $i: P$i$j")
        end
    end
end