using StatsBase
function get_synthetic_mtx(n, m, l, k ; ongrid=false, Tint=false, Wint=false, btm=false)
    if Wint
        T = rand([1:9;],n,m)
    else
        T = rand(n, m)
    end

    if Wint
        W = rand([1], n, m)
    else
        W = rand([1.0], n, m)
    end

    if btm
        T = rand(n,m)
        W = ones(n,m)
        W[n-l:end,m-k:end] = 0
        W = convert(BitArray{2}, W)
        return T, W
    end

    if ongrid
        S1 = Set(sample(1:n,l,replace=false))
        S2 = Set(sample(1:n,k,replace=false))
        for s1 in S1
            for s2 in S2
                W[s1,s2] = 0
            end
        end
    else
        idxs = sample(collect(CartesianIndices(W)),l*k, replace=false)
        for idx in idxs
            W[idx] = 0
        end
    end
    W = convert(BitArray{2}, W)
    return T, W
end


