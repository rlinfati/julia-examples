using Plots
using Random

function tspPlot(xy::Array{Float64,2}, tour::Array{Int,1})
    n, _ = size(xy)

    plot(legend=false)
    scatter!(xy[:,1], xy[:,2], color=:blue)
    for i in 1:n
        annotate!(xy[i,1], xy[i,2], text("$i", :top))
    end

    plot!(xy[tour,1] , xy[tour,2] , color=:black)

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

function tspIns(tour::Array{Int,1}, dist::Array{Float64,2}, sf::Bool = false)
    n, _ = size(dist)

    besti = 0
    bestj = 0
    bestd = 0.0
    for i in 2:n-1, j in i+2:n+1
        dd = 0.0
        dd -= dist[tour[i-1], tour[i]] + dist[tour[i], tour[i+1]]
        dd += dist[tour[i-1], tour[i+1]]
        dd -= dist[tour[j-1], tour[j]]
        dd += dist[tour[j-1], tour[i]] + dist[tour[i], tour[j]]
        if dd < bestd - eps(Float16)
            besti = i
            bestj = j
            bestd = dd
            if sf break end
        end
    end

    if besti == 0 || bestj == 0 return nothing end

    newtour = copy(tour)
    insert!(newtour, bestj, newtour[besti])
    deleteat!(newtour, besti)

    return newtour
end

function tspSwap(tour::Array{Int,1}, dist::Array{Float64,2}, sf::Bool = false)
    n, _ = size(dist)

    besti = 0
    bestj = 0
    bestd = 0.0
    for i in 2:n-1, j in i+2:n
        dd = 0.0
        dd += dist[tour[i-1], tour[j]] + dist[tour[j], tour[i+1]]
        dd += dist[tour[j-1], tour[i]] + dist[tour[i], tour[j+1]]
        dd -= dist[tour[i-1], tour[i]] + dist[tour[i], tour[i+1]]
        dd -= dist[tour[j-1], tour[j]] + dist[tour[j], tour[j+1]]
        if dd < bestd - eps(Float16)
            besti = i
            bestj = j
            bestd = dd
            if sf break end
        end
    end

    if besti == 0 || bestj == 0 return nothing end

    newtour = copy(tour)
    newtour[besti], newtour[bestj] = newtour[bestj], newtour[besti]
    return newtour
end

function tsp2Opt(tour::Array{Int,1}, dist::Array{Float64,2}, sf::Bool = false)
    n, _ = size(dist)

    besti = 0
    bestj = 0
    bestd = 0.0
    for i in 2:n-1, j in i+1:n
        dd = dist[tour[i-1], tour[j]] + dist[tour[i], tour[j+1]] - dist[tour[i-1], tour[i]] - dist[tour[j], tour[j+1]]
        if dd < bestd - eps(Float16)
            besti = i
            bestj = j
            bestd = dd
            if sf break end
        end
    end

    if besti == 0 || bestj == 0 return nothing end

    return reverse(tour, besti, bestj)
end

function mhVNS(tour::Array{Int,1}, dist::Array{Float64,2}, nbh::Array{Function,1}, sf::Bool = false)
    ctour = copy(tour)
    busqueda0 = [ tspDist(dist, ctour) ] # actual ztour
    busquedafn = [ "base" ] # actual fn

    while true
        nomejora = false
        for nbh_i in nbh
            newtour =  nbh_i(ctour, dist, sf)
            if nbh_i == nbh[end] nomejora = true end
            if newtour === nothing continue end

            zt = tspDist(dist, newtour)
            if zt < busqueda0[end]
                ctour = newtour
                push!(busqueda0, zt)
                push!(busquedafn, string(nbh_i))
                nomejora = false
                break
            end
        end
        if nomejora break end
    end

    savefig(plot(busqueda0), "tsp-plot-z.png")
    io = open("tsp-plot-fn.txt", "w") do io
        println(io, busquedafn)
        for x in busquedafn
            println(io, x)
        end
    end

    return ctour
end

function main(n::Int = 10)
    Random.seed!(1234)
    xy = rand(n, 2) * 1_000.0
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]
    
    tour = tspRND(dist)
    @show tspDist(dist, tour)

    nbh::Array{Function,1} = [tspIns, tspSwap, tsp2Opt]
    tour2 = mhVNS(tour, dist, nbh, false)
    @show tspDist(dist, tour2)

    p = tspPlot(xy, tour2)
    return p
end

main()
