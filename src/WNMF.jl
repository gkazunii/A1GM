using LinearAlgebra
using StatsBase

function WLS_norm(W,P,Q)
    return norm(W.*P - W.*Q)
end

function WKL_divergence(W,P,Q)
    (n,m) = size(P)
    kl = 0.0
    eps = 1.0e-30
    small_number = 1.0e-100

    for idx1 = 1:n
        for idx2 = 1:m
            if W[idx1, idx2] == 0.0
                continue
            end
            if P[idx1,idx2] > eps
                kl += P[idx1, idx2] * log( P[idx1,idx2] )
                if Q[idx1, idx2] > eps
                    kl -= P[idx1, idx2] * log( Q[idx1,idx2] )
                else
                    kl -= P[idx1, idx2] * log( small_number )
                end
            end
            kl -= P[idx1, idx2]
            kl += Q[idx1, idx2]
        end
    end
    return kl
end

function wnmf_kl(A, W, r ; max_iter=200, tol = 1.0E-4, verbose = false)
    m, n = size(A)
    U = rand(m, r)
    V = rand(r, n)
    one_mn = ones(m, n)

    error_history = Float64[]
    error_at_init = WKL_divergence(W, A, U*V)
    previous_error = error_at_init
    for iter in 1:max_iter
        V .= (V ./ (U'*W)) .* (U' * (( W .* A ) ./ (U*V)))
        U .= (U ./ (W*V')) .* ((( W .* A ) ./ (U*V)) * V' )

        if tol > 0 && iter % 1 == 0
            error = WKL_divergence(W, A, U*V)
            append!(error_history, error)
            if verbose
                println("iter: $iter cost: $error")
            end
            if (previous_error - error) / error_at_init < tol
                break
            end
            previous_error = error
        end
    end

    return U, V, error_history
end

function wnmf_euc(A, W, r ; max_iter=200, tol = 1.0E-4, verbose = true)
    m, n = size(A)
    U = rand(m, r)
    V = rand(r, n)

    error_history = Float64[]
    error_at_init = WLS_norm(W, A, U*V)
    previous_error = error_at_init
    for iter = 1:max_iter
        V .=  V .* ( U' * (W .* A) ) ./ ( U' * (W .* (U * V) ) )
        U .=  U .* ( (W .* A)  * V') ./ ( (W .* (U  * V)) * V' )

        if tol > 0 && iter % 1 == 0
            error = WLS_norm(W, A, U*V)
            append!(error_history, error)
            if verbose
                println("iter: $iter cost: $error")
            end
            if (previous_error - error) / error_at_init < tol
                break
            end
            previous_error = error
        end
    end

    return U*V, error_history
end

