using Plots
using Random
using Statistics

function tspPlot(xy::Array{Float64,2}, tour::Array{Int,1})
    n, _ = size(xy)

    plot(legend = false)
    scatter!(xy[:, 1], xy[:, 2], color = :blue)
    for i in 1:n
        annotate!(xy[i, 1], xy[i, 2], text("$i", :top))
    end

    plot!(xy[tour, 1], xy[tour, 2], color = :black)

    return plot!()
end

function tspDist(dist::Array{Float64,2}, tour::Array{Int,1})
    n, _ = size(dist)

    f = tour[1] == tour[end] && sort(tour[1:(end-1)]) == 1:n
    if f == false return +Inf end

    totalDist = sum(dist[tour[i], tour[i+1]] for i in 1:n)
    return totalDist
end

function gaPMX(padre1::Array{Int,1}, padre2::Array{Int,1})
    n = length(padre1) - 1

    gen1 = rand(2:n-1)
    gen2 = rand(2:n-1)
    while gen1 == gen2 gen2 = rand(2:n-1) end
    if gen1 > gen2 gen1, gen2 = gen2, gen1 end

    hijo1 = zero(padre1)
    hijo2 = zero(padre2)

    hijo1[gen1:gen2] = padre2[gen1:gen2]
    hijo2[gen1:gen2] = padre1[gen1:gen2]

    for i in vcat(1:gen1-1, gen2+1:n)
        in1 = findfirst(isequal(padre1[i]), hijo1)
        if in1 === nothing
            hijo1[i] = padre1[i]
        else
            tmpin = in1
            while tmpin !== nothing
                tmpin = findfirst(isequal(hijo2[in1]), hijo1)
                in1 = tmpin === nothing ? in1 : tmpin
            end
            hijo1[i] = padre1[in1]
        end

        in2 = findfirst(isequal(padre2[i]), hijo2)
        if in2 === nothing
            hijo2[i] = padre2[i]
        else
            tmpin = in2
            while tmpin !== nothing
                tmpin = findfirst(isequal(hijo1[in2]), hijo2)
                in2 = tmpin === nothing ? in2 : tmpin
            end
            hijo2[i] = padre2[in2]
        end
    end

    hijo1[end] = hijo1[1]
    hijo2[end] = hijo2[1]

    return hijo1, hijo2
end

function gaSWAP(ind::Array{Int,1})
    n = length(ind) - 1

    mutind = copy(ind)

    gen1 = rand(2:n)
    gen2 = rand(2:n)
    while gen1 == gen2 gen2 = rand(2:n) end

    mutind[gen1], mutind[gen2] = mutind[gen2], mutind[gen1]
    return mutind
end

function gaDuelo(fitness::Array{Float64,1}, spop::Int)
    nPoblacion = length(fitness)
    selected = falses(nPoblacion)

    while sum(selected) < spop
        player1 = rand(1:nPoblacion)
        player2 = rand(1:nPoblacion)
        while player1 == player2 player2 = rand(1:nPoblacion) end

        sp = fitness[player1] + fitness[player2]
        if rand() < fitness[player1] / sp
            selected[player1] = true
            fitness[player1] = 0.0
        else
            selected[player2] = true
            fitness[player2] = 0.0
        end
    end

    return selected
end

function gaBestK(fitness::Array{Float64,1}, spop::Int)
    nPoblacion = length(fitness)
    selected = falses(nPoblacion)

    while sum(selected) < spop
        se = argmax(fitness)
        selected[se] = true
        fitness[se] = 0.0
    end

    return selected
end

function mhGA(dist::Array{Float64,2})
    n, _ = size(dist)

    nPoblacion = 3 * n
    nGeneraciones = 20 * n
    pCruzamiento::Float64 = 0.80
    pMutacion::Float64 = 0.05

    busqueda0 = [] # promedio ztour
    busqueda1 = [] # mejor    ztour
    mejortour = [0]

    Poblacion = [randperm(n) for _ in 1:nPoblacion]
    for ind in Poblacion
        push!(ind, ind[1])
    end

    for _ in 1:nGeneraciones
        while length(Poblacion) < 2 * nPoblacion
            padre1 = rand(Poblacion[1:nPoblacion])
            padre2 = rand(Poblacion[1:nPoblacion])
            while padre1 == padre2 padre2 = rand(Poblacion[1:nPoblacion]) end

            if rand() > pCruzamiento continue end
            hijo1, hijo2 = gaPMX(padre1, padre2)

            @assert tspDist(dist, hijo1) != Inf
            @assert tspDist(dist, hijo2) != Inf

            push!(Poblacion, hijo1)
            push!(Poblacion, hijo2)
        end

        for ind in Poblacion
            if rand() > pMutacion continue end
            mutind = gaSWAP(ind)

            @assert tspDist(dist, mutind) != Inf
            push!(Poblacion, mutind)
        end

        zt = [tspDist(dist, i) for i in Poblacion]
        push!(busqueda0, mean(zt))
        push!(busqueda1, minimum(zt))

        bestID = argmin(zt)
        if zt[bestID] < tspDist(dist, mejortour)
            mejortour = Poblacion[bestID]
        end

        fitness = mean(zt) ./ zt
        sel = gaBestK(fitness, floor(Int, nPoblacion / 5.0))
        newPob = unique(vcat([mejortour], Poblacion[sel]))
        while length(newPob) < nPoblacion
            sel = gaDuelo(fitness, nPoblacion - length(newPob))
            newPob = unique(vcat(newPob, Poblacion[sel]))
        end
        Poblacion = newPob

    end

    plot(busqueda0)
    plot!(busqueda1)
    savefig("tsp-plot-z.png")

    return mejortour
end

function main(n::Int = 10)
    Random.seed!(1234)
    xy = rand(n, 2) * 1_000.0
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]

    tour = mhGA(dist)
    @show tspDist(dist, tour)

    p = tspPlot(xy, tour)
    return p
end

main()
