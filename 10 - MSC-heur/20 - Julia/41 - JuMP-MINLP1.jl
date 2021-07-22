using JuMP
using SCIP

function exJuMP()
    v = [10, 20, 12, 23, 42]
    w = [12, 45, 12, 22, 21]
    n = length(v)
    @assert length(v) == length(w)

    m = JuMP.Model()
    @variable(m, x[1:n], Bin)
    @objective(m, Max, sum(v .* x))
    @constraint(m, sum(w .* x .* x) <= 45)

    println(m)

    JuMP.set_optimizer(m, SCIP.Optimizer)
    JuMP.optimize!(m)

    @show JuMP.termination_status(m)
    @show JuMP.solve_time(m)
    @show JuMP.primal_status(m)
    @show JuMP.dual_status(m)

    if JuMP.has_values(m)
        @show JuMP.objective_value(m)
        @show JuMP.objective_bound(m)
        @show JuMP.relative_gap(m)
        @show JuMP.value.(x)
    end

    return
end

exJuMP()
