using JuMP
using GLPK
using Plots

function modelPM(xy_c::Array{Float64,2}, xy_f::Array{Float64,2}, p::Int)
    n, _ = size(xy_c)
    m, _ = size(xy_f)
    h_c = ones(n)

    dist(c, f) = sqrt((xy_c[c,1] - xy_f[f,1])^2 + (xy_c[c,2] - xy_f[f,2])^2)

    model = JuMP.Model()
    @variable(model, x[1:m], Bin)
    @variable(model, y[1:n,1:m] >= 0)

    @objective(model, Min, sum(h_c[i]*dist(i,j)*y[i,j] for i in 1:n, j in 1:m))

    @constraint(model, r1[i in 1:n], sum(y[i,:]) == 1)
    @constraint(model, r2, sum(x) == p )
    @constraint(model, r3[i in 1:n, j in 1:m], y[i,j] <= x[j])

    JuMP.set_optimizer(model, GLPK.Optimizer)
    JuMP.set_optimizer_attribute(model, "msg_lev", GLP_MSG_ALL)
    JuMP.set_optimizer_attribute(model, "tm_lim", 60 * 1000)
    JuMP.optimize!(model)

    xval = JuMP.value.(x) .≈ 1.0
    yval = JuMP.value.(y) .> eps()

    return xval, yval
end

function modelPC(xy_c::Array{Float64,2}, xy_f::Array{Float64,2}, p::Int)
    n, _ = size(xy_c)
    m, _ = size(xy_f)

    dist(c, f) = sqrt((xy_c[c,1] - xy_f[f,1])^2 + (xy_c[c,2] - xy_f[f,2])^2)

    model = JuMP.Model()
    @variable(model, x[1:m], Bin)
    @variable(model, y[1:n,1:m], Bin)
    @variable(model, w >= 0)

    @objective(model, Min, w)

    @constraint(model, r1[i in 1:n], sum(y[i,:]) == 1)
    @constraint(model, r2, sum(x) == p)
    @constraint(model, r3[i in 1:n, j in 1:m], y[i,j] <= x[j])
    @constraint(model, r4[i in 1:n], w >= sum(dist(i,j)*y[i,j] for j in 1:m))

    JuMP.set_optimizer(model, GLPK.Optimizer)
    JuMP.set_optimizer_attribute(model, "msg_lev", GLP_MSG_ALL)
    JuMP.set_optimizer_attribute(model, "tm_lim", 60 * 1000)
    JuMP.optimize!(model)

    xval = JuMP.value.(x) .≈ 1.0
    yval = JuMP.value.(y) .> eps()

    return xval, yval
end

function plotSolution(xy_c::Array{Float64,2}, xy_f::Array{Float64,2}, xval::BitArray{1}, yval::BitArray{2})
    n, _ = size(xy_c)
    m, _ = size(xy_f)

    plot(legend=false)
    scatter!(xy_c[:,1], xy_c[:,2], markershape=:circle, markercolor=:blue)

    mc = [(xval[j] ? :red : :white) for j in 1:m]
    scatter!(xy_f[:,1], xy_f[:,2], markershape=:square, markercolor=mc)

    for i in 1:n, j in 1:m
        if yval[i,j]
            plot!([xy_c[i,1], xy_f[j,1]], [xy_c[i,2], xy_f[j,2]], color=:black)
        end
    end

    return plot!()
end

function main()
    n = 10 # customers
    m =  5 # facilities potential location
    p =  3 # p :)
    @assert m >= p

    xy_c = 1_000.0 * rand(n, 2)
    xy_f = 1_000.0 * rand(m, 2)

    println("** P-Median model")
    xval, yval = modelPM(xy_c, xy_f, p)
    p1 = plotSolution(xy_c, xy_f, xval, yval)
    plot!(p1, title = "P-Median")

    println("** P-Center model")
    xval, yval = modelPC(xy_c, xy_f, p)
    p2 = plotSolution(xy_c, xy_f, xval, yval)
    plot!(p2, title = "P-Center")

    plot(p1, p2)
    return plot!()
end

main()
