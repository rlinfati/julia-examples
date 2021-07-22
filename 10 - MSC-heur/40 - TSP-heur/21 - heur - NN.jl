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

function tspNN(dist::Array{Float64,2}, s::Int = 0)
    n, _ = size(dist)

    # Heuristica Vecino mas Cercano
    if s == 0 s = rand(1:n) end
    @assert 1 <= s <= n

    tour = Int[s]
    aVisitar = collect(1:n)
    deleteat!(aVisitar, s)

    while !isempty(aVisitar)
        proxID = argmin(dist[tour[end], aVisitar])
        push!(tour, aVisitar[proxID])
        deleteat!(aVisitar, proxID)
    end
    push!(tour, s)

    # SOLUCION
    @show tour
    @show sum(dist[tour[i], tour[i+1]] for i in 1:n)

    return tour
end

function main(n::Int = 10)
    Random.seed!(1234)
    xy = rand(n, 2) * 1_000.0
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]

    tour = tspNN(dist)
    p = tspPlot(xy, tour)
    return p
end

main()
