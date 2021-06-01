using Plots
using Random
using Statistics

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

function mhACO(dist::Array{Float64,2}, s::Int = 0)
    n, _ = size(dist)
    if s == 0 s = rand(1:n) end
    @assert 1 <= s <= n

    alpha = 1.0
    betha = 1.0
    rho = 0.20
    qfer = 100.0

    nHormigas = 2 * n
    maxiter   = 10 * n

    tau::Array{Float64,2} = ones(n, n)
    eta::Array{Float64,2} = mean(dist) ./ dist
    for i in 1:n eta[i,i] = eps() end

    busqueda0 = [   ] # promedio ztour
    busqueda1 = [   ] # mejor    ztour
    mejortour = [ 0 ]

    for _ in 1:maxiter
        tours = []
        for _ in 1:nHormigas
            tour = Int[ s ]

            novisited = ones(n)
            novisited[s] = 0.0

            while sum(novisited) > 0.0
                pxy = tau[tour[end],:].^alpha .* eta[tour[end],:].^betha .* novisited
                pxy = pxy ./ sum(pxy)

                next = 0
                cspxy = cumsum(pxy)
                r = rand()

                for i in 1:n
                    if novisited[i] ≈ 0.0 continue end
                    if r < cspxy[i]
                        next = i
                        break
                    end
                end
                @assert next != 0

                push!(tour, next)
                novisited[next] = 0.0
            end
            push!(tour, tour[1])
            push!(tours, tour)
        end

        zt = [tspDist(dist, i) for i in tours]
        push!(busqueda0, mean(zt))
        push!(busqueda1, minimum(zt))

        bestID = argmin(zt)
        if zt[bestID] < tspDist(dist, mejortour)
            mejortour = tours[bestID]
        end

        tau *= 1 - rho
        for h in 1:nHormigas
            up = qfer / tspDist(dist, tours[h])
            for p in 1:n
                i = tours[h][p]
                j = tours[h][p+1]
                tau[i, j] += up
            end
        end
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
    
    tour = mhACO(dist)
    @show tspDist(dist, tour)

    p = tspPlot(xy, tour)
    return p
end

main()
