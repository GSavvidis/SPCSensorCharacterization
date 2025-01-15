
"""
Information of a single logbook entry
"""
struct MapEntry <: AbstractEntry
    entryindex::Int
    runname::String
    position::NamedTuple

    function MapEntry(
        entryindex::Int,
        runname::String,
        position::NamedTuple;
        )

        new(entryindex, runname, position)
    end
end

# TODO: Change ::Vector{AbstractEntry} to ::Vector{MapEntry}
"""
The collection of entries which constitude the logbook
"""
struct MapLogbook <: AbstractLogbook
    entries::Vector{AbstractEntry}
end

"""
Holds an abstract histogram for a sensor readout channel.
"""
struct Readout{H<:FHist.AbstractHistogram} <: AbstractReadout
    channel::Int
    fhist::H
end

"""
Holds abstract histograms for each sensor readout channel
"""
struct MappingRun <: AbstractRun
    readouts::Vector{Readout}
end

"""
Holds abstract histograms for each run for each sensor readout
"""
struct MappingExperiment{L<:AbstractLogbook} <: AbstractExperiment
    vars::NamedTuple
    logbook::L
    runs::Vector{MappingRun}
    channels::Vector{Int}

    function MappingExperiment(
        vars::NamedTuple,
        logbook::L,
        runs::Vector{MappingRun},
        channels::Vector{Int}
        ) where {L<:AbstractLogbook}

        @assert length(logbook.entries) == length(runs)

        new{L}(vars, logbook, runs, channels)
    end
end

struct CountsHeatmapExperiment <: HeatmapExperiment
    channel::Int
    xvar::Symbol
    yvar::Symbol
    xs::Vector
    ys::Vector
    zcounts::Matrix
end


"""
Loop throuh the experiment's logbook and get
the positions of the source for each run.
"""
function get_positions(e::MappingExperiment)
    # vector to store positions
    positions = Vector{NamedTuple}(undef, length(e.logbook.entries))

    for i in eachindex(e.logbook.entries)
        positions[i] = e.logbook.entries[i].position
    end

    return positions
end
