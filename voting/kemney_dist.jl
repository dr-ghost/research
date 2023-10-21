include("kemney_dist_st.jl")

using .kemney_sc, StaticArrays, Random

function testingHypothesis0x01()
    ts = 0
    while true
        ts+=1
        println("#", ts)
        cnd = rand(1:1000)
        vot = rand(1:10)
        str = generateTMString(cnd, vot, SVector{cnd, Int64}(shuffle([i for i = 1:cnd])), rand(1:vot), rand(1:10000))

        gl = goldenLanguage0x01(str)
        l1 = lang0x01(str)

        if (gl != l1)
            return str
            break
        end

        println(gl," ", l1)
    end
end
#=
function testingHypothesis0x02()
    ts = 0
    while true
        ts+=1
        println("#", ts)
        cnd = rand(1:10)
        vot = rand(1:10)
        str = generateTMString(cnd, vot, SVector{cnd, Int64}(shuffle([i for i = 1:cnd])), rand(1:vot), rand(1:10000))

        gl = goldenLanguage0x02(str)
        l1 = lang0x02(str)

        if (gl != l1)
            return str
            break
        end

        println(gl," ", l1)
    end
end
=#
str = generateTMString(6, 6, SVector{6, Int64}(shuffle([i for i = 1:6])), 2, 0)
println(goldenLanguage0x02(str)," ", lang0x02(str))
