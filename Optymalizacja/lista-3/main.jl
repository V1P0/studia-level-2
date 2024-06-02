# Mateusz Jończak 261691

using JuMP
using GLPK

function solve_gap(job_time :: Matrix{Int},
                   job_cost :: Matrix{Int}, 
                   jobs :: Vector{Int},
                   machines :: Vector{Int},
                   machine_max_work_time :: Vector{Int},
                   graph :: Matrix{Int})

    local model :: Model
    local m :: Int # machines
    local n :: Int # jobs
    local epsilon :: Float64

    (m, n) = size(job_time)

    model = Model(GLPK.Optimizer)

    # x [i,j] - machine ith doing job jth (only x[i,j] part of job)
    @variable(model, x[1:m, 1:n] >= 0)

    # In this case we have profit, so maximize it
    @objective(model, Max, sum(x[i, j] * job_cost[i, j] * graph[i, j] for i = 1:m, j = 1:n))

    # We can do exacly 100% of each job
    epsilon = eps(Float64)
    for j in 1:n
        if jobs[j] == 1
            @constraint(model, sum(x[i, j] * graph[i, j] for i = 1:m) == 1)
        end
    end

    # Machine can works only for maxTime
    for i in 1:m
        if machines[i] == 1
            @constraint(model, sum(x[i, j] * job_time[i, j] * graph[i, j] for j = 1:n) <= machine_max_work_time[i])
        end
    end
    optimize!(model)
    status = termination_status(model)
    if status != MOI.OPTIMAL
        println("Model not optimal")
        return status, 0, 0
    end
    return status, objective_value(model), value.(x)
end

function aprox(job_time :: Matrix{Int},
               job_cost :: Matrix{Int},
               jobs :: Vector{Int},
               machines :: Vector{Int},
               machine_max_work_time :: Vector{Int},
               graph :: Matrix{Int},
               filename :: String)


    local m :: Int # machines
    local n :: Int # jobs
    local epsilon :: Float64
    local machine_max_time_in_work_copy :: Vector{Int}
    local final_graph :: Matrix{Int}
    local deleted :: Bool

    local final_cost :: Int

    (m, n) = size(job_time)

    # We need to change values, so lets copy vector
    machine_max_time_in_work_copy = copy(machine_max_work_time)

    epsilon = 0.00001;

    # Start with empty graph
    final_graph = zeros(Int, m, n)

    while sum(jobs[j] for j = 1:n) > 0
        (status, fval, x) = solve_gap(job_time, job_cost, jobs, machines, machine_max_work_time, graph)
        deleted = false
        for i in 1:m
            for j in 1:n
                # remove all edge, such that x[i,j] == 0
                if graph[i, j] == 1 && x[i, j] <= epsilon # == 0
                    graph[i, j] = 0
                    deleted = true
                end
            end
        end

        # if job is completed, remove job and edge from work graph, but ofc add to final graph
        for i in 1:m
            for j in 1:n
                if deleted == false && graph[i, j] == 1 && (x[i, j] <= 1 + epsilon) && (x[i, j] >= 1 - epsilon) # == 1
                    final_graph[i, j] = 1
                    jobs[j] = 0
                    machine_max_work_time[i] = machine_max_work_time[i] - job_time[i, j]
                    deleted = true
                    graph[i, j] = 0
                end
            end
        end

        if deleted == false
            for i in 1:m
                # remove machine such that degree == 1
                if deleted == false && sum(graph[i, j] * machines[i] for j = 1:n) == 1
                    machines[i] = 0
                    deleted = true
                end

                # remove machine that job is finished and has degree == 2
                if deleted == false && sum(graph[i, j] * machines[i] for j = 1:n) == 2 && sum(x[i, j] * jobs[j] for j = 1:n) >= 1 - epsilon # >= 1
                    machines[i] = 0
                    deleted = true
                end
            end
        end
    end

    final_cost = sum(final_graph[i, j] * job_cost[i, j] for i = 1:m, j = 1:n)
    println(final_cost)
    # Time on each machine vs max time on each machine
    open(filename, "w") do f
        for i in 1:m
            fulltime = sum(final_graph[i, j] * job_time[i, j] for j = 1:n)
            println(f, machine_max_time_in_work_copy[i], ",", fulltime)
        end
    end
end

function Experiment()
    local files :: Int
    local prefix :: String
    local name :: String
    local tests :: Int

    local job_cost :: Matrix{Int}
    local job_time :: Matrix{Int}
    local machine_max_work_time :: Vector{Int}
    local jobs :: Vector{Int}
    local machines :: Vector{Int}
    local graph :: Matrix{Int}

    files = 12
    prefix = "./problems/gap"
    results = "./results/gap"

    optimals = [336, 327, 339, 341, 326,
    434, 436, 420, 419, 428,
    580, 564, 573, 570, 564,
    656, 644, 673, 647, 664,
    563, 558, 564, 568, 559,
    761, 759, 758, 752, 747,
    942, 949, 968, 945, 951,
    1133, 1134, 1141, 1117, 1127,
    709, 717, 712, 723, 706,
    958, 963, 960, 947, 947,
    1139, 1178, 1195, 1171, 1171,
    1451, 1449, 1433, 1447, 1446]

    # for each file DO
    for file = 1:files
        name = prefix * string(file) * ".txt" # string concat
        f = open(name, "r")
        line = readline(f)
        tests = parse(Int, line)

        # Get size of problem
        for i in 1:tests
            print((file - 1) * tests + i, ",", optimals[(file - 1) * tests + i], ",")
            line = readline(f)
            m, n = parse.(Int, split(line))


            job_cost = zeros(Int, m, n)
            for i in 1:m
                k = 0
                while k < n
                    line = parse.(Int, split(readline(f)))
                    for j in 1:length(line)
                        job_cost[i, k + j] = line[j]
                    end
                    k += length(line)
                end
            end
            job_time = zeros(Int, m, n)
            for i in 1:m
                k = 0
                while k < n
                    line = parse.(Int, split(readline(f)))
                    for j in 1:length(line)
                        job_time[i, k + j] = line[j]
                    end
                    k += length(line)
                end
            end
            machine_max_work_time = zeros(Int, m)
            k = 0
            while k < m
                line = parse.(Int, split(readline(f)))
                for i in 1:length(line)
                    machine_max_work_time[k + i] = line[i]
                end
                k += length(line)
            end

            # All jobs need to be done
            jobs = ones(Int, n)

            # enable all machines
            machines = ones(Int, m)

            # Construct all possible combination machine --> job
            graph = ones(Int, m, n)

            for i in 1:m
                for j in 1:n
                    if job_time[i, j] > machine_max_work_time[i]
                        graph[i][j] = 0
                    end
                end
            end

        name = results * string(file) * "-" * string(i) * ".csv"
        aprox(job_time, job_cost, jobs, machines, machine_max_work_time, graph, name)
        end
    close(f)
    end

end

Experiment()