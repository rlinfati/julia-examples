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

function tspCWs(dist::Array{Float64,2}, lamda::Float64 = 1.0, s::Int = 0)
    n, _ = size(dist)

    # Heuristica de los ahorros
    if s == 0 s = rand(1:n) end
    @assert 1 <= s <= n

    ahorro = [(dist[i, s] + dist[s, j] - lamda * dist[i, j], i, j) for i in 1:n for j in (i+1):n]
    sort!(ahorro, rev = true)
    visitado = zeros(Int, n)

    tour = [ahorro[1][2]; ahorro[1][3]]
    visitado[s] = 1
    visitado[tour[1]] = 1
    visitado[tour[2]] = 1
    visitado[s] = 1

    while sum(visitado) < n
        for (_, i, j) in ahorro
            if visitado[i] + visitado[j] != 1 continue end

            if tour[1] == i
                pushfirst!(tour, j)
                visitado[j] = 1
            elseif tour[1] == j
                pushfirst!(tour, i)
                visitado[i] = 1
            elseif tour[end] == i
                push!(tour, j)
                visitado[j] = 1
            elseif tour[end] == j
                push!(tour, i)
                visitado[i] = 1
            else
                continue
            end

            break
        end
    end

    pushfirst!(tour, s)
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

    tour = tspCWs(dist)
    p = tspPlot(xy, tour)
    return p
end

main()
