
using DrWatson
quickactivate(@__DIR__)

using CSV
using DataFrames

using UnROOT
using FHist
using Dictionaries

using GLMakie
GLMakie.activate!()

# setup logbook
logbook =  CSV.read(datadir("logbook/0.25mm_13anodes_bakelite/mapping/mapping5.csv"), DataFrame)
rename!(logbook, "ArcTheta (cm)" => "ArcTheta")

# mask and sort with respect to theta
mask = ((logbook.ArcTheta .== 23) .&& (logbook.Longitude .== 10))
# mask = ((logbook.ArcTheta .== 3) .|| (logbook.ArcTheta .== 43)) .&& (logbook.Longitude .== 11)
# logbook_inds = findall(x -> x == true, mask)

masked_logbook = logbook[mask, :]

# sort_var = :Theta
coord_i_var = :Longitude
coord_j_var = :ArcTheta

unique_coord_i_vals = unique(sort(masked_logbook[!, coord_i_var], rev=false))
unique_coord_j_vals = unique(sort(masked_logbook[!, coord_j_var]))

logbook_config = Dict(
    :logbook => masked_logbook,
    :coords_i => coord_i_var => unique_coord_i_vals,
    :coords_j => coord_j_var => unique_coord_j_vals
)

readfiles_config = Dict(
    :path_to_data => datadir("T2/0.25mm_13ball_bak/mapping5/"),
    :suffix => "_DD2_fixedstartend_q00.root",
    :runname_col => :Runname,
    :TDir => "T2",
    :branches => ["DD_RawAmpl", "DD_RawRise", "Channel"],
              )

# cuts
x_lower = 2_000
x_upper = 15_000
# channels = Dict(:Channel => [1])
cuts0 = x -> (x_lower .< x[:DD_RawAmpl] .< x_upper) .& (x[:Channel] .== 0)
cuts1 = x -> (x_lower .< x[:DD_RawAmpl] .< x_upper) .& (x[:Channel] .== 1)
cuts = [0 => cuts0, 1 => cuts1]
xcuts = [0 => nothing, 1 => nothing]

bin_edges = Dictionary(Dict(:DD_RawAmpl => x_lower:200:x_upper,
                                                    :DD_RawRise => 0:1:50,
                                                    :DD_RawWidth => 0:2:200,
                                                    :TimeS => lz -> 0:2:lz[end, :TimeS][1])
                       )

fhist_config = Dict(
    :x => :DD_RawAmpl,
    # :channels => channels_dict,
    :cuts => cuts,
    :xcuts => xcuts,
    :binedges => bin_edges[:DD_RawAmpl],
    :stop => nothing
)

# filename = masked_logbook.Runname[1] * "_DD2_fixedstartend_q00.root"
# ttree = ROOTFile(datadir("T2/0.25mm_13ball_bak/mapping5/" * filename))
filename = "yk05f000" * "_DD2_fixedstartend_q00.root"
ttree = ROOTFile(datadir("T2/0.25mm_13ball_bak/share_effect/" * filename))
branches = ["DD_RawAmpl", "Channel", "DD_RawRise", "TimeS", "TimeMuS"]
lz_tree = LazyTree(ttree, "T2", branches)


# frames = 1:size(lz_tree)[1]
# frames = 1:500
frames = 1:10_000

# points = Observable(Point2f[(0, 0)])

# fig, ax = scatter(points)
# limits!(ax, 0, 30, 0, 30)

# frames = 1:30

# record(fig, "append_animation.mp4", frames;
#         framerate = 30) do frame
#     new_point = Point2f(frame, frame)
#     points[] = push!(points[], new_point)
# end

# points = Observable(Point2f[(0, 0)])

function record_hist()

    p0 = Observable([0.0])
    p1 = Observable([0.0])
    fig, ax, h = hist(p0, bins=bin_edges[:DD_RawAmpl])
    hist!(p1, bins=bin_edges[:DD_RawAmpl])

    # b = 80
    limits!(ax, 2_000, 15_000, 0, 80)

    record(fig, "test2.mp4", frames;
           framerate=200) do frame
               # @show b

               # ev_mask = lz_tree[frame][:Channel] .== 1
               ev_mask0 = cuts0(lz_tree[frame])
               ev_mask1 = cuts1(lz_tree[frame])

               if (frame % 6_000) == 0
                   ymax = ax.yaxis.attributes.limits.val[2] + 80
                   # b = 80 + b
                   limits!(ax, 2_000, 15_000, 0, ymax)
                end

               if any(ev_mask0)
                   x = lz_tree[frame][:DD_RawAmpl][ev_mask0][1]
                   # h.color = RGBf(0.1, 0.2, 0.8)
                   new_point = x
                   p0[] = push!(p0[], new_point)
               end

               if any(ev_mask1)
                   x = lz_tree[frame][:DD_RawAmpl][ev_mask1][1]
                   # h.color = RGBf(0.5, 0.2, 0.8)
                   new_point = x
                   p1[] = push!(p1[], new_point)
               end

    end

end


