include("kemney_dist_st.jl")

using .kemney_sc, StaticArrays, Random

function chk_relation0x01()
    tries = 1
    while true
        println("! ", tries)
        nCandidates = rand(1:8)
        nVoters = rand(1:1000)

        e = generateElection(nCandidates, nVoters)

        X1 = SVector{nCandidates}(shuffle([i for i = 1:nCandidates]))
        X2 = SVector{nCandidates}(shuffle([i for i = 1:nCandidates]))
        
        dst, kcs = kemneyConsensus(e)
        
        dstX1 = minimum([distance(X1, i) for i in kcs])
        dstX2 = minimum([distance(X2, i) for i in kcs])

        if distance(e, X1) < distance(e, X2) && dstX2 < dstX1
            println(X1, " ", X2)
            break
        end
        
        global tries+=1
    end

    # X1 = [5, 2, 1, 3, 4], X2 = [2, 4, 5, 3, 1]
end

