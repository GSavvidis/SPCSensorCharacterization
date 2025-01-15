using DrWatson
quickactivate(@__DIR__)

using CSV
using DataFrames

# using UnROOT
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

path_to_fits = datadir("jld2/0.25mm_13ball_bak/mapping_fits/mapping6/")

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

# read files and plot the result
jldopen(path_to_fits * files[1]) do f
    if msk(f["MappingRunFitResults"]) == true

        hist!(ax, f["MappingRunFitResults"].readouts[1].readout.fhist)

        ppc_counts = f["MappingRunFitResults"].readouts[1].ppc_counts
        lower_bounds, upper_bounds, median_counts = ppc_quantiles(ppc_counts)

        band!(
            ax,
            bincenters(f["MappingRunFitResults"].readouts[1].readout.fhist),
            lower_bounds,
            upper_bounds
        )

        lines!(
            ax,
            bincenters(f["MappingRunFitResults"].readouts[1].readout.fhist),
            median_counts
        )

    end
end

# #
# regex_i = r"Longitude=(\d+)"
# regex_j = r"ArcTheta=(\d+)"

# get uniques for facetting
unique_coords_i = "Longitude" => sort(get_uniques(full_filenames, "Longitude"))
unique_coords_j = "ArcTheta" => sort(get_uniques(full_filenames, "ArcTheta"))

# fig3 = Figure(size=(800,600))
fig3 = Figure()
gb = fig3[1,1] = GridLayout()

# model's parameter vs ϕ, θ
for i in eachindex(unique_coords_i.second)
    coord_i = unique_coords_i.second[i]

    ax = Axis(
        gb[i,1],
        # azimuth=-0.2 * π,
        # xlabel="Longitude",
        # ylabel="ArcTheta",
        # zlabel="std σ",
        # viewmode=:fitzoom,
        # tellheight=true,
        # tellwidth=true,
        height=100,
        # width=300
        )

    # points = []
    x = []
    y = []
    z = []
    stdz = []

    for j in eachindex(unique_coords_j.second)
        coord_j = unique_coords_j.second[j]


        for k in eachindex(full_filenames)
            jldopen(full_filenames[k], "r") do f

                if f[unique_coords_i.first] == coord_i && f[unique_coords_j.first] == coord_j
                    # push!(points, Point3f(coord_i,coord_j,mean(f["chain"][2][:σ])))

                    xi = coord_i
                    yi = coord_j ./ 15 .* 180/π
                    # yi = coord_j
                    zi = mean(f["chain"][2][:μ])
                    stdzi = std(f["chain"][2][:μ])

                    # push!(points, Point2f(xi, yi))
                    push!(x, xi)
                    push!(y, yi)
                    push!(z, zi)
                    push!(stdz, stdzi)

                    # for errorbars in 3D plot
                    # lines!(ax3d, [xi, xi], [yi, yi], [zi - stdzi, zi + stdzi])

                end
            end

        end

    end

    scatterlines!(ax, y, z)
    errorbars!(ax, y, z, stdz, color=convert.(Int, x), whiskerwidth=5)

    resize_to_layout!(fig3)
end

# add labels on fig3
for k in eachindex(unique_coords_i.second)

    row_val = unique_coords_i.second[k]
    Label(gb[k, 2], "$(unique_coords_i.first) = $row_val", rotation = -π/2, tellheight = false, fontsize=18)
    # vlines!(axes[i][j], 10_000)
end
Label(gb[length(unique_coords_i.second)+1, 1], "Theta", rotation = 0, tellheight = false, fontsize=18, tellwidth=false)
Label(gb[1:end, 0], "Mean Amplitude [ADU]", rotation = π/2, tellheight = false, fontsize=18, tellwidth=true)

resize_to_layout!(fig3)
stop
