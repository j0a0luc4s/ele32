using Random
using Plots
using LaTeXStrings

@testset "1" begin
    pv = Float64[]
    hammingv = Float64[]
    matrixv = Float64[]
    nocodev = Float64[]

    p = 0.5
    while p > 1e-2
        @testset "p = $p" begin
            original = bitrand(1000008)

            hamming = ele32.HammingCodes.encodeMany(original)
            hamming = ele32.Channels.binarySymmetric(hamming, p)
            hamming = ele32.HammingCodes.decodeMany(hamming)

            matrix = ele32.MatrixCodes.encodeMany(original)
            matrix = ele32.Channels.binarySymmetric(matrix, p)
            matrix = ele32.MatrixCodes.decodeMany(matrix)

            nocode = ele32.Channels.binarySymmetric(original, p)

            wrong_hamming = count(.==(false), hamming .== original)
            wrong_matrix = count(.==(false), matrix .== original)
            wrong_nocode = count(.==(false), nocode .== original)
            total = length(original)

            push!(pv, p)
            push!(hammingv, wrong_hamming/total)
            push!(matrixv, wrong_matrix/total)
            push!(nocodev, wrong_nocode/total)

            println("p = $p")
            println("pb_hamming = ", wrong_hamming, "/", total, " = ", hammingv[end])
            println("pb_matrix = ", wrong_matrix, "/", total, " = ", matrixv[end])
            println("pb_nocode = ", wrong_nocode, "/", total, " = ", nocodev[end])

            plt = plot(
                pv,
                [hammingv matrixv nocodev],
                xscale=:log10,
                yscale=:log10,
                xticks=[],
                yticks=[],
                xflip=true,
                xlabel="\$p\$",
                ylabel="\$P_b\$",
                label=["Hamming" "Matrix" "Nocode"],
                legend=:bottomleft,
                left_margin=5Plots.mm,
                dpi=400
            )
            display(plt)
            #savefig("plot.png")

            p *= 0.9
        end
    end
end
