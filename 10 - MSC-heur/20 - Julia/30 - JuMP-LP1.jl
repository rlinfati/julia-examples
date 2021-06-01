using JuMP
using GLPK

function exJuMP()
    m = JuMP.Model()

    @variable(m, x1 >= 0)
    @variable(m, x2 >= 0)

    @objective(m,  Max, 3 * x1 + 5 * x2)

    @constraint(m, r01,     x1          <= 4)
    @constraint(m, r02,          2 * x2 <= 12)
    @constraint(m, r03, 3 * x1 + 2 * x2 <= 18)

    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.optimize!(m)
    @show JuMP.solve_time(m)

    @show JuMP.objective_value(m)
    @show [JuMP.value(i) for i in JuMP.all_variables(m)]

    println()

    for i in list_of_constraint_types(m)
        if i[1] == VariableRef continue end
        @show JuMP.dual_objective_value(m)
        @show [JuMP.shadow_price(j) for j in JuMP.all_constraints(m, i[1], i[2])]
        # shadow_price vs dual
    end

    return
end

exJuMP()
