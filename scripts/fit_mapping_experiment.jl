
"""
This script is meant to be used to fit the mapping data
using Turing. The results are saved as .jld2 files in
the datadir.
"""

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


# setup logbook
df =  CSV.read(
    datadir("testdata/logbook/mapping5.csv"),
    DataFrame
)
DataFrames.rename!(df, "ArcTheta (cm)" => "ArcTheta")
# round theta angle
DataFrames.transform!(df, :Theta => ByRow( x-> round(Int,x)) => :Theta)

# convert to arc to angle
# logbook[!, :Theta] = @. round(Int, (logbook.ArcTheta / 15) * (180/π))

# mask and sort with respect to theta
mask = (df.Theta .< 100.0) .&& (df.Longitude .<= 1)

map_logbook = construct_logbook(
    df[mask, :],
    :Runname,
    (θ=:Theta, ϕ=:Phi, longitude=:Longitude, anode=:Anode)
)

# configurations
path_to_data = datadir("testdata/T2/")
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
xcuts_vec = nothing

# configuration for 1D histogram
hist1d_config = MappingHist1DConfig(
    :DD_RawAmpl,
    channels=[0, 1],
    binedges=[bin_edges[:DD_RawAmpl], bin_edges[:DD_RawAmpl], bin_edges[:DD_RawAmpl]];
    cuts=[cuts0, cuts1]
)


experiment = construct_experiment(map_logbook, hist1d_config, root_config)

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

# Fits the data. Result is saved as .jld2 file in the datadir
fit_experiment(experiment, histmodel, mcmcconfig; savedir=datadir("testdata/jld2/"))
