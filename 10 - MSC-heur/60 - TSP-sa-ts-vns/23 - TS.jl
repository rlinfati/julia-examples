using Plots
using Random

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

function tspRND(dist::Array{Float64,2})
    n, _ = size(dist)

    tour = randperm(n)
    push!(tour, tour[1])

    # SOLUCION
    @show tour
    @show sum(dist[tour[i], tour[i+1]] for i in 1:n)

    return tour
end

function tspInsTS(tour::Array{Int,1}, dist::Array{Float64,2}, tabulist::Array{Array{Int,1},1})
    n, _ = size(dist)

    besti = 0
    bestj = 0
    bestd = +Inf
    for i in 2:n-1, j in i+2:n+1
        if [tour[i-1], tour[i+1]] in tabulist continue end
        if [tour[j-1], tour[i]] in tabulist continue end
        if [tour[i], tour[j]] in tabulist continue end

        dd = 0.0
        dd -= dist[tour[i-1], tour[i]] + dist[tour[i], tour[i+1]]
        dd += dist[tour[i-1], tour[i+1]]
        dd -= dist[tour[j-1], tour[j]]
        dd += dist[tour[j-1], tour[i]] + dist[tour[i], tour[j]]
        if dd < bestd - eps(Float16)
            besti = i
            bestj = j
            bestd = dd
        end
    end

    if besti == 0 || bestj == 0 return (nothing, nothing, nothing) end

    newtour = copy(tour)
    insert!(newtour, bestj, newtour[besti])
    deleteat!(newtour, besti)

    mov1 = [tour[besti-1], tour[besti]]
    mov2 = [tour[besti], tour[besti+1]]
    mov3 = [tour[bestj-1], tour[bestj]]

    return (newtour, [mov1, mov2, mov3], "tspInsTS")
end

function tspSwapTS(tour::Array{Int,1}, dist::Array{Float64,2}, tabulist::Array{Array{Int,1},1})
    n, _ = size(dist)

    besti = 0
    bestj = 0
    bestd = +Inf
    for i in 2:n-1, j in i+2:n
        if [tour[i-1], tour[j]] in tabulist continue end
        if [tour[j], tour[i+1]] in tabulist continue end
        if [tour[j-1], tour[i]] in tabulist continue end
        if [tour[i], tour[j+1]] in tabulist continue end

        dd = 0.0
        dd += dist[tour[i-1], tour[j]] + dist[tour[j], tour[i+1]]
        dd += dist[tour[j-1], tour[i]] + dist[tour[i], tour[j+1]]
        dd -= dist[tour[i-1], tour[i]] + dist[tour[i], tour[i+1]]
        dd -= dist[tour[j-1], tour[j]] + dist[tour[j], tour[j+1]]
        if dd < bestd - eps(Float16)
            besti = i
            bestj = j
            bestd = dd
        end
    end

    if besti == 0 || bestj == 0 return (nothing, nothing, nothing) end

    newtour = copy(tour)
    newtour[besti], newtour[bestj] = newtour[bestj], newtour[besti]

    mov1 = [tour[besti-1], tour[besti]]
    mov2 = [tour[besti], tour[besti+1]]
    mov3 = [tour[bestj-1], tour[bestj]]
    mov4 = [tour[bestj], tour[bestj+1]]

    return (newtour, [mov1, mov2, mov3, mov4], "tspSwapTS")
end

function tsp2OptTS(tour::Array{Int,1}, dist::Array{Float64,2}, tabulist::Array{Array{Int,1},1})
    n, _ = size(dist)

    besti = 0
    bestj = 0
    bestd = +Inf
    for i in 2:n-1, j in i+1:n
        if [tour[i-1], tour[j]] in tabulist continue end
        if [tour[i], tour[j+1]] in tabulist continue end

        dd = dist[tour[i-1], tour[j]] + dist[tour[i], tour[j+1]] - dist[tour[i-1], tour[i]] - dist[tour[j], tour[j+1]]
        if dd < bestd - eps(Float16)
            besti = i
            bestj = j
            bestd = dd
        end
    end

    if besti == 0 || bestj == 0 return (nothing, nothing, nothing) end

    newtour = reverse(tour, besti, bestj)

    mov1 = [tour[besti-1], tour[besti]]
    mov2 = [tour[bestj], tour[bestj+1]]

    return (newtour, [mov1, mov2], "tsp2OptTS")
end

function mhTS(tour::Array{Int,1}, dist::Array{Float64,2}, nbh::Array{Function,1})
    n, _ = size(dist)
    ctour = copy(tour)
    besttour = copy(tour)

    tabulist::Array{Array{Int,1},1} = []
    tabutenure = 7
    maxiter = 10 * n

    busqueda0 = [tspDist(dist, ctour)] # actual ztour
    busqueda1 = copy(busqueda0)        # mejor  ztour
    busquedafn = ["base"]              # actual fn

    for _ in 1:maxiter
        nbh_tour = [nbh_i(ctour, dist, tabulist) for nbh_i in nbh]
        nbh_ztour = []
        for (t, mv1, fn) in nbh_tour
            if t === nothing continue end
            zt = tspDist(dist, t)
            push!(nbh_ztour, (zt, t, mv1, fn))
        end
        if length(nbh_ztour) == 0 break end

        sort!(nbh_ztour)
        newtourz, newtour, mov1, fn = nbh_ztour[1]

        ctour = newtour
        if newtourz < busqueda1[end]
            besttour = newtour
        end

        for mvi in mov1
            push!(tabulist, mvi)
        end
        while length(tabulist) > tabutenure
            popfirst!(tabulist)
        end

        push!(busqueda0, newtourz)
        if newtourz < busqueda1[end]
            push!(busqueda1, newtourz)
        else
            push!(busqueda1, busqueda1[end])
        end
        push!(busquedafn, fn)
    end

    plot(busqueda0)
    plot!(busqueda1)
    savefig("tsp-plot-z.png")

    io = open("tsp-plot-fn.txt", "w") do io
        println(io, busquedafn)
        for x in busquedafn
            println(io, x)
        end
    end

    return besttour
end

function main(n::Int = 10)
    Random.seed!(1234)
    xy = rand(n, 2) * 1_000.0
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]

    tour = tspRND(dist)
    @show tspDist(dist, tour)

    nbh::Array{Function,1} = [tspInsTS, tspSwapTS, tsp2OptTS]
    tour2 = mhTS(tour, dist, nbh)
    @show tspDist(dist, tour2)

    p = tspPlot(xy, tour2)
    return p
end

main()
