using JuMP
using GLPK

function exJuMP()
    m = JuMP.Model()

    A = [1 0; 0 2; 3 2]
    b = [4; 12; 18]
    c = [3; 5]

    @variable(m, x[1:2] >= 0)
    @objective(m, Max, c' * x)
    @constraint(m, A * x .<= b)
    
    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.optimize!(m)
    @show JuMP.solve_time(m)

    @show JuMP.termination_status(m)
    @show JuMP.primal_status(m)
    @show JuMP.dual_status(m)
    report = lp_sensitivity_report(m)

    println()

    if JuMP.has_values(m)
        @show JuMP.objective_value(m)

        for i in JuMP.all_variables(m)
            xval = JuMP.value(i)
            dx_lo, dx_hi = report[i]
            fo = JuMP.objective_function(m)
            c = JuMP.coefficient(fo, i)
            rc = JuMP.reduced_cost(i)
            println("$i=$xval \t -> rc = $rc \t Δ: ($dx_lo, $dx_hi) \t -> α: ($(c+dx_lo):$(c+dx_hi))")
        end
    end

    println()

    if JuMP.has_duals(m) 
        for i in list_of_constraint_types(m)
            if i[1] == VariableRef continue end

            for j in JuMP.all_constraints(m, i[1], i[2])
                ys = JuMP.shadow_price(j) # shadow_price vs dual
                b = JuMP.normalized_rhs(j)

                dRHS_lo, dRHS_hi = report[j]
                println("$j \t -> shadow_price: $ys \t -> Δ: ($dRHS_lo, $dRHS_hi) \t -> α: ($(b+dRHS_lo):$(b+dRHS_hi))")
            end
        end
    end

    return
end

exJuMP()
