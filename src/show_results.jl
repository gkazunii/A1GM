using FileIO
using Statistics
using Printf
using JLD2
include("config.jl")
include("WL1RR.jl")
include("data_loader.jl")

function show_results()
    datasets_information = load("../data/datasets_information.jld2")
    results = load("../results/real/reals.jld2")

    @printf("%20s %15s %15s %15s %15s %15s %15s %15s %15s %15s %15s %15s\n", 
            "dataset",
            "shape",
            "size",
            "num_missing",
            "num_missing_up",
            "times_num_missing",
            "WNMF WKLerror",
            "WL1RR WKLerror",
            "relative WKLerror",
            "WNMF runtime",
            "WL1RR runtime",
            "relative runtime"
           )

    for datasetname in datasetnames
        @printf("%20s %15s %15s %15s %15s %15s %15s %15s %15s %15s %15s %15s \n",
             datasetname[1:min(length(datasetname),18)],
             datasets_information[datasetname]["shape"],
             datasets_information[datasetname]["size"],
             datasets_information[datasetname]["num_missing"],
             datasets_information[datasetname]["num_missing_up"],
             datasets_information[datasetname]["times_num_missing"],
             round(results[datasetname]["WNMF"]["WKLerror"], sigdigits=5),
             round(results[datasetname]["WL1RR"]["WKLerror"],sigdigits=5),
             round(results[datasetname]["WL1RR"]["WKLerror"]/results[datasetname]["WNMF"]["WKLerror"], sigdigits=5),
             round(results[datasetname]["WNMF"]["runtime"], sigdigits=5),
             round(results[datasetname]["WL1RR"]["runtime"],sigdigits=5),
             round(results[datasetname]["WL1RR"]["runtime"]/results[datasetname]["WNMF"]["runtime"], sigdigits=5),
            )
    end
end

show_results()
