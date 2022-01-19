using FileIO
using Plots.PlotMeasures
using Plots
include("config.jl")

pyplot()
function get_errorplot()
    for p in ps
        p, ns, ongrid_, errors = load("../results/synthetic/grid$ongrid$p.jld2",
                                            "p","ns","ongrid","errors")
        Ns = 3 .* ns
        plt_time = plot()
        title = "missing rate $p % grid $ongrid_"
        for method in methods
            plot!(plt_time, Ns[1:end], errors[method][1:end],
                    title = title,
                    line = (linetype_dict[method], :black, linewidth),
                    xaxis = :log,
                    yaxis = :log,
                    xlabel = "Matrix size N",
                    ylabel = "Weighted KL error",
                    label = method,
                    legend = :topleft,
                    legendfont = fnt2,
                    grid = :on,
                    size = img_size,
                    xguidefont = fnt1,
                    yguidefont = fnt1,
                    xtickfont = fnt1,
                    ytickfont = fnt1,
                    markersize = markersize,
                    markershapes = markershapes_dict[method],
                    markercolor = markercolor,
                    markerstrokewidth = markerstrokewidth,
                    bottom_margin = 5mm,
                    left_margin = 5mm
                 )
        end
        save_path = "../pngs/error_missing$p.png"
        png(plt_time, save_path);
        println("$save_path has been saved")
    end
end

function get_timeplot()
    for p in ps
        p,errorplotns, ongrid_, runtimes, runtimes_std = load("../results/synthetic/grid$ongrid$p.jld2",
                                            "p","ns","ongrid","runtimes","runtimes_std")
        Ns = 3 .* ns
        plt_time = plot()

        if ongrid_
            title = "missing rate $p % grid-like"
        else
            title = "missing rate $p % non grid-like"
        end

        for method in methods
            plot!(plt_time, Ns[1:end], runtimes[method][1:end],
                    line = (linetype_dict[method], linewidth, :black),
                    #title = title,
                    xaxis = :log,
                    yaxis = :log,
                    yticks = ([10e-5, 10e-3, 10e-1, 10e+2],["10^{-5}","10^{-3}","10^{-1}","10^2"]),
                    ylims = (10e-6,Inf),
                    xlabel = "Matrix size N",
                    ylabel = "Running time(sec.)",
                    label = method,
                    legend = :topleft,
                    legendfont = fnt2,
                    grid = :on,
                    size = img_size,
                    xguidefont = fnt1,
                    yguidefont = fnt1,
                    xtickfont = fnt1,
                    ytickfont = fnt1,
                    markersize = markersize,
                    markershapes = markershapes_dict[method],
                    markercolor = markercolor,
                    bottom_margin = 5mm,
                    left_margin = 5mm,
                    yerror = runtimes_std[method]
                 )
        end
        save_path = "../pngs/time_missing$p.pdf"
        savefig(plt_time, save_path);
        println("$save_path has been saved")
    end
end
get_timeplot()
#get_errorplot()
