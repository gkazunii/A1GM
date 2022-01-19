using BenchmarkTools
using Plots
using Statistics
using Plots.PlotMeasures
using Printf
using FileIO
using BenchmarkTools
include("WNMF.jl")
include("A1GM.jl")
include("config.jl")
include("make_mtx.jl")
include("data_loader.jl")

function main_real()
    println("experiments on real datasets")

    results =
        Dict( datasetname =>
             Dict(
                  method =>
                  Dict( "WKLerror" => 0.0,
                        "WLSerror" => 0.0,
                        "runtime" => 0.0,
                        "runtime_std" => 0.0)
                  for method in methods)
            for datasetname in datasetnames)

    for datasetname in datasetnames
        println("===================================")
        println("datasetname $datasetname")
        T, W = load_mtx(datasetname)
        @printf("%10s %10s %10s %10s \n", "method", "KLerror", "LSerror", "runtime")

        ######################################################
        method = "WL1RR"
        t_WL1RR = @benchmark A1GM($T[:,:],$W)
        R = A1GM(T[:,:],W)

        WKLerror = round(WKL_divergence(W, T, R), digits=4)
        WLSerror = round(WLS_norm(W, T, R), digits=4)

        t_WL1RR_mean = time(mean(t_WL1RR))*10e-9
        t_WL1RR_std  = time(std(t_WL1RR))*10e-9

        results[datasetname][method]["WKLerror"] = WKLerror
        results[datasetname][method]["WLSerror"] = WLSerror
        results[datasetname][method]["runtime"] = t_WL1RR_mean
        results[datasetname][method]["runtime_std"] = t_WL1RR_std
        @printf("%10s %10s %8f %10f \n", "WL1RR", WKLerror, WLSerror, t_WL1RR_mean)

        ######################################################
        method = "WNMF"
        t_wnmf = @benchmark wnmf_kl($T, $W, 1)
        Utmp, Vtmp, _ = wnmf_kl(T, W, 1)
        R = Utmp*Vtmp
        WKLerror = round(WKL_divergence(W, T, R), digits=4)
        WLSerror = round(WLS_norm(W, T, R), digits=4)
        t_wnmf_mean = time(mean(t_wnmf))*10e-9
        t_wnmf_std  = time(std(t_wnmf))*10e-9

        results[datasetname][method]["WKLerror"] = WKLerror
        results[datasetname][method]["WLSerror"] = WLSerror
        results[datasetname][method]["runtime"] = t_wnmf_mean
        results[datasetname][method]["runtime_std"] = t_wnmf_std
        @printf("%10s %10s %8f %10f \n", "WNMF_KL", WKLerror, WLSerror, t_wnmf_mean)

        ######################################################
        #t_weuc = @benchmark wnmf_euc($T, $W, 1)
        #R, _ = wnmf_euc(T, W, 1)
        #WKLerror = round(WKL_divergence(W, T, R), digits=4)
        #WLSerror = round(WLS_norm(W, T, R), digits=4)
        #t_weuc_mean = time(mean(t_weuc))*10e-9
        #t_weuc_std  = time(std(t_weuc))*10e-9
        #@printf("%10s %10s %8f %10f \n", "WNMF_LS", WKLerror, WLSerror, t_weuc_mean)
    end
    save_path = "../results/real/reals.jld2"
    save(save_path, results)
    println("$save_path has been saved")

end

function main()
    # p is missing rate
    for p in ps
        runtimes     = Dict("WL1RR" => [], "WNMF" => [])
        runtimes_std = Dict("WL1RR" => [], "WNMF" => [])
        errors       = Dict("WL1RR" => [], "WNMF" => [])
        for n in ns
            l = Int(floor(n * sqrt(p) / 10))
            k = Int(floor(n * sqrt(p) / 10))
            T, W = get_synthetic_mtx(n,n,l,k, ongrid=ongrid, Tint=Tint, Wint=Wint, btm=btm)

            println("--------------------------")
            println("matrix size $n, number of missing values $l * $k, missing rate $p")
            @printf("%10s %10s %10s \n", "method", "KLerror", "runtime")

            t_WL1RR = @benchmark A1GM($T,$W)
            R = A1GM(T,W)
            WKLerror = WKL_divergence(W, T, R)

            t_WL1RR_mean = time(mean(t_WL1RR))*10e-9
            t_WL1RR_std  = time(std(t_WL1RR))*10e-9

            append!(runtimes["WL1RR"], t_WL1RR_mean)
            append!(runtimes_std["WL1RR"], t_WL1RR_std)
            append!(errors["WL1RR"], WKLerror)
            @printf("%10s %8f %10f \n", "WL1RR", WKLerror, t_WL1RR_mean)

            t_wnmf = @benchmark wnmf_kl($T, $W, 1)
            Utmp, Vtmp, _ = wnmf_kl(T, W, 1)
            R = Utmp*Vtmp
            WKLerror = WKL_divergence(W, T, R)
            t_wnmf_mean = time(mean(t_wnmf))*10e-9
            t_wnmf_std  = time(std(t_wnmf))*10e-9
            append!(runtimes["WNMF"], t_wnmf_mean)
            append!(runtimes_std["WNMF"], t_wnmf_std)
            append!(errors["WNMF"], WKLerror)
            @printf("%10s %8f %10f \n", "WNMF", WKLerror, t_wnmf_mean)
        end
        results = Dict(
                    "p" => p,
                    "ns" => ns,
                    "ongrid" => ongrid,
                    "runtimes" => runtimes,
                    "runtimes_std" => runtimes_std,
                    "errors" => errors
                    )
        save_path = "../results/synthetic/grid$ongrid$p.jld2"
        save(save_path, results)
        println("$save_path has been saved")
        #get_timeplot(ns, p, runtimes, runtimes_std)
        #get_errorplot(ns, p, errors)
    end
end

main()
#main_real()