function record_heatmap()

    h0 = Hist2D(; binedges=(1_000:200:15_000, 0:1:60))
    h1 = Hist2D(; binedges=(1_000:200:15_000, 0:1:60))
    # h2 = Hist2D(; binedges=(0:0.1:20, 0:1:60))

    fig = Figure()
    ga = fig[1,1] = GridLayout()

    ax0 = Axis(ga[1,1], xlabel = "Raw Amplitude [ADU]", ylabel="Time [s]", title = "Channel 0 [North]")
    ax1 = Axis(ga[1,2], xlabel = "Raw Amplitude [ADU]", ylabel="Time [s]", title= "Channel 1 [South]")

    heatmap!(ax0, h0)
    heatmap!(ax1, h1)


    # fig, ax, hm = heatmap(h2,
    #                       axis=(title="Raw Risetime vs Time [Channel 0]",
    #                             xlabel="Raw Risetime [μs]",
    #                             ylabel="Time [s]",)
    #                       )

    # fig, ax, hm = heatmap(h2,
    #                       axis=(title="Raw Risetime vs Time [Channel 0]",
    #                             xlabel="Raw Risetime [μs]",
    #                             ylabel="Time [s]",)
    #                       )

    # Label(fig[0, 1], "Raw Amplitude vs Time [Channel 0]")
    # Label(fig[2, 1], "Raw Amplitude [ADU]")
    # Label(fig[1, 0], "Time [s]")

   # b = 80
   limits!(ax0, 1_000, 15_000, 0, 10)
   limits!(ax1, 1_000, 15_000, 0, 10)
   # limits!(ax, 1_000, 15_000, 0, 10)
   # limits!(ax, 0, 20, 0, 10)

    println("Recording heatmap")
    record(fig, "share_effect_Amplitude_2.mp4", frames;
           framerate=130) do frame

               # ev_mask = lz_tree[frame][:Channel] .== 1
               ev_mask0 = cuts0(lz_tree[frame])
               ev_mask1 = cuts1(lz_tree[frame])

               # 5_000 events => 60 seconds
               # update limits every 10 seconds
               if (frame % 750) == 0
                   println("Frame $frame")
                   # ymax = ax.yaxis.attributes.limits.val[2] + 10

                   ymax = ax0.yaxis.attributes.limits.val[2] + 10
                   limits!(ax0, 1_000, 15_000, 0, ymax)
                   limits!(ax1, 1_000, 15_000, 0, ymax)
                   # limits!(ax, 0, 20, 0, ymax)
                   # resize_to_layout!(fig)
                end

               if any(ev_mask0)
                   x = lz_tree[frame][:DD_RawAmpl][ev_mask0][1]
                   # x = lz_tree[frame][:DD_RawAmpl][1]
                   # x = lz_tree[frame][:DD_RawRise][1]
                   y = lz_tree[frame][:TimeS][ev_mask0][1] + lz_tree[frame][:TimeMuS][ev_mask0][1]*1e-6
                   atomic_push!(h0, x, y)
                   heatmap!(ax0, h0)
                   # autolimits!(ax)

               end

               if any(ev_mask1)
                   x = lz_tree[frame][:DD_RawAmpl][ev_mask1][1]
                   # x = lz_tree[frame][:DD_RawAmpl][1]
                   # x = lz_tree[frame][:DD_RawRise][1]
                   y = lz_tree[frame][:TimeS][ev_mask1][1] + lz_tree[frame][:TimeMuS][ev_mask1][1]*1e-6
                   atomic_push!(h1, x, y)
                   heatmap!(ax1, h1)
                   # autolimits!(ax)

               end

    end

end

function record_scatter()

    # h0 = Hist2D(; binedges=(1_000:200:15_000, 0:1:60))
    # h1 = Hist2D(; binedges=(1_000:200:15_000, 0:1:60))
    # h2 = Hist2D(; binedges=(0:0.1:20, 0:1:60))

    fig = Figure()
    ga = fig[1,1] = GridLayout()

    ax0 = Axis(ga[1,1], xlabel = "Raw Amplitude [ADU]", ylabel="Time [s]", title = "Channel 0 [North]")
    ax1 = Axis(ga[1,2], xlabel = "Raw Amplitude [ADU]", ylabel="Time [s]", title= "Channel 1 [South]")

    p0 = Observable(Point2f[(0.0, 0.0)])
    p1 = Observable(Point2f[(0.0, 0.0)])

    scatter!(ax0, p0)
    scatter!(ax1, p1)

   limits!(ax0, 1_000, 15_000, 0, 10)
   limits!(ax1, 1_000, 15_000, 0, 10)

    println("Recording scatter")
    record(fig, "share_effect_Amplitude_scatter.mp4", frames;
           framerate=130) do frame


               # ev_mask = lz_tree[frame][:Channel] .== 1
               ev_mask0 = cuts0(lz_tree[frame])
               ev_mask1 = cuts1(lz_tree[frame])

               # 5_000 events => 60 seconds
               # update limits every 10 seconds
               if (frame % 750) == 0
                   println("Frame $frame")
                   # ymax = ax.yaxis.attributes.limits.val[2] + 10

                   ymax = ax0.yaxis.attributes.limits.val[2] + 10
                   limits!(ax0, 1_000, 15_000, 0, ymax)
                   limits!(ax1, 1_000, 15_000, 0, ymax)
                   # limits!(ax, 0, 20, 0, ymax)
                   # resize_to_layout!(fig)
                end

               if any(ev_mask0)
                   x = lz_tree[frame][:DD_RawAmpl][ev_mask0][1]
                   # x = lz_tree[frame][:DD_RawAmpl][1]
                   # x = lz_tree[frame][:DD_RawRise][1]
                   y = lz_tree[frame][:TimeS][ev_mask0][1] + lz_tree[frame][:TimeMuS][ev_mask0][1]*1e-6

                   new_p0 = Point2f(x, y)
                   p0[] = push!(p0[], new_p0)

               end

               if any(ev_mask1)
                   x = lz_tree[frame][:DD_RawAmpl][ev_mask1][1]
                   # x = lz_tree[frame][:DD_RawAmpl][1]
                   # x = lz_tree[frame][:DD_RawRise][1]
                   y = lz_tree[frame][:TimeS][ev_mask1][1] + lz_tree[frame][:TimeMuS][ev_mask1][1]*1e-6

                   new_p1 = Point2f(x, y)
                   p1[] = push!(p1[], new_p1)

               end

    end

end

record_scatter()
record_heatmap()

