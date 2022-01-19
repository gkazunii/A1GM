using FileIO
using Statistics
using Printf
using JLD2
include("config.jl")
include("A1GM.jl")

function get_S_(W::BitArray)
    S1 = Set(map(x -> x[1], findall(x -> x != size(W)[2], Base._sum(W, 2))))
    S2 = Set(map(x -> x[2], findall(x -> x != size(W)[1], Base._sum(W, 1))))
    #@assert size(W) != (length(S1), length(S2)) "every elements are missing"
    return S1, S2
end

function load_mtx(datasetname)
    if datasetname == "heartdisease"
        #Xswis,Xclev,Xhung,Xva
        X, W = load( datasets_path[datasetname], "Xclev", "Wclev")
    else
        X, W = load( datasets_path[datasetname], "X", "W")
    end

    replace!(X, missing=>1)
    num_zero = count(X .== 0.0)
    num_negative = count(X .< 0.0)

    X .= abs.(X)
    meanX = mean(X)
    replace!(X, 0=>meanX)
    X = convert(Array{Float64,2},X)

    W = convert(BitArray{2}, W)
    return X, W, num_zero, num_negative
end

function show_data_inforamtion()
    datasets_information =
        Dict( datasetname =>
             Dict(
                "shape" => (0,0),
                "size" => 0,
                "num_missing" => 0,
                "num_missing_up" => 0,
                "times_num_missing" => 0,
                "num_zero" => 0,
                "num_negative" => 0
                 )
            for datasetname in datasetnames )

    @printf("%20s %15s %15s %15s %15s %15s %15s %15s %15s %15s\n", "dataset", "shape", "size", "num_missing", "rate_missing",
            "num_missing_up", "rate_missing_up","times_num_missing", "num_zero", "num_negative")

    for datasetname in datasetnames
        X, W, num_zero, num_negative = load_mtx(datasetname)
        (N,M) = size(X)
        num_missing = N*M - sum(W)
        rate_missing = num_missing / (N*M)
        S1,S2 = get_S_(W)
        num_missing_up = length(S1) * length(S2)
        rate_missing_up = num_missing_up / (N*M)
        @printf("%20s %15s %15s %15s %15s %15s %15s %15s %15s %15s\n",
             datasetname[1:min(length(datasetname),18)], "($N,$M)", N*M, Int(num_missing),
             round(rate_missing,digits=6), num_missing_up,
             round(rate_missing_up,digits=6), round(num_missing_up/num_missing,digits=4),
             num_zero, num_negative
            )

        datasets_information[datasetname]["shape"] = (N,M)
        datasets_information[datasetname]["size"] = N*M
        datasets_information[datasetname]["num_missing"] = num_missing
        datasets_information[datasetname]["num_missing_up"] = num_missing_up
        datasets_information[datasetname]["times_num_missing"] = round(num_missing_up / num_missing, digits=5)
        datasets_information[datasetname]["num_zero"] = num_zero
        datasets_information[datasetname]["num_negative"] = num_negative
    end
    save_path = "../data/datasets_information.jld2"
    save(save_path, datasets_information)
    println("$save_path has been saved")

end
#show_data_inforamtion()
