

struct MappingROOTConfig{S<:AbstractString} <: AbstractROOTConfig
    path_to_data::S
    suffix::S
    treename::S
    branches::Vector{S}

    function MappingROOTConfig(
        path_to_data::S,
        suffix::S,
        treename::S,
        branches::Vector{S}
        ) where {S<:AbstractString}

        new{S}(path_to_data, suffix, treename, branches)
    end

end

struct MappingHist1DConfig <: AbstractHist1DConfig
    xvar::Symbol
    channels::Vector{Int}
    binedges::Union{Nothing, Vector{StepRange{Int, Int}}}
    cuts::Union{Nothing, Vector{<:Function}}
    xcuts::Union{Nothing, Vector{<:Function}}
    maxval::Union{Nothing, Vector{Int}}

    function MappingHist1DConfig(
        xvar::Symbol;
        channels::Union{Nothing, Vector{Int}}=nothing,
        binedges::Union{Nothing, Vector{StepRange{Int, Int}}}=nothing,
        cuts::Union{Nothing, Vector{Function}}=nothing,
        xcuts::Union{Nothing, Vector{Function}}=nothing,
        maxval::Union{Nothing, Vector{Int}}=nothing
        )

        new( xvar, channels, binedges, cuts, xcuts, maxval)
    end
end


struct MappingHist2DConfig <: AbstractHist2DConfig
    xvar::Symbol
    yvar::Symbol
    channels::Vector{Int}
    binedges::Union{Nothing, Vector{<:Tuple}}
    cuts::Union{Nothing, Vector{<:Function}}
    xcuts::Union{Nothing, Vector{<:Function}}
    maxval::Union{Nothing, Vector{Int}}

    function MappingHist2DConfig(
        xvar::Symbol,
        yvar::Symbol;
        channels::Union{Nothing, Vector{Int}}=nothing,
        binedges::Union{Nothing, Vector{<:Tuple}}=nothing,
        cuts::Union{Nothing, Vector{<:Function}}=nothing,
        xcuts::Union{Nothing, Vector{Function}}=nothing,
        maxval::Union{Nothing, Vector{Int}}=nothing
        )

        if !isnothing(binedges)
            @assert length(binedges) == length(channels)
        end

        if !isnothing(cuts)
            @assert length(cuts) == length(channels)
        end

        if !isnothing(xcuts)
            @assert length(xcuts) == length(channels)
        end

        new( xvar, yvar, channels, binedges, cuts, xcuts, maxval)
    end
end
