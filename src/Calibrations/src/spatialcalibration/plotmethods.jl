
"""
Plots a 1D histogram for the given readout
"""
function plot_readout(r::Readout)

    fig = Figure()
    ax = Axis(fig[1,1])

    if typeof(r.fhist) <: Hist1D
        hist!(ax, r.fhist)

        return fig, ax
    end

end

"""
    plot_run(r::MappingRun; overlay::Bool=true)

Plots a 1D histogram of the given run.
If `overlay` is `true, the run's readouts
are overlayed on the same plot and a `Figure` with
an `Axis` objects are returned. Otherwise, they
are plotted on separate plots and a `Figure` with a
vector of `Axis` are returned.

# Arguments

- `r::MappingRun`: the run to be plotted
- `overlay::Bool=true`: option to plot histograms
  on the same axis if `true`. Otherwise plots histograms
  on separate axes creating as many plots as the number
  of channels of the given run
"""
function plot_run(r::MappingRun; overlay::Bool=true)

    fig = Figure()

    # overlay channels on the same axis
    if overlay == true
        ax = Axis(fig[1,1])

        # loop through each readout channel
        for i in eachindex(r.readouts)

            if typeof(r.readouts[i].fhist) <: Hist1D
                hist!(ax, r.readouts[i].fhist, label="$i")
            end

        end # for loop


        return fig, ax

    else
        axes = Vector{Axis}(undef, length(r.readouts))
        # loop through each readout channel
        for i in eachindex(r.readouts)
            axes[i] = Axis(fig[1,i])

            if typeof(r.readouts[i].fhist) <: Hist1D
                hist!(axes[i], r.readouts[i].fhist, label="$i")
            end

        end # for loop


        return fig, axes

    end # overlay

end


function plot_run!(ax::Axis, r::MappingRun; overlay::Bool=true)

    # overlay channels on the same axis
    if overlay == true
        # ax = Axis(fig[1,1])

        # loop through each readout channel
        for i in eachindex(r.readouts)

            if typeof(r.readouts[i].fhist) <: Hist1D
                hist!(ax, r.readouts[i].fhist, label="$i")

            elseif typeof(r.readouts[i].fhist) <: Hist2D
                heatmap!(ax, r.readouts[i].fhist, label="$i")
            end

        end # for loop

        # return ax

    # else
    #     axes = Vector{Axis}(undef, length(r.readouts))
    #     # loop through each readout channel
    #     for i in eachindex(r.readouts)
    #         axes[i] = Axis(fig[1,i])

    #         if typeof(r.readouts[i].fhist) <: Hist1D
    #             hist!(axes[i], r.readouts[i].fhist, label="$i")
    #         end

        # end # for loop


        # return fig, axes

    end # overlay

end

"""
    construct_facet(e::MappingExperiment, facet_config::MappingFacetConfig;)

Construct a facet for the `MappingExperiment`.
Returns a type of `MappingFacet`.
"""
function construct_facet(e::MappingExperiment, facet_config::MappingFacetConfig;)

    fig = Figure(facet_config.figurekwargs...)
    ga = fig[1,1] = GridLayout()

    # get the source positions from the logbook
    positions = get_positions(e)

    rowvar = facet_config.rowvar
    colvar = facet_config.colvar

    unique_rows = sort(unique([positions[i][rowvar] for i in eachindex(positions)]), rev=facet_config.reverse_rows)
    unique_cols = sort(unique([positions[i][colvar] for i in eachindex(positions)]), rev=facet_config.reverse_cols)

    # axes = Array{Axis}(undef, (length(unique_rows), length(unique_cols)))
    axes = []

    for i in eachindex(unique_rows)
        # temp vector to hold all axes of the i-th row
        axes_i = []
        for j in eachindex(unique_cols)

            mask = map(x -> x[rowvar] == unique_rows[i] && x[colvar] == unique_cols[j], positions)

            if any(mask)
                # make sure there is a single run for each i,j
                @assert length(findall(mask)) == 1

                # get corresponding run
                run_ij = e.runs[mask][1]

                # construct the i-th, j-th axis, plot and store it
                ax = Axis(ga[i,j]; facet_config.axiskwargs...)
                plot_run!(ax, run_ij)
                push!(axes_i, ax)

            end # if

        end # for j

        # store axes
        push!(axes, axes_i)

    end # for i

    resize_to_layout!(fig)

    facet = MappingFacet(fig, ga, axes, rowvar, colvar, unique_rows, unique_cols)

    return facet

end

