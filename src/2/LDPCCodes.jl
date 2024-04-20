module LDPCCodes

using Random

struct Graph
    edges::Vector{Int64}
    dv::Int64
    dc::Int64
    v::Int64
    c::Int64
end

function generate(dv::Int64, dc::Int64, v::Int64)::Graph
    @assert dv < dc "dv must be smaller than dc"
    @assert v*dv % dc == 0 "dc must divide N*dv"
    c::Int64 = div(v*dv, dc)

    edges::Vector{Int64} = zeros(Int64, c*dc)
    lens::Vector{Int64} = zeros(Int64, c)

    r::Vector{Int64} = shuffle(collect(1:v))

    for iv in r
        minlen = minimum(lens)
        icfree::Vector{Int64} = findall(len -> len == minlen, lens)
        icchosen::Vector{Int64} = Vector{Int64}()
        if length(icfree) < dv
[1, 2]
            append!(icchosen, icfree)
            icfree = findall(len -> len == minlen + 1, lens)
            shuffle!(icfree)
            append!(icchosen, icfree[1:dv-length(icchosen)])
        else
            shuffle!(icfree)
            append!(icchosen, icfree[1:dv])
        end
        edges[dc*(icchosen .- 1) .+ lens[icchosen] .+ 1] .= iv
        lens[icchosen] .+= 1
    end

    g::Graph = Graph(edges, dv, dc, v, c)
    return g
end

function decodeOne(g::Graph, in::BitVector)::BitVector
    @assert length(in) == g.v "in must have length g.v = $(g.v)"

    errors::Vector{Int64} = zeros(Int64, g.v)

    for ic in 1:g.c
        ivs = g.edges[g.dc*(ic - 1) + 1:g.dc*ic]
        if count(==(true), in[ivs]) % 2 == 0
            continue
        end
        errors[ivs] .+= 1
    end

    out = deepcopy(in)

    it::Int64 = 0
    while !all(errors .== 0) && it < g.v
        ivmax = argmax(errors)
        out[ivmax] = ~out[ivmax]
        for iedges in findall(el -> el == ivmax, g.edges)
            ic = div(iedges - 1, g.dc) + 1
            ivs = g.edges[g.dc*(ic - 1) + 1:g.dc*ic]
            if count(==(true), out[ivs]) % 2 == 0
                errors[ivs] .-= 1
                continue
            end
            errors[ivs] .+= 1
        end
        it += 1
    end

    return out[1:g.v - g.c]
end

function decodeMany(g::Graph, in::BitVector)::BitVector
    @assert length(in) % g.v == 0 "in must have length multiple of g.v = $g.v"
    out = BitVector(undef, (g.v - g.c) * div(length(in), g.v))
    for i = 1:div(length(in), g.v)
        out[(g.v - g.c)*(i - 1) + 1:(g.v - g.c)*i] = decodeOne(g, in[g.v*(i - 1) + 1:g.v*i])
    end
    return out
end

end # module HammingCodes
