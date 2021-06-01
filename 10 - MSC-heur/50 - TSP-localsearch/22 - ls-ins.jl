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

function mhLocalSearch1(tour::Array{Int,1}, dist::Array{Float64,2}, sf::Bool = false)
    ctour = copy(tour)
    busqueda0 = [ tspDist(dist, ctour) ] # actual ztour

    while true
        newtour = tspIns(ctour, dist, sf)
        if newtour === nothing break end

        newtourz = tspDist(dist, newtour)
        @show newtourz, newtour
        
        if newtourz < busqueda0[end]
            push!(busqueda0, newtourz)
            ctour = newtour
        else
            break
        end
    end

    savefig(plot(busqueda0), "tsp-plot-z.png")
    return ctour
end

function main(n::Int = 10)
    Random.seed!(1234)
    xy = rand(n, 2) * 1_000.0
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]
    
    tour = tspRND(dist)
    @show tspDist(dist, tour)

    tour2 = mhLocalSearch1(tour, dist, true)
    @show tspDist(dist, tour2)

    p = tspPlot(xy, tour2)
    return p
end

main()
