using JuMP
using GLPK

function exJuMP()
    ㊭ = JuMP.Model()
    
    @variable(㊭, 💻 >= 0)
    @variable(㊭, 📱 >= 0)

    @objective(㊭,  Max, 3 * 💻 + 5 * 📱)

    @constraint(㊭,          💻          <= 4)
    @constraint(㊭,               2 * 📱 <= 12)
    @constraint(㊭,      3 * 💻 + 2 * 📱 <= 18)

    println(㊭)

    JuMP.set_optimizer(㊭, GLPK.Optimizer)
    JuMP.optimize!(㊭)

    @show JuMP.value(💻)
    @show JuMP.value(📱)
    @show JuMP.value(3*💻 + 5*📱)
    return
end

exJuMP()
