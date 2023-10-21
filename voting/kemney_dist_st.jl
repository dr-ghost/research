module kemney_sc

using Random, StaticArrays, Base.Iterators, Permutations

export election, tmstring
export generateElection, generateTMString, distance, goldenLanguage0x01, goldenLanguage0x02, lang0x01, lang0x02, kemneyConsensus


struct election
    candidates::SVector
    votes::Vector{SVector}
end

struct tmstring
    e::election
    X::SVector
    k::Int64
    t::Int64
end

function generateElection(numCandidates::Int64, numVoters::Int64)
    candidates = SVector{numCandidates, Int64}([i for i = 1:numCandidates])

    votes = [SVector{numCandidates, Int64}(shuffle([i for i = 1:numCandidates])) for j = 1:numVoters]

    election(candidates, votes)
end

function generateTMString(numCandidates::Int64, numVoters::Int64, X::SVector, k::Int64, t::Int64)
    @assert length(X) == numCandidates || throw(ArgumentError("X is not an applicable argument"))
    @assert numVoters >= k || throw(ArgumentError("Invalid k"))
    tmstring(generateElection(numCandidates, numVoters), X, k, t)
end

function distance(X::SVector, Y::SVector)
    numCandidates = length(X)

    hash1 = zeros(numCandidates)
    hash2 = zeros(numCandidates)
    dst = 0

    for i = 1:numCandidates
        hash1[X[i]] = i
        hash2[Y[i]] = i
    end

    for i = 1:numCandidates
        for j = i+1:numCandidates
            if ((hash1[i] - hash1[j]) * (hash2[i] - hash2[j]) < 0)
                dst+=1
            end
        end
    end

    dst
end

function distance(e::election, X::SVector)
    dst = 0

    for i in e.votes
        dst += distance(X, i)
    end

    dst
end
function goldenLanguage0x01(str::tmstring)

    for i = generateChoices(str.e, str.X, str.k)
        if (distance(i, str.X) <= str.t)
            return true
        end
    end

    false
end

function goldenLanguage0x02(str::tmstring)

    for i = generateChoices(str.e, str.X, str.k)
        dst, vcs = kemneyConsensus(i) 
        for j in vcs
            if (distance(j, str.X) <= str.t)
                return true
            end
       end
    end

    false
end

function generateChoices(e::election, X::SVector, k::Int64)
    n = length(e.votes)
    l = length(e.candidates)

    tx = [SVector{l, Int64}(zeros(l)) for i = 1:n]

    Channel{election}(n) do c
        for i = 0:(1<<n)-1
            tmp = 0

            for j = 0:n-1
                if (i & (1<<j) != 0)
                    tmp+=1
                end
            end

            if (tmp == k)
                for j = 0:n-1
                    if (i & (1<<j) != 0)
                        tx[j+1] = X
                    else
                        tx[j+1] = e.votes[j+1]
                    end
                end
                put!(c, election(e.candidates, tx))
            end
        end
    end
end

function lang0x01(str::tmstring)
    ev_  = srt(str.e, str.X)

    for i = 1:str.k
        ev_[i] = str.X
    end

    e_ = election(str.e.candidates, ev_)
    distance(e_, str.X) <= str.t
end

function lang0x02(str::tmstring)
    ev_  = srt(str.e, str.X)

    for i = 1:str.k
        ev_[i] = str.X
    end

    e_ = election(str.e.candidates, ev_)

    dst, vcs = kemneyConsensus(e_) 
    for j in vcs
        if distance(j, str.X) <= str.t
            return true
        end
    end

    false
end

function srt(e::election, X::SVector)
    v_ = [e.votes[i] for i = 1:length(e.votes)]

    v_ = sort(v_, by=x -> -distance(x, X))

    v_
end

function kemneyConsensus(e::election)
    dist = 1 << 20
    n::Int64 = length(e.candidates)

    kemneySet::Vector{SVector{n, Int64}} = [SVector{n, Int64}(zeros(n))]

    for perm in PermGen(n)
        pv = SVector{n}(perm.data)
        tmd = distance(e, pv)
        if (tmd < dist)
            dist = tmd
        end
    end

    for perm in PermGen(n)
        pv = SVector{n}(perm.data)
        if (distance(e, pv) == dist)
            push!(kemneySet, pv)
        end
    end

    (dist, [kemneySet[i] for i = 2:length(kemneySet)])
end
end
