using Random

function tspXYRand(n::Int, myseed::Int = 1234)
    Random.seed!(myseed)
    xy = rand(n, 2) * 1_000.0
    return xy
end

function tspXYCluster(n::Int, myseed::Int = 1234)
    Random.seed!(myseed)
    cs = rand(3:8)
    xy = rand(n, 2) * 1_000.0

    for i in (cs+1):n
        while true
            dps = sum(exp(-sqrt((xy[i, 1] - xy[j, 1])^2
                                + (xy[i, 2] - xy[j, 2])^2) / 40.0) for j in 1:cs)

            if rand() < dps break end

            xy[i, 1] = rand() * 1_000.0
            xy[i, 2] = rand() * 1_000.0
        end
    end
    return xy
end

function distEuclidean(xy::Array{Float64,2})
    n, _ = size(xy)
    dist = [sqrt((xy[i, 1] - xy[j, 1])^2 + (xy[i, 2] - xy[j, 2])^2) for i in 1:n, j in 1:n]
    return dist
end

function distManhattan(xy::Array{Float64,2})
    n, _ = size(xy)
    dist = [abs(xy[i, 1] - xy[j, 1]) + abs(xy[i, 2] - xy[j, 2]) for i in 1:n, j in 1:n]
    return dist
end

function distMaximum(xy::Array{Float64,2})
    n, _ = size(xy)
    dist = [max(abs(xy[i, 1] - xy[j, 1]), abs(xy[i, 2] - xy[j, 2])) for i in 1:n, j in 1:n]
    return dist
end

function distGeographical(xy::Array{Float64,2})
    n, _ = size(xy)
    # xy = DDD.MM format
    # dist = GEO from TSPLIB
    lat = floor.(xy[:,1])
    lat += (xy[:,1] - lat) * 5.0 / 3.0
    lat *= π / 180.0

    lon = floor.(xy[:,2])
    lon += (xy[:,2] - lon) * 5.0 / 3.0
    lon *= π / 180.0

    q1 = [cos(lon[i] - lon[j]) for i in 1:n, j in 1:n ]
    q2 = [cos(lat[i] - lat[j]) for i in 1:n, j in 1:n ]
    q3 = [cos(lat[i] + lat[j]) for i in 1:n, j in 1:n ]

    rrr = 6378.388

    dist = 0.5 .* ( (1.0 .+ q1) .* q2 - (1.0 .- q1) .* q3 )
    dist = rrr .* acos.(dist)

    return dist
end
