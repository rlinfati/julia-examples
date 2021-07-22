using JuMP
using GLPK

function exJuMP(n::Int = 5)
    m = JuMP.Model()
    c = rand(1:100, n, n)

    @variable(m, x[1:n, 1:n], Bin)
    @objective(m, Min, sum(c .* x))
    @constraint(m, ai[j in 1:n], sum(x[:, j]) == 1)
    @constraint(m, aj[i in 1:n], sum(x[i, :]) == 1)

    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.optimize!(m)

    # println(m)

    @show JuMP.termination_status(m)

    @show JuMP.solve_time(m)
    @show JuMP.objective_value(m)
    @show JuMP.objective_bound(m)
    @show JuMP.relative_gap(m)

    @show xval = JuMP.value.(x)
    for i in 1:n
        println(i, " x ", argmax(xval[i, :]))
    end

    return
end

exJuMP()
