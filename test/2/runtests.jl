using Random
using Plots
using LaTeXStrings

@testset "1" begin
    pv = Float64[]
    hammingv = Float64[]
    ldpc100v = Float64[]
    ldpc200v = Float64[]
    ldpc500v = Float64[]
    ldpc1000v = Float64[]

    ldpc100g = ele32.LDPCCodes.generate(3, 7, 98)
    ldpc200g = ele32.LDPCCodes.generate(3, 7, 203)
    ldpc500g = ele32.LDPCCodes.generate(3, 7, 497)
    ldpc1000g = ele32.LDPCCodes.generate(3, 7, 994)

    p = 0.5
    while p > 1e-2
        @testset "p = $p" begin
            original = BitVector(0 for _ in 1:576520)
            original_encoded = BitVector(0 for _ in 1:1008910)

            hamming = ele32.BinarySymmetricChannels.binarySymmetric(original_encoded, p)
            hamming = ele32.HammingCodes.decodeMany(hamming)

            ldpc100 = ele32.BinarySymmetricChannels.binarySymmetric(original_encoded, p)
            ldpc100 = ele32.LDPCCodes.decodeMany(ldpc100g, ldpc100)

            ldpc200 = ele32.BinarySymmetricChannels.binarySymmetric(original_encoded, p)
            ldpc200 = ele32.LDPCCodes.decodeMany(ldpc200g, ldpc200)

            ldpc500 = ele32.BinarySymmetricChannels.binarySymmetric(original_encoded, p)
            ldpc500 = ele32.LDPCCodes.decodeMany(ldpc500g, ldpc500)

            ldpc1000 = ele32.BinarySymmetricChannels.binarySymmetric(original_encoded, p)
            ldpc1000 = ele32.LDPCCodes.decodeMany(ldpc1000g, ldpc1000)

            wrong_hamming = count(.==(false), hamming .== original)
            wrong_ldpc100 = count(.==(false), ldpc100 .== original)
            wrong_ldpc200 = count(.==(false), ldpc200 .== original)
            wrong_ldpc500 = count(.==(false), ldpc500 .== original)
            wrong_ldpc1000 = count(.==(false), ldpc1000 .== original)
            total = length(original)

            push!(pv, p)
            push!(hammingv, wrong_hamming/total)
            push!(ldpc100v, wrong_ldpc100/total)
            push!(ldpc200v, wrong_ldpc200/total)
            push!(ldpc500v, wrong_ldpc500/total)
            push!(ldpc1000v, wrong_ldpc1000/total)

            println("p = $p")
            println("pb_hamming = ", wrong_hamming, "/", total, " = ", hammingv[end])
            println("pb_ldpc100 = ", wrong_ldpc100, "/", total, " = ", ldpc100v[end])
            println("pb_ldpc200 = ", wrong_ldpc200, "/", total, " = ", ldpc200v[end])
            println("pb_ldpc500 = ", wrong_ldpc500, "/", total, " = ", ldpc500v[end])
            println("pb_ldpc1000 = ", wrong_ldpc1000, "/", total, " = ", ldpc1000v[end])

            plt = plot(
                pv,
                [hammingv ldpc100v ldpc200v ldpc500v ldpc1000v],
                xscale=:log10,
                yscale=:log10,
                xflip=true,
                xlabel="\$p\$",
                ylabel="\$P_b\$",
                label=["Hamming" "LDPC 100" "LDPC 200" "LDPC 500" "LDPC 1000" ],
                legend=:bottomleft,
                left_margin=5Plots.mm,
                dpi=400
            )
            xticks!([0.1; 0.2; 0.5], ["0.1"; "0.2"; "0.5"]),
            yticks!([0.1; 0.2; 0.5], ["0.1"; "0.2"; "0.5"]),
            display(plt)
            if !isdir("results") mkdir("results") end
            savefig("results/2.png")

            p *= 0.9
        end
    end
end
