using JuMP
using GLPK
using Plots
using Random

function tspPlot(xy::Array{Float64,2}, tour::Array{Int,1})
    n, _ = size(xy)

    plot(legend=false)
    scatter!(xy[:,1], xy[:,2], color=:blue)
    for i in 1:n
        annotate!(xy[i,1], xy[i,2], text("$i", :top))
    end

    plot!(xy[tour,1] , xy[tour,2] , color=:black)

    return plot!()
end

function tspMTZ(dist::Array{Float64,2})
    n, _ = size(dist)

    # MODELO TSP MANUAL
    m = JuMP.Model()
    @variable(m, x[1:n, 1:n], Bin)
    @variable(m, u[1:n] >= 0) # Miller-Tucker-Zemlin formulation
    @objective(m, Min, sum(dist .* x))
    @constraint(m, r0[i in 1:n], x[i, i] == 0)
    @constraint(m, r1[i in 1:n], sum(x[i, :]) == 1)
    @constraint(m, r2[j in 1:n], sum(x[:, j]) == 1)
    # SEC Miller-Tucker-Zemlin formulation
    @constraint(m, r3[i in 2:n, j in 2:n], u[i] + 1 <= u[j] + n * (1 - x[i, j]))
    @constraint(m, r4[i in 2:n], u[i] <= n - 1)

    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.set_optimizer_attribute(m, "msg_lev", GLP_MSG_ALL)
    JuMP.set_optimizer_attribute(m, "tm_lim", 60 * 1000)

    JuMP.optimize!(m)

    println("Termination Status: ", JuMP.termination_status(m))
    println("Objetive Value: ", JuMP.objective_value(m))
    println("Objetive Bound: ", JuMP.objective_bound(m))
    println("Relative GAP: ", JuMP.relative_gap(m))
    println("Solve Time: ", JuMP.solve_time(m))

    tour = Int[1]
    xval = JuMP.value.(x)
    while true
        push!(tour, argmax(xval[tour[end], :]))
        if tour[end] == 1 break end
    end

    # SOLUCION
    @show tour
    @show sum(dist[tour[i], tour[i+1]] for i in 1:n)

    return tour
end

function main(n::Int = 10)
    Random.seed!(1234)
    xy = rand(n, 2) * 1_000.0
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]

    @show tour = tspMTZ(dist)
    p = tspPlot(xy, tour)
    return p
end

main()

