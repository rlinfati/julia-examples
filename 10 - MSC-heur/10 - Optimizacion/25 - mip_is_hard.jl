using JuMP
using GLPK

function mip_is_hard()
    m = JuMP.Model()

    @variable(m, x1 >= 1, Int)
    @variable(m, x2 >= 0, Int)
    @variable(m, x3 >= 0, Int)

    @objective(m, Min, x1)
    @constraint(m, r1, 1234 * x1 == 2345 * x2 + 3456 * x3)

    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.set_optimizer_attribute(m, "msg_lev", GLP_MSG_ALL)
    JuMP.set_optimizer_attribute(m, "tm_lim", 60 * 1000)

    JuMP.optimize!(m)

    @show JuMP.termination_status(m)
    @show JuMP.solve_time(m)

    if JuMP.has_values(m)
        @show JuMP.objective_value(m)
        @show JuMP.objective_bound(m)
        @show JuMP.relative_gap(m)

        @show [JuMP.value(i) for i in JuMP.all_variables(m)]
    end

    return
end

mip_is_hard()
