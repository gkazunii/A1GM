using Plots
# experimetns setup
# matrix size
ns = Int.(floor.(exp10.(range(1.0, stop=3.3, length=8))))
# missing rate
ps = [5.0]

# how to make synthetic mtx
btm = false
ongrid = true
Tint = false
Wint = false

methods = ["WL1RR", "WNMF"]

datasetnames = [
            "arrhythmia","communities","HCCSurvivalDataSet",
            "heartdisease","lungcancer","MyocardialInfarctionComplications",
            "nomao", "secom", "wiki4HE", "LifeExpectancyData", "Autompg",
            "Bostonhousing","DailySunSpot","CaliforniaHousing","LifeExpectancyData",
            "HumanResourceAnalytics","YoungPeopleSurvey","CreditCardApproval","MTSLibrary",
            "MalaysiaCovid19","BigMartSaleForecast", "SleepData", "PerthHousePrice",
            "BoardGameGeekData"
            ]

datasets_dir = "../../../datasets/matrix/"
get_path(datasetname) = joinpath(datasets_dir, datasetname, datasetname*".jld2")
datasets_path = Dict( datasetname => get_path(datasetname) for datasetname in datasetnames )

###############
# plotconfigs #
###############

# fonts list : Helvetica, palatino, courier, times, newcentryschlbk, advantgrade
 fnt1 = font(20, "Helvetica")
 fnt2 = font(15, "Helvetica")
markershapes_dict = Dict("WL1RR" => :utriangle, "WNMF" => :circle)
linetype_dict = Dict("WL1RR" => :dot, "WNMF" => :dash)
linewidth = 5
img_size = (500,500)
markersize = 10
markerstrokewidth = 1
markercolor = :transparent