"""
    add_facet_labels!(
        facet::MappingFacet;
        xlabel::String="",
        ylabel::String="",
        title::String="",
        rowlabels_config::NamedTuple=NamedTuple(),
        collabels_config::NamedTuple=NamedTuple(),
        xlabel_config::NamedTuple=NamedTuple(),
        ylabel_config::NamedTuple=NamedTuple(),
        title_config::NamedTuple=NamedTuple()
        )

Function to add labels on an existing facet.

# Arguments

- `facet::MappingFacet`: The facet
- `xlabel::String=""`: The facet's xlabel
- `ylabel::String=""`: The facet's ylabel
- `title::String=""`: The facet's title
- `rowlabels_config::NamedTuple=NamedTuple()`: The
  keyword arguments for the configuration of the facet's
  row labels
- `collabels_config::NamedTuple=NamedTuple()`: The
  keyword arguments for the configuration of the facet's
  col labels
- `xlabel_config::NamedTuple=NamedTuple()`: The
  keyword arguments for the configuration of the facet's
  xlabels
- `ylabel_config::NamedTuple=NamedTuple()`: The
  keyword arguments for the configuration of the facet's
  ylabels
- `title_config::NamedTuple=NamedTuple()`: The
  keyword arguments for the configuration of the facet's
  title
"""
function add_facet_labels!(
    facet::MappingFacet;
    xlabel::String="",
    ylabel::String="",
    title::String="",
    rowlabels_config::NamedTuple=NamedTuple(),
    collabels_config::NamedTuple=NamedTuple(),
    xlabel_config::NamedTuple=NamedTuple(),
    ylabel_config::NamedTuple=NamedTuple(),
    title_config::NamedTuple=NamedTuple()
    )

    ncols = length(facet.colvals)

    # row labels
    for i in eachindex(facet.rowvals)
        Label(facet.grid[i, ncols + 1], "$(facet.rowvar)=$(facet.rowvals[i])"; rowlabels_config...)
    end

    # col labels
    for j in eachindex(facet.colvals)
        Label(facet.grid[0, j], "$(facet.colvar)=$(facet.colvals[j])"; collabels_config...)
    end

    resize_to_layout!(facet.fig)

    # add x label at the bottom
    last_row = size(facet.grid)[1]
    Label(facet.grid[last_row, 1:end], xlabel; xlabel_config...)

    # add y label at the left
    Label(facet.grid[1:end, 0], ylabel; ylabel_config...)

    # add super title
    Label(facet.grid[-1, 1:end], title; title_config...)

    resize_to_layout!(facet.fig)
end

"""
    add_facet_legend!(
        facet::MappingFacet,
        title::String,
        legend_config::NamedTuple=NamedTuple();
        legend_position=:right
        )

Add legend corresponding to the
readout, on an existing mapping facet.

# Arguments

- `facet::MappingFacet`: The facet
- `title::String`: The title of the legend
- `legend_config::NamedTuple=NamedTuple()`: The
  keyword arguments for the configuration of the
  facet's legend
- `legend_position=:right`: The position of the
  legend
"""
function add_facet_legend!(
    facet::MappingFacet,
    title::String,
    legend_config::NamedTuple=NamedTuple();
    legend_position=:right
    )

    if legend_position == :right
        j = size(facet.fig.layout)[2]
        Legend(facet.fig[1, j+1], facet.axes[1][1], title; legend_config...)
    end

end

"""
    construct_experiment_counts_heatmap(
        e::MappingExperiment,
        config::HeatmapCountsExperimentConfig
        )

This function is designed specifically
for 3-channel data. Creates the heatmap
of counts from `MappingExperiment`'s runs.
It returns a plot object of type
`HeatmapPlotExperiment`.
"""
function construct_experiment_counts_heatmap(
    e::MappingExperiment,
    config::HeatmapCountsExperimentConfig
    )

    # get the source positions from the logbook
    positions = get_positions(e)

    xvar = config.xvar
    yvar = config.yvar

    # must be sorted in order to have regular grid
    unique_xvals = sort(unique([positions[i][xvar] for i in eachindex(positions)]), rev=config.reverse_x)
    unique_yvals = sort(unique([positions[i][yvar] for i in eachindex(positions)]), rev=config.reverse_y)

    # vector to store the heatmap data
    hms = Vector{CountsHeatmapExperiment}(undef, length(e.channels))

    # loop through the channels
    for k in eachindex(e.channels)

        zcounts =  missings(Int, length(unique_xvals), length(unique_yvals))

        for i in eachindex(unique_xvals)
            for j in eachindex(unique_yvals)

                # look in positions if the i-th, j-th run exists
                mask = map(x -> x[xvar] == unique_xvals[i] && x[yvar] == unique_yvals[j], positions)

                if any(mask)

                    # make sure there is a single run for each i,j
                    @assert length(findall(mask)) == 1

                    # get corresponding run
                    run_ij = e.runs[mask][1]

                    # double-check the channel
                    @assert e.channels[k] == run_ij.readouts[k].channel

                    # sum of counts for the k-th channel for the i-th, j-th run
                    Σcounts = sum(bincounts(run_ij.readouts[k].fhist))

                    # store the sum in the heatmap matrix
                    zcounts[i,j] = Int.(Σcounts)

                end # if

            end # for j

        end # for i

    hms[k] = CountsHeatmapExperiment(e.channels[k], xvar, yvar, unique_xvals, unique_yvals, zcounts)

    end # for k

    fig = Figure(config.figure_kwargs...)
    ga = fig[1,1] = GridLayout()

    if config.reverse_channels == true

        for k in reverse(eachindex(e.channels))
            @assert e.channels[k] == hms[k].channel

            j = length(e.channels) - k + 1
            heatmap!(
                Axis(ga[1, j];
                     xlabel="$(hms[k].xvar)",
                     ylabel="$(hms[k].yvar)",
                     title="Channel = $(e.channels[k])",
                     config.axis_kwargs...),
                hms[k].xs,
                hms[k].ys,
                hms[k].zcounts
            )
        end

    else

        for k in eachindex(e.channels)
                @assert e.channels[k] == hms[k].channel

                heatmap!(
                    Axis(ga[1, k];
                         xlabel="$(hms[k].xvar)",
                         ylabel="$(hms[k].yvar)",
                         title="Channel = $(e.channels[k])"),
                    hms[k].xs,
                    hms[k].ys,
                    hms[k].zcounts
                )
        end

    end

    Label(ga[0, 1:end], "Counts Heatmap"; fontsize=30)

    resize_to_layout!(fig)

    hm_experiment = HeatmapPlotExperiment(fig, ga, hms)

    return hm_experiment

end

