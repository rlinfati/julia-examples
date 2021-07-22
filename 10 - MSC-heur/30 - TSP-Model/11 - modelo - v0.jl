using JuMP
using GLPK
using Random
using Plots

function exTSP0()
    Random.seed!(1234)

    n = 10
    xy = rand(n, 2) * 1_000.0
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]

    # MODELO TSP BASE
    m = JuMP.Model()
    @variable(m, x[1:n, 1:n], Bin)
    @objective(m, Min, sum(dist .* x))
    @constraint(m, r0[i in 1:n], x[i, i] == 0)
    @constraint(m, r1[i in 1:n], sum(x[i, :]) == 1)
    @constraint(m, r2[j in 1:n], sum(x[:, j]) == 1)

    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.set_optimizer_attribute(m, "msg_lev", GLP_MSG_ALL)
    JuMP.set_optimizer_attribute(m, "tm_lim", 60 * 1000)

    # MODELO TSP SEC
    tour = [8, 4, 10]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)
    tour = [1, 5]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)
    tour = [7, 9]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)
    tour = [3, 2, 6]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)
    tour = [2, 6]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)
    tour = [7, 9, 3]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)
    tour = [4, 10, 5, 1, 8]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)
    tour = [4, 10]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)
    tour = [1, 5, 6, 2, 3, 9, 7, 8]
    @constraint(m, sum(x[i, j] for i in tour, j in tour) <= length(tour) - 1)

    # SOLUCION
    JuMP.optimize!(m)
    xpar = [[i, j] for i in 1:n, j in 1:n if JuMP.value(x[i, j]) ≈ 1.0]
    plot(legend = false)
    scatter!(xy[:, 1], xy[:, 2], color = :blue)
    for i in 1:n
        annotate!(xy[i, 1], xy[i, 2], text("$i", :top))
    end
    for i in xpar
        plot!(xy[i, 1], xy[i, 2], color = :black)
    end

    return plot!()
end

exTSP0()
