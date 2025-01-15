
"""
This script is meant to be used to look at the data,
perform cuts and visualize. For now, this script
provides an interface to look at multiple data,
more specifically to mapping data (spatial calibration)
A facet plot is created with the rows and columns of the
facet corresponding to a 1D histogram.
"""
using DrWatson
quickactivate(@__DIR__)

using CSV
using DataFrames

using UnROOT
using FHist
using Dictionaries

using Calibrations
# using AnalysisUtils

using CairoMakie

# using JLD2

# setup logbook
df =  CSV.read(datadir("logbook/0.25mm_13anodes_bakelite/mapping/3channels/mapping7_updated.csv"), DataFrame)
rename!(df, "ArcTheta (cm)" => "ArcTheta")

# round theta angle
transform!(df, :Theta => ByRow( x-> round(Int,x)) => :Theta)

# convert to arc to angle
# logbook[!, :Theta] = @. round(Int, (logbook.ArcTheta / 15) * (180/π))

# mask and sort with respect to theta
mask = (df.Theta .> 0.0) .&& (df.Longitude .<= 2324)
# mask = (34 .<= df.Theta .< 92.0) .&& (df.Longitude .<= 2324)
# logbook_inds = findall(x -> x == true, mask)

map_logbook = construct_logbook(
    df[mask, :],
    :Runname,
    (θ=:Theta, ϕ=:Phi3, longitude=:Longitude, anode=:Anode)
)

# configurations
path_to_data = datadir("T2/0.25mm_13ball_bak/mapping7/")
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
cuts0 = x ->
    (x_lower .< x[:DD_RawAmpl] .< x_upper) .&&
    x[:DD_RawRise] .> 5 .&&
    x[:Channel] .== 0

cuts1 = x ->
    (x_lower .< x[:DD_RawAmpl] .< x_upper) .&&
    x[:DD_RawRise] .> 5 .&&
    x[:Channel] .== 1

cuts2 = x ->
    (x_lower .< x[:DD_RawAmpl] .< x_upper) .&&
    x[:DD_RawRise] .> 5 .&&
    x[:Channel] .== 2

xcuts_vec = nothing

# configuration for 1D histogram
hist1d_config = MappingHist1DConfig(
    :DD_RawAmpl,
    channels=[0, 1, 2],
    binedges=[bin_edges[:DD_RawAmpl], bin_edges[:DD_RawAmpl], bin_edges[:DD_RawAmpl]];
    cuts=[cuts0, cuts1, cuts2]
)

experiment = construct_experiment(map_logbook, hist1d_config, root_config)

# create the facet for the mapping data
facet_config = MappingFacetConfig(
    :θ,
    :ϕ;
    reverse_rows=true,
    reverse_cols=false,
    axiskwargs=(
        xticklabelsize=15,
        yticklabelsize=15,
        xticklabelrotation=π/8,
        tellheight=true,
        tellwidth=true,
        height=200,
        width=200
    )
)

println("constructing facet")
facet = construct_facet(experiment, facet_config)


println("adding labels to facet")
add_facet_labels!(
    facet;
    xlabel="Raw amplitude [ADU]",
    ylabel="Raw rise-time [μs]",
    title="Channel 0",
    rowlabels_config=(fontsize=60, rotation=-π/2,),
    collabels_config=(fontsize=60,),
    xlabel_config=(rotation=0, fontsize=70,),
    ylabel_config=(rotation=π/2, fontsize=70,),
    title_config=(rotation=0, fontsize=80,),
)

# println("adding legend to facet")
# add_facet_legend!(facet, "Channel", (labelsize=40, titlesize=30, markersize=30,))
#
# Legend(facet.fig[1,2], facet.axes[1,1], "Channel")
resize_to_layout!(facet.fig)
