using JuMP
using GLPK

function mip_is_hard()
    m = JuMP.Model()

    @variable(m, x1 >= 1, Int)
    @variable(m, x2 >= 0, Int)
    @variable(m, x3 >= 0, Int)

    @objective(m, Min, x1)
    @constraint(m, r1, 1234*x1 == 2345*x2 + 3456*x3)

    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.set_optimizer_attribute(m, "msg_lev", GLP_MSG_ALL)
    JuMP.set_optimizer_attribute(m, "tm_lim", 60 * 1000)

    function myCallbackHeuristic(cb_data)
        x = JuMP.all_variables(m)
        x_val = JuMP.callback_value.(cb_data, x)
        ret = callback_node_status(cb_data, m)
        println("** myCallbackHeuristic node_status = $(ret)")

        if x_val[1] <= 1728.0 + eps(Float16) return end

        x_vals = [1728.0, 0.0, 617.0]
        ret = MOI.submit(m, MOI.HeuristicSolution(cb_data), x, x_vals)
        println("** myCallbackHeuristic status = $(ret)")
        return
    end
    # MOI.set(m, MOI.HeuristicCallback(), myCallbackHeuristic)

    function myCallbackLazyConstraint(cb_data)
        x = JuMP.all_variables(m)
        x_val = JuMP.callback_value.(cb_data, x)
        ret = callback_node_status(cb_data, m)
        println("** myCallbackLazyConstraint node_status = $(ret)")

        if x_val[1] >= 1728.0 - eps(Float16) return end

        con = @build_constraint(x[3] == 617.0)
        ret = MOI.submit(m, MOI.LazyConstraint(cb_data), con)
        println("** myCallbackLazyConstraint status = $(ret)")
        return
    end
    # MOI.set(m, MOI.LazyConstraintCallback(), myCallbackLazyConstraint)

    function myCallbackUserCut(cb_data)
        x = JuMP.all_variables(m)
        x_val = JuMP.callback_value.(cb_data, x)
        ret = callback_node_status(cb_data, m)
        println("** myCallbackUserCut node_status = $(ret)")

        if x_val[1] >= 1728.0 - eps(Float16) return end
        
        con = @build_constraint(x[3] >= 617.0)
        ret = MOI.submit(m, MOI.UserCut(cb_data), con)
        println("** myCallbackUserCut status = $(ret)")
        return
    end
    # MOI.set(m, MOI.UserCutCallback(), myCallbackUserCut)

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
