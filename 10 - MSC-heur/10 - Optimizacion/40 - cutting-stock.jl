using JuMP
using GLPK

function exCuttingStock()
    jumbo_ancho = 100.0
    jumbo_costo = 1.0

    bobina_ancho   = Float64[45, 36, 31, 14]
    bobina_demanda = Float64[40, 50, 60, 80]
    bobina_n = length(bobina_ancho)

    @assert length(bobina_ancho) == length(bobina_demanda)
    @assert all( bobina_ancho .<= jumbo_ancho )

    patrones = [i==j ? 1 : 0 for i in 1:bobina_n, j in 1:bobina_n]
    #patrones = [i==j ? floor(Int, jumbo_ancho / bobina_ancho[i]) : 0 for i in 1:bobina_n, j in 1:bobina_n]
    patron_n = bobina_n

    mCSP = JuMP.Model(GLPK.Optimizer)
    @variable(mCSP, x[1:patron_n] >= 0)
    @objective(mCSP, Min, sum(jumbo_costo * x))
    @constraint(mCSP, r[i in 1:bobina_n], sum(patrones[i,:] .* x) >= bobina_demanda[i])
    
    JuMP.optimize!(mCSP)

    function calculaPatron(n::Int, ancho::Array{Float64,1}, maxancho::Float64, precioSombra::Array{Float64,1})
        @assert n == length(ancho)
        @assert n == length(precioSombra)

        mBobina = JuMP.Model(GLPK.Optimizer)
        @variable(mBobina, xx[1:n] >= 0, Int)
        @objective(mBobina, Min, jumbo_costo - sum(precioSombra .* xx))
        @constraint(mBobina, sum(ancho .* xx) <= maxancho)

        JuMP.optimize!(mBobina)

        patron = JuMP.value.(xx)
        rc = JuMP.objective_value(mBobina)

        println("* Problema Esclavo = mBobina")
        println("  z = ", rc)
        println("  Patron = ", patron)

        if rc >= -eps(Float16) return nothing end
        return patron
    end

    while true
        println("* Problema Maestro = Cutting Stock Problema Relax")
        println("  z = ", JuMP.objective_value(mCSP))
        for j in 1:patron_n
            println("  Patron ", j, " = ", patrones[:,j] ," usado ", JuMP.value(x[j]), " veces")
        end
        yval = []
        for i in list_of_constraint_types(mCSP)
            if i[1] == VariableRef continue end
            yval = [JuMP.dual(j) for j in JuMP.all_constraints(mCSP, i[1], i[2])]
            # shadow_price vs dual
        end
        println("  Dual Piezas = ", yval)

        nuevo_patron = calculaPatron(bobina_n, bobina_ancho, jumbo_ancho, yval)

        if nuevo_patron === nothing break end

        patron_n += 1
        patrones = [patrones nuevo_patron]

        newX = @variable(mCSP; base_name="x[$patron_n]", lower_bound=0)
        push!(x, newX)
        JuMP.set_objective_coefficient(mCSP, newX, jumbo_costo)
        JuMP.set_normalized_coefficient.(r, newX, nuevo_patron)

        JuMP.optimize!(mCSP)
    end

    JuMP.set_integer.(x)
    JuMP.optimize!(mCSP)

    println("* Problema Cutting Stock")
    println("  z = ", JuMP.objective_value(mCSP))
    for j in 1:patron_n
        println("  Patron ", j, " = ", patrones[:,j] ," usado ", JuMP.value(x[j]), " veces")
    end

    return
end

exCuttingStock()
