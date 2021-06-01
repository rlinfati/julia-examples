using JuMP
using Cbc     # MIP   SOLVER
using Ipopt   # NL    SOLVER
using Juniper # MINLP SOLVER

function exJuMP()
    v = [10,20,12,23,42]
    w = [12,45,12,22,21]
    n = length(v)
    @assert length(v) == length(w)

    m = JuMP.Model()
    @variable(m, x[1:n], Bin)
    @objective(m, Max, sum(v .* x))
    @NLconstraint(m, sum(w[i]*x[i]^2 for i in 1:n) <= 45)

    println(m)

    nl_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0)
    mip_solver = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel" => 0)
    minlp_solver = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>nl_solver, "mip_solver"=>mip_solver, "log_levels"=>[])

    JuMP.set_optimizer(m, minlp_solver)
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
