module HammingCodes

include("BinarySpaces.jl")

function encodeOne(in::BitVector)::BitVector
    @assert length(in) == 4 "in must have length 4"
    out = BitVector(undef, 7)
    out[1:4] = in
    out[5] = xor(in[1], in[2], in[4])
    out[6] = xor(in[1], in[3], in[4])
    out[7] = xor(in[2], in[3], in[4])
    return out
end

function encodeMany(in::BitVector)::BitVector
    @assert length(in) % 4 == 0 "in must have length multiple of 4"
    out = BitVector(undef, 7 * div(length(in), 4))
    for i = 1:div(length(in), 4)
        out[7*(i-1)+1:7*i] = encodeOne(in[4*(i-1)+1:4*i])
    end
    return out
end

function decodeOne end

let
    allEncoded = BitMatrix(undef, 16, 7)

    for i = 1:16
        allEncoded[i, :] = encodeOne(BitVector(digits(i - 1; base=2, pad=4)))
    end

    global decodeOne
    function decodeOne(in::BitVector)::BitVector
        @assert length(in) == 7 "in must have length 7"
        _, i = findmin(el -> BinarySpaces.distance(in, BitVector(el)), eachrow(allEncoded))
        out = deepcopy(allEncoded[i, 1:4])
        return out
    end
end

function decodeMany(in::BitVector)::BitVector
    @assert length(in) % 7 == 0 "in must have length multiple of 7"
    out = BitVector(undef, 4 * div(length(in), 7))
    for i = 1:div(length(in), 7)
        out[4*(i-1)+1:4*i] = decodeOne(in[7*(i-1)+1:7*i])
    end
    return out
end

end # module HammingCodes
