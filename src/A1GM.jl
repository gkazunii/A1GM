using LinearAlgebra

function exact_sol(X,Y,Z)
    sumZ2 = sum(Z,dims=2)
    sumY1 = sum(Y,dims=1)

    sumX = sum(X)
    sqrtsumX = sqrt(sumX)
    b1 = sqrt(sumX) / (sumX+sum(sumZ2)) .* ( sum(X,dims=2) + sumZ2 )
    b2 = sum(Y,dims=2) / sqrtsumX
    c1 = sqrt(sumX) / (sumX+sum(sumY1)) .* ( sum(X,dims=1) + sumY1 )
    c2 = sum(Z,dims=1) / sqrtsumX
    B = [b1 ; b2 ]
    C = [c1  c2 ]

    return B, C
end

function get_S(W)
    m, n = size(W)
    b1, b2 = fill(false, m), fill(false, n)
    #Threads.@threads for j in 1:n
    for j in 1:n
        for i in 1:m
            @inbounds if W[i,j] == 0
                b1[i] = b2[j] =true
            end
        end
    end
    b1, b2
end

function A1GM(T, W; basis=false)
    b1, b2 = get_S(W)

    X = @view T[.!b1, .!b2]
    sumX = sum(X)
    Y = @view T[  b1, .!b2]
    sumY = sum(Y)
    Z = @view T[.!b1, b2]
    sumZ = sum(Z)
    U = @view T[b1, b2]

    x1 = sum(T[.!b1,:],  dims=2)
    x2 = sum(T[ :,.!b2], dims=1)
    y1 = sum(T[b1,.!b2], dims=2)
    z2 = sum(T[.!b1,b2], dims=1)

    X .= sumX /((sumX+sumY)*(sumX+sumZ)) .* kron(x1,x2)
    Y .= 1.0 / (sumX+sumY) .* kron(y1,x2)
    Z .= 1.0 / (sumX+sumZ) .* kron(x1,z2)
    U .= 1.0 / sumX .* kron(y1,z2)

    if basis
        wa = sum(T, dims=2)
        hb = sum(T, dims=1)
        sumb1 = sum(.!b1)
        sumb2 = sum(.!b2)
        w = wa[1:sumb1]
        h = hb[1:sumb2]
        a = wa[sumb1+1:end]
        b = hb[sumb2+1:end]
        return [w; a] ./sum(wa), [h' b']
    else
        return T
    end
end
