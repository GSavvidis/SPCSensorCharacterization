
using DrWatson
quickactivate(@__DIR__)

using CSV
using DataFrames

using UnROOT
using FHist
using Dictionaries

using Calibrations

using CairoMakie

using Turing

# using JLD2

# setup logbook
df =  CSV.read(datadir("logbook/0.25mm_13anodes_bakelite/mapping/3channels/mapping6.csv"), DataFrame)
DataFrames.rename!(df, "ArcTheta (cm)" => "ArcTheta")
# round theta angle
DataFrames.transform!(df, :Theta => ByRow( x-> round(Int,x)) => :Theta)

# convert to arc to angle
# logbook[!, :Theta] = @. round(Int, (logbook.ArcTheta / 15) * (180/π))

# mask and sort with respect to theta
mask = (df.Theta .< 100.0) .&& (df.Longitude .<= 2324)
# logbook_inds = findall(x -> x == true, mask)

map_logbook = construct_logbook(df[mask, :])

# configurations
path_to_data = datadir("T2/0.25mm_13ball_bak/mapping6/")
suffix = "_DD2_fixedstartend_q00.root"
treename = "T2"
branches = ["DD_RawAmpl", "DD_RawRise", "Channel", "TimeS", "DD_RawWidth"]
root_config = MappingROOTConfig(path_to_data, suffix, treename, branches)

# bin edges for histograms
x_lower = 1_000
x_upper = 15_000
bin_edges = Dictionary(Dict(:DD_RawAmpl => x_lower:200:x_upper,
                                                    :DD_RawRise => 0:1:50,
                                                    :DD_RawWidth => 0:2:200,
                                                    :TimeS => lz -> 0:2:lz[end, :TimeS][1])
                       )

# cuts
cuts0 = x -> (x_lower .< x[:DD_RawAmpl] .< x_upper) .&& x[:Channel] .== 0
cuts1 = x -> (x_lower .< x[:DD_RawAmpl] .< x_upper) .&& x[:Channel] .== 1
cuts2 = x -> (x_lower .< x[:DD_RawAmpl] .< x_upper) .&& x[:Channel] .== 2
xcuts_vec = nothing

# configuration for 1D histogram
hist1d_config = MappingHist1DConfig(
    :DD_RawAmpl,
    channels=[0, 1, 2],
    binedges=[bin_edges[:DD_RawAmpl], bin_edges[:DD_RawAmpl], bin_edges[:DD_RawAmpl]];
    cuts=[cuts0, cuts1, cuts2]
)


experiment = construct_experiment(map_logbook, hist1d_config, root_config)

# cf = let
#     function config(event::UnROOT.LazyEvent)
#         mask0 = event[:DD_RawAmpl] .< 5_000 .&& event[:Channel] .== 0
#         mask1 = event[:DD_RawAmpl] .< 5_000 .&& event[:Channel] .== 1

#         if any(mask0) .&& any(mask1)
#             var = event[:DD_RawAmpl][mask0] / event[:DD_RawAmpl][mask1]
#             return var
#         end
#     end

# end

# model configuration
histmodel = HistModelConfig(
    :mixture_model,
    mixture_model,
    (μ=6_000, σ=3_000, α=0.7, β=0.3,)
)

# MCMC configuration
mcmcconfig = MCMCConfig(
    NUTS(),
    MCMCThreads(),
    2_000,
    2,
    samplekwargs=(discard_initial=50,)
)

#
fit_experiment(experiment, histmodel, mcmcconfig)


# var = event -> event[:DD_RawAmpl][submask0(event)] + event[:DD_RawAmpl][submask1(event)]

# histconf = Hist2DConfig((0:1:100))

# h = construct_hist(lzconfs[1], histconf, config)

# cuts = event -> ((x_lower .< event[:DD_RawAmpl] .< x_upper) .&&
#     event[:Channel] .== 0) .||
#     (event[:DD_RawAmpl] .> 0 .&& event[:Channel] .== 1)
