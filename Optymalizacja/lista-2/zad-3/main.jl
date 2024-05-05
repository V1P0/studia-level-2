using JuMP, GLPK, Plots

# Sample data
n = 5  # Number of tasks
p = 3 # number of processors
a = [
    [4, 7, 6, 8, 10]  # Processing times on P1
    [3, 1, 5, 7, 9]   # Processing times on P2
    [7, 5, 9, 11, 13] # Processing times on P3
    ]  

M = sum([sum(i) for i in a])

# Initialize the model with GLPK solver
model = Model(GLPK.Optimizer)

# Decision variables
@variable(model, x[1:n, 1:n], Bin)  # Task sequencing variables
@variable(model, start[1:n, 1:p] >= 0)  # Start times
@variable(model, Cmax)

# Objective: Minimize the makespan
@objective(model, Min, Cmax)

for i in 1:n
    @constraint(model, sum(x[i, j] for j in 1:n if j != i) == 1)  # Each task i must precede exactly one task j
    @constraint(model, sum(x[j, i] for j in 1:n if j != i) == 1)  # Each task j must be preceded by exactly one task i
end

for tp in 1:n
    for ta in (tp+1):n
        for i in 1:n
            for j in 1:n
                if i != j
                    for pr in 1:p
                        @constraint(model, (start[i, pr]+a[pr, i]) <= start[j, pr] + M*(1-x[i, tp]) + M*(1-x[j, ta]))
                    end
                end
            end
        end
    end
end

# Start time and sequence constraints
for i in 1:n
    # Processing constraints
    for pr in 1:(p-1)
        @constraint(model, start[i, pr+1] >= start[i, pr] + a[pr, i])
    end
    @constraint(model, start[i, p] + a[p, i] <= Cmax)
end

# Solve the model
optimize!(model)
println("Optimal Schedule Length: ", objective_value(model))

# Extract start times for visualization
starts = [value.(start[i,j]) for i in 1:n, j in 1:3]

# Function to plot Gantt Chart
function plot_gantt(starts, a, b, c)
    p = plot(xticks=true, yticks=1:n, yflip=true, legend=false, xlabel="Time", ylabel="Task")
    for i in 1:n
        plot!(p, [starts[i,1], starts[i,1]+a[i]], [i, i], line=(10, :solid, palette(:blues)[1]), label="")
        plot!(p, [starts[i,2], starts[i,2]+b[i]], [i, i], line=(10, :solid, palette(:greens)[1]), label="")
        plot!(p, [starts[i,3], starts[i,3]+c[i]], [i, i], line=(10, :solid, palette(:reds)[1]), label="")
    end
    savefig(p, "myplot.png")  # Saves as PNG
end

# Call the function to plot the Gantt chart
plot_gantt(starts, a, b, c)
