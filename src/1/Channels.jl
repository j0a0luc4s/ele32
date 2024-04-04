module Channels

using Random

function binarySymmetric(u::BitVector, p::Float64)::BitVector
    v = deepcopy(u)
    for i in eachindex(v)
        if Random.rand() < p
            v[i] = ~v[i]
        end
    end
    return v
end

end # module Channels
