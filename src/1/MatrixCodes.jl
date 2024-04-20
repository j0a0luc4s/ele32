module MatrixCodes

include("BinarySpaces.jl")

function encodeOne(in::BitVector)::BitVector
    @assert length(in) == 9 "in must have length 9"
    out = BitVector(undef, 15)
    out[1:9] = in
    out[10] = xor(in[1], in[2], in[3])
    out[11] = xor(in[4], in[5], in[6])
    out[12] = xor(in[7], in[8], in[9])
    out[13] = xor(in[1], in[4], in[7])
    out[14] = xor(in[2], in[5], in[8])
    out[15] = xor(in[3], in[6], in[9])
    return out
end

function encodeMany(in::BitVector)::BitVector
    @assert length(in) % 9 == 0 "in must have length multiple of 9"
    out = BitVector(undef, 15 * div(length(in), 9))
    for i = 1:div(length(in), 9)
        out[15*(i-1)+1:15*i] = encodeOne(in[9*(i-1)+1:9*i])
    end
    return out
end

function decodeOne end

let
    allEncoded = BitMatrix(undef, 512, 15)

    for i = 1:512
        allEncoded[i, :] = encodeOne(BitVector(digits(i - 1; base=2, pad=9)))
    end

    global decodeOne
    function decodeOne(in::BitVector)::BitVector
        @assert length(in) == 15 "in must have length 15"
        _, i = findmin(el -> BinarySpaces.distance(in, BitVector(el)), eachrow(allEncoded))
        out = deepcopy(allEncoded[i, 1:9])
        return out
    end
end

function decodeMany(in::BitVector)::BitVector
    @assert length(in) % 15 == 0 "in must have length multiple of 15"
    out = BitVector(undef, 9 * div(length(in), 15))
    for i = 1:div(length(in), 15)
        out[9*(i-1)+1:9*i] = decodeOne(in[15*(i-1)+1:15*i])
    end
    return out
end

end # module MatrixCodes
