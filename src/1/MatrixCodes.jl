module MatrixCodes

include("BinarySpaces.jl")
using .BinarySpaces
function encodeOne(u::BitVector)::BitVector
    @assert length(u) == 9 "u must have length 9"
    v = BitVector(undef, 15)
    v[1:9] = u
    v[10] = xor(u[1], u[2], u[3])
    v[11] = xor(u[4], u[5], u[6])
    v[12] = xor(u[7], u[8], u[9])
    v[13] = xor(u[1], u[4], u[7])
    v[14] = xor(u[2], u[5], u[8])
    v[15] = xor(u[3], u[6], u[9])
    return v
end

function encodeMany(u::BitVector)::BitVector
    @assert length(u) % 9 == 0 "u must have length multiple of 9"
    v = BitVector(undef, 15 * div(length(u), 9))
    for i = 1:div(length(u), 9)
        v[15*(i-1)+1:15*i] = encodeOne(u[9*(i-1)+1:9*i])
    end
    return v
end

function decodeOne end

let
    allEncoded = BitMatrix(undef, 512, 15)

    for i = 1:512
        allEncoded[i, :] = encodeOne(BitVector(digits(i - 1; base=2, pad=9)))
    end

    global decodeOne
    function decodeOne(u::BitVector)::BitVector
        @assert length(u) == 15 "u must have length 15"
        _, i = findmin(w -> BinarySpaces.distance(u, BitVector(w)), eachrow(allEncoded))
        v = deepcopy(allEncoded[i, 1:9])
        return v
    end
end

function decodeMany(u::BitVector)::BitVector
    @assert length(u) % 15 == 0 "u must have length multiple of 15"
    v = BitVector(undef, 9 * div(length(u), 15))
    for i = 1:div(length(u), 15)
        v[9*(i-1)+1:9*i] = decodeOne(u[15*(i-1)+1:15*i])
    end
    return v
end

end # module MatrixCodes
