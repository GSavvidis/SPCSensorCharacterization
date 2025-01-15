
struct MappingFacetConfig <: FacetConfig
    rowvar::Symbol
    colvar::Symbol
    reverse_rows::Bool
    reverse_cols::Bool
    figurekwargs::NamedTuple
    axiskwargs::NamedTuple

    function MappingFacetConfig(
        rowvar::Symbol,
        colvar::Symbol;
        reverse_rows::Bool=false,
        reverse_cols::Bool=false,
        figurekwargs::NamedTuple=NamedTuple(),
        axiskwargs::NamedTuple=NamedTuple(),
        )

        new(rowvar, colvar, reverse_rows, reverse_cols, figurekwargs, axiskwargs)

    end
end

# struct MappingCountsHeatmapConfig
#     xvar::Symbol
#     yvar::Symbol
#     reverse_x::Bool
#     reverse_y::Bool
#     reverse_xaxis::Bool
#     reverse_yaxis::Bool
#     figure_kwargs::NamedTuple
#     axis_kwargs::NamedTuple

#     function MappingCountsHeatmapConfig(
#         xvar::Symbol,
#         yvar::Symbol;
#         reverse_x::Bool=false,
#         reverse_y::Bool=false,
#         reverse_xaxis::Bool=false,
#         reverse_yaxis::Bool=false,
#         figure_kwargs::NamedTuple=NamedTuple(),
#         axis_kwargs::NamedTuple=NamedTuple()
#         )

#         new(xvar, yvar, reverse_x, reverse_y, reverse_xaxis, reverse_yaxis, figure_kwargs, axis_kwargs)
#     end
# end


struct HeatmapCountsExperimentConfig
    xvar::Symbol
    yvar::Symbol
    reverse_channels::Bool
    reverse_x::Bool
    reverse_y::Bool
    reverse_xaxis::Bool
    reverse_yaxis::Bool
    figure_kwargs::NamedTuple
    axis_kwargs::NamedTuple

    function HeatmapCountsExperimentConfig(
        xvar::Symbol,
        yvar::Symbol;
        reverse_channels::Bool=false,
        reverse_x::Bool=false,
        reverse_y::Bool=false,
        reverse_xaxis::Bool=false,
        reverse_yaxis::Bool=false,
        figure_kwargs::NamedTuple=NamedTuple(),
        axis_kwargs::NamedTuple=NamedTuple()
        )

        new(xvar, yvar, reverse_channels, reverse_x, reverse_y, reverse_xaxis, reverse_yaxis, figure_kwargs, axis_kwargs)
    end
end

# struct MappingLegendConfig
#     title::String
#     kwargs::Union{Nothing, NamedTuple}

#     function MappingLegendConfig(title::String; kwargs::Union{Nothing, NamedTuple}=nothing)
#         new(title, kwargs)
#     end
# end
