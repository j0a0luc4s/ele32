module BinarySpaces

function distance(u::BitVector, w::BitVector)::Float64
    @assert length(u) == length(w) "u and w must have the same length"
    return count(==(true), xor.(u, w))
end

end # module BinarySpaces
