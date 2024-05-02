using JuMP, GLPK, Plots

# Sample data
n = 5  # Number of tasks
a = [2, 4, 6, 8, 10]  # Processing times on P1
b = [1, 3, 5, 7, 9]   # Processing times on P2
c = [5, 7, 9, 11, 13]  # Processing times on P3

# Initialize the model with GLPK solver
model = Model(GLPK.Optimizer)

# Decision variables for start and completion times
@variable(model, start[1:n, 1:3] >= 0)
@variable(model, Cmax)

# Objective: Minimize the makespan
@objective(model, Min, Cmax)

# Constraints
for i in 1:n
    # Processing time constraints
    @constraint(model, start[i, 1] + a[i] <= start[i, 2])  # Task must finish on P1 before starting on P2
    @constraint(model, start[i, 2] + b[i] <= start[i, 3])  # Task must finish on P2 before starting on P3
    @constraint(model, start[i, 3] + c[i] <= Cmax)         # Completion time of each task on P3

    # Ensure machines process tasks sequentially
    if i > 1
        @constraint(model, start[i-1, 1] + a[i-1] <= start[i, 1])
        @constraint(model, start[i-1, 2] + b[i-1] <= start[i, 2])
        @constraint(model, start[i-1, 3] + c[i-1] <= start[i, 3])
    end
end

# Solve the model
optimize!(model)
println("Optimal Schedule Length: ", objective_value(model))

# Extract start times for visualization
starts = [value.(start[i,j]) for i in 1:n, j in 1:3]

# Function to plot Gantt Chart
function plot_gantt(starts, a, b, c)
    p = plot(xticks=false, yticks=1:n, yflip=true, legend=false, xlabel="Time", ylabel="Task")
    for i in 1:n
        plot!(p, [starts[i,1], starts[i,1]+a[i]], [i, i], line=(10, :solid, palette(:blues)[1]), label="")
        plot!(p, [starts[i,2], starts[i,2]+b[i]], [i, i], line=(10, :solid, palette(:greens)[1]), label="")
        plot!(p, [starts[i,3], starts[i,3]+c[i]], [i, i], line=(10, :solid, palette(:reds)[1]), label="")
    end
    savefig(p, "myplot.png")  # Saves as PNG
end

# Call the function to plot the Gantt chart
plot_gantt(starts, a, b, c)
