"""
This script is meant to be used to plot the fit result
of the mapping data. Bayesian posterior-predictive check
is performed together with credibility intervals and
best-fit line.
"""

using DrWatson
quickactivate(@__DIR__)

using CSV
using DataFrames

using FHist
using Dictionaries
using Calibrations
using Turing

using CairoMakie
# using GLMakie
# GLMakie.activate!()

using StatsBase

using JLD2

# regex patterns for filtering the filenames
ϕ_pattern = :ϕ => r"ϕ=(\d+)"
# arctheta_pattern = :ArcTheta => r"ArcTheta=(\d+)"
# channel_pattern = :Channel => r"channel=(\d+)"

regex_patterns = [ϕ_pattern]
# regex_patterns = [arctheta_pattern, longitude_pattern, channel_pattern]

filters = Dict(
    # :ArcTheta => x -> x > 0,
    :ϕ=> x -> x == 0,
    # :Channel => x -> x == 1
)

# # how filters should be combined
comb = d -> d[:ϕ]
# comb = d -> d[:ArcTheta] && d[:Longitude] && d[:Channel]

# filter filenames and sort them according to sort_by for facetting
# sort_by(str) = parse(Int, match(r"Longitude=(\d+)", str).captures[1])

path_to_fits = datadir("testdata/jld2/")

# filter the directory using regex
files = filterdir(
    path_to_fits;
    regex_patterns=regex_patterns,
    filters=filters,
    comb=comb,
    sort_by=nothing
)

# files = readdir(path_to_fits)


function ppc_quantiles(ppc_counts)

    ppc_counts_resh = reduce(hcat, ppc_counts)

    # Calculate 95% credible intervals for the predicted counts
    lower_bounds = [quantile(ppc_counts_resh[i, :], 0.025) for i in 1:size(ppc_counts_resh, 1)]

    upper_bounds = [quantile(ppc_counts_resh[i, :], 0.975) for i in 1:size(ppc_counts_resh, 1)]

    median_counts = [median(ppc_counts_resh[i, :]) for i in 1:size(ppc_counts_resh, 1)]

    return lower_bounds, upper_bounds, median_counts

end

msk = x -> x.mapentry.position[:ϕ] == 0
fig = Figure()
ga = fig[1,1] = GridLayout()
ax = Axis(ga[1,1])

# read files and plot the result.
# TODO: Make an interface for handling the readouts
# Currently you need to manually select which readout
# to be read and plotted from the file
jldopen(path_to_fits * files[1]) do f
    if msk(f["MappingRunFitResults"]) == true

        hist!(ax, f["MappingRunFitResults"].readouts[2].readout.fhist)

        ppc_counts = f["MappingRunFitResults"].readouts[2].ppc_counts
        lower_bounds, upper_bounds, median_counts = ppc_quantiles(ppc_counts)

        band!(
            ax,
            bincenters(f["MappingRunFitResults"].readouts[2].readout.fhist),
            lower_bounds,
            upper_bounds
        )

        lines!(
            ax,
            bincenters(f["MappingRunFitResults"].readouts[2].readout.fhist),
            median_counts
        )

    end
end

