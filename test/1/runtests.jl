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
            hamming = ele32.BinarySymmetricChannels.binarySymmetric(hamming, p)
            hamming = ele32.HammingCodes.decodeMany(hamming)

            matrix = ele32.MatrixCodes.encodeMany(original)
            matrix = ele32.BinarySymmetricChannels.binarySymmetric(matrix, p)
            matrix = ele32.MatrixCodes.decodeMany(matrix)

            nocode = ele32.BinarySymmetricChannels.binarySymmetric(original, p)

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
                xflip=true,
                xlabel="\$p\$",
                ylabel="\$P_b\$",
                label=["Hamming" "Matrix" "Nocode"],
                legend=:bottomleft,
                left_margin=5Plots.mm,
                dpi=400
            )
            xticks!([0.1; 0.2; 0.5], ["0.1"; "0.2"; "0.5"]),
            yticks!([0.1; 0.2; 0.5], ["0.1"; "0.2"; "0.5"]),
            display(plt)
            if !isdir("results") mkdir("results") end
            savefig("results/1.png")

            p *= 0.9
        end
    end
end
