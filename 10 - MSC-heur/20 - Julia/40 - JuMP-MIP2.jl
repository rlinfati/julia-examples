using JuMP
using GLPK

function exJuMP()
    m = JuMP.Model()

    @variable(m, x1 >= 1, Int)
    @variable(m, x2 >= 0, Int)
    @variable(m, x3 >= 0, Int)

    @objective(m, Min, x1)

    @constraint(m, r1, 12345*x1 == 23456*x2 + 34567*x3)

    println(m)

    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.set_optimizer_attribute(m, "msg_lev", GLP_MSG_ALL)
    JuMP.set_optimizer_attribute(m, "tm_lim", 60 * 1000)

    JuMP.set_optimizer_attribute(m, "fp_heur", GLP_ON)
    JuMP.set_optimizer_attribute(m, "ps_heur", GLP_ON)
    JuMP.set_optimizer_attribute(m, "gmi_cuts", GLP_ON)
    JuMP.set_optimizer_attribute(m, "mir_cuts", GLP_ON)
    JuMP.set_optimizer_attribute(m, "cov_cuts", GLP_ON)
    JuMP.set_optimizer_attribute(m, "clq_cuts", GLP_ON)
    JuMP.set_optimizer_attribute(m, "presolve", true)

    JuMP.optimize!(m)

    println()

    @show JuMP.termination_status(m)
    @show JuMP.primal_status(m)
    @show JuMP.dual_status(m)
    @show JuMP.solve_time(m)
    @show JuMP.relative_gap(m)
    #@show JuMP.simplex_iterations(m)
    #@show JuMP.barrier_iterations(m)
    #@show JuMP.node_count(m)
    @show JuMP.objective_value(m)
    @show JuMP.objective_bound(m)
    @show JuMP.value.([x1, x2, x3])
    
    return
end

exJuMP()
