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

function tspCWp(dist::Array{Float64,2}, lamda::Float64 = 1.0, s::Int = 0)
    n, _ = size(dist)

    # Heuristica de los ahorros
    if s == 0 s = rand(1:n) end
    @assert 1 <= s <= n

    ahorro = [(dist[i, s] + dist[s, j] - lamda * dist[i, j], i, j) for i in 1:n for j in (i+1):n]
    sort!(ahorro, rev = true)

    visitado = zeros(n)
    paths = []

    while sum(visitado) < n || length(paths) > 1
        for (_, i, j) in ahorro
            if visitado[i] + visitado[j] == 0
                push!(paths, [i, j])
                visitado[i] = visitado[j] = 1
            elseif visitado[i] + visitado[j] == 1
                for p in paths
                    if p[1] == i
                        pushfirst!(p, j)
                        visitado[j] = 1
                    elseif p[1] == j
                        pushfirst!(p, i)
                        visitado[i] = 1
                    elseif p[end] == i
                        push!(p, j)
                        visitado[j] = 1
                    elseif p[end] == j
                        push!(p, i)
                        visitado[i] = 1
                    end
                end
            elseif visitado[i] + visitado[j] == 2
                v1 = findfirst(p -> p[1] == i, paths)
                v1s = true
                if v1 === nothing
                    v1 = findfirst(p -> p[end] == i, paths)
                    v1s = false
                end
                if v1 === nothing continue end

                v2 = findfirst(p -> p[1] == j, paths)
                v2s = true
                if v2 === nothing
                    v2 = findfirst(p -> p[end] == j, paths)
                    v2s = false
                end
                if v2 === nothing continue end

                if v1 == v2 continue end

                vn = Int[]
                if v1s == true && v2s == true
                    vn = [reverse(paths[v1]); paths[v2]]
                elseif v1s == true && v2s == false
                    vn = [paths[v2]; paths[v1]]
                elseif v1s == false && v2s == true
                    vn = [paths[v1]; paths[v2]]
                elseif v1s == false && v2s == false
                    vn = [paths[v1]; reverse(paths[v2])]
                end
                push!(paths, vn)
                deleteat!(paths, max(v1, v2))
                deleteat!(paths, min(v1, v2))
            end
        end
    end

    tour = paths[1]
    push!(tour, tour[1])

    # SOLUCION
    @show tour
    @show sum(dist[tour[i], tour[i+1]] for i in 1:n)

    return tour
end

function main(n::Int = 10)
    Random.seed!(1234)
    xy = rand(n, 2) * 1_000.0
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]

    tour = tspCWp(dist)
    p = tspPlot(xy, tour)
    return p
end

main()
