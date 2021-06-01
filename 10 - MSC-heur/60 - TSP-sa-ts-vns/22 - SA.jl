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

function tspInsSA(tour::Array{Int,1}, dist::Array{Float64,2})
    n, _ = size(dist)

    besti = rand(2:n-1)
    bestj = rand(besti+2:n+1)

    newtour = copy(tour)
    insert!(newtour, bestj, newtour[besti])
    deleteat!(newtour, besti)

    return newtour
end

function tspSwapSA(tour::Array{Int,1}, dist::Array{Float64,2})
    n, _ = size(dist)

    besti = rand(2:n-1)
    bestj = rand(besti+1:n)

    newtour = copy(tour)
    newtour[besti], newtour[bestj] = newtour[bestj], newtour[besti]
    return newtour
end

function tsp2OptSA(tour::Array{Int,1}, dist::Array{Float64,2})
    n, _ = size(dist)

    besti = rand(2:n-1)
    bestj = rand(besti+1:n)

    return reverse(tour, besti, bestj)
end

function mhSA(tour::Array{Int,1}, dist::Array{Float64,2}, nbh::Array{Function,1})
    n, _ = size(dist)
    ctour = copy(tour)
    besttour = copy(tour)

    temp = 1_000.0
    temp_alpha = 0.9753
    maxiter = 50 * n

    busqueda0  = [ tspDist(dist, ctour) ] # actual ztour
    busqueda1  =   copy(busqueda0)        # mejor  ztour
    busquedat  = [ temp ]                 # actual temp
    busquedafn = [ "base" ]               # actual fn

    for _ in 1:maxiter
        nh = rand(nbh)
        newtour = nh(ctour, dist)
        newtourz = tspDist(dist, newtour)

        delta = newtourz - busqueda0[end]
        acepta = delta < 0.0 ? true : rand() < exp(-delta / temp)
        if acepta
            ctour = newtour
            push!(busqueda0, newtourz)
        else
            push!(busqueda0, busqueda0[end])
        end

        if newtourz < busqueda1[end]
            besttour = newtour
            push!(busqueda1, newtourz)
        else
            push!(busqueda1, busqueda1[end])
        end

        temp = temp_alpha * temp
        push!(busquedat, temp)
        push!(busquedafn, string(nh))
    end

    plot(busqueda0)
    plot!(busqueda1)
    savefig("tsp-plot-z.png")

    savefig(plot(busquedat), "tsp-plot-t.png")

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

    nbh::Array{Function,1} = [tspInsSA, tspSwapSA, tsp2OptSA]
    tour2 = mhSA(tour, dist, nbh)
    @show tspDist(dist, tour2)

    p = tspPlot(xy, tour2)
    return p
end

main()
