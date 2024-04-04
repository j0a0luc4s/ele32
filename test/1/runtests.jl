using Random
using Plots

@testset "1" begin
    pv = Float64[]
    hammingv = Float64[]
    matrixv = Float64[]

    for p = [0.5, 0.2, 0.1, 0.05, 0.02, 0.01, 0.005, 0.002, 0.001, 0.0005, 0.0002, 0.0001]
        @testset "p = $p" begin
            original = bitrand(1000008)

            hamming = ele32.HammingCodes.encodeMany(original)
            hamming = ele32.Channels.binarySymmetric(hamming, p)
            hamming = ele32.HammingCodes.decodeMany(hamming)

            matrix = ele32.MatrixCodes.encodeMany(original)
            matrix = ele32.Channels.binarySymmetric(matrix, p)
            matrix = ele32.MatrixCodes.decodeMany(matrix)

            wrong_hamming = count(.==(false), hamming .== original)
            wrong_matrix = count(.==(false), matrix .== original)
            total = length(original)

            push!(pv, p)
            push!(hammingv, wrong_hamming/total)
            push!(matrixv, wrong_matrix/total)

            println("p = $p")
            println("pb_hamming = ", wrong_hamming, "/", total, " = ", hammingv[end])
            println("pb_matrix = ", wrong_matrix, "/", total, " = ", matrixv[end])

            plt = plot(pv, [hammingv matrixv], yscale=:log10)
            display(plt)
        end
    end
end
