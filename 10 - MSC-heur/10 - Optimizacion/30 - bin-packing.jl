using JuMP
using GLPK

function MIPModel(w::Array{Int,1}, c::Int)
    n = length(w)
    m = JuMP.Model()

    @variable(m, x[1:n, 1:n], Bin)
    @variable(m, y[1:n], Bin)

    @objective(m, Min, sum(y))
    @constraint(m, r1[i in 1:n], sum(w[:] .* x[i, :]) <= c * y[i])
    @constraint(m, r2[j in 1:n], sum(x[:, j]) == 1)

    JuMP.set_optimizer(m, GLPK.Optimizer)
    JuMP.set_optimizer_attribute(m, "msg_lev", GLP_MSG_ALL)
    JuMP.set_optimizer_attribute(m, "tm_lim", 60 * 1000)

    JuMP.optimize!(m)
    @show JuMP.termination_status(m)
    println()

    for i in 1:n
        if JuMP.value(y[i]) ≈ 0.0 continue end
        wval = [w[j] for j in 1:n if JuMP.value(x[i, j]) ≈ 1.0]
        u = sum(wval)
        # u == w' * JuMP.value.(x[i,:])
        println("bin $i - used $u/$c = $wval")
    end

    return sum(JuMP.value.(y))
end

function heurNF(w::Array{Int,1}, c::Int)
    n = length(w)
    bin = [Int[]]
    for i in 1:n
        if sum(bin[end]) + w[i] <= c
            push!(bin[end], w[i])
        else
            push!(bin, Int[])
            push!(bin[end], w[i])
        end
    end

    for i in 1:length(bin)
        u = sum(bin[i])
        println("bin $i - used $u/$c = $(bin[i])")
    end

    return length(bin)
end

function heurFF(w::Array{Int,1}, c::Int)
    n = length(w)
    bin = [Int[]]
    for i in 1:n
        estaOK = false
        for j in 1:length(bin)
            if sum(bin[j]) + w[i] <= c
                push!(bin[j], w[i])
                estaOK = true
                break
            end
        end
        if estaOK == false
            push!(bin, Int[])
            push!(bin[end], w[i])
        end
    end

    for i in 1:length(bin)
        u = sum(bin[i])
        println("bin $i - used $u/$c = $(bin[i])")
    end

    return length(bin)
end

function heurBF(w::Array{Int,1}, c::Int)
    n = length(w)
    bin = [Int[]]
    for i in 1:n
        u = [sum(bin[i]) for i in 1:length(bin)]
        while true
            id = argmax(u)
            if sum(bin[id]) + w[i] <= c
                push!(bin[id], w[i])
                break
            else
                u[id] = 0
            end
            if sum(u) == 0
                push!(bin, Int[])
                push!(bin[end], w[i])
                break
            end
        end
    end

    for i in 1:length(bin)
        u = sum(bin[i])
        println("bin $i - used $u/$c = $(bin[i])")
    end

    return length(bin)
end

function main()
    w = [50, 3, 48, 53, 53, 4, 3, 41, 23, 20, 52, 49]
    c = 100

    println("** heur NF")
    v1, t1 = @timed heurNF(w, c)

    println("** heur FF")
    v2, t2 = @timed heurFF(w, c)

    println("** heur BF")
    v3, t3 = @timed heurBF(w, c)

    println("** RESUMEN 1 - SIN ORDENAR")
    println("** NF tiempo = ", t1, '\t', "#bins = ", v1)
    println("** FF tiempo = ", t2, '\t', "#bins = ", v2)
    println("** BF tiempo = ", t3, '\t', "#bins = ", v3)

    ww = sort(w, rev = true)

    println("** heur sorted NF")
    v1, t1 = @timed heurNF(ww, c)

    println("** heur sorted FF")
    v2, t2 = @timed heurFF(ww, c)

    println("** heur sorted BF")
    v3, t3 = @timed heurBF(ww, c)

    println("** RESUMEN 2 - CON ORDENAR")
    println("** NF tiempo = ", t1, '\t', "#bins = ", v1)
    println("** FF tiempo = ", t2, '\t', "#bins = ", v2)
    println("** BF tiempo = ", t3, '\t', "#bins = ", v3)

    println("** MIP Model")
    v1, t1 = @timed MIPModel(w, c)
    println("** RESUMEN 3 - MODELO")
    println("** MIP tiempo = ", t1, '\t', "#bins = ", v1)

    return
end

main()
