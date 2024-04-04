module HammingCodes

include("BinarySpaces.jl")
using .BinarySpaces

function encodeOne(u::BitVector)::BitVector
    @assert length(u) == 4 "u must have length 4"
    v = BitVector(undef, 7)
    v[1:4] = u
    v[5] = xor(u[1], u[2], u[4])
    v[6] = xor(u[1], u[3], u[4])
    v[7] = xor(u[2], u[3], u[4])
    return v
end

function encodeMany(u::BitVector)::BitVector
    @assert length(u) % 4 == 0 "u must have length multiple of 4"
    v = BitVector(undef, 7 * div(length(u), 4))
    for i = 1:div(length(u), 4)
        v[7*(i-1)+1:7*i] = encodeOne(u[4*(i-1)+1:4*i])
    end
    return v
end

function decodeOne end

let
    allEncoded = BitMatrix(undef, 16, 7)

    for i = 1:16
        allEncoded[i, :] = encodeOne(BitVector(digits(i - 1; base=2, pad=4)))
    end

    global decodeOne
    function decodeOne(u::BitVector)
        @assert length(u) == 7 "u must have length 7"
        _, i = findmin(w -> BinarySpaces.distance(u, BitVector(w)), eachrow(allEncoded))
        v = deepcopy(allEncoded[i, 1:4])
        return v
    end
end

function decodeMany(u::BitVector)
    @assert length(u) % 7 == 0 "u must have length multiple of 7"
    v = BitVector(undef, 4 * div(length(u), 7))
    for i = 1:div(length(u), 7)
        v[4*(i-1)+1:4*i] = decodeOne(u[7*(i-1)+1:7*i])
    end
    return v
end

end # module HammingCodes
