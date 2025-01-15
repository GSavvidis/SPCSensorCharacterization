
"""
    construct_logbook(df::DataFrame, colrunname::Symbol, coordinates::NamedTuple)

Returns the logbook of type `MapLogbook` based on
the dataframe `df`.

# Arguments

- `df`: the `DataFrame` holding the experiment's information
- `colrunname::Symbol`: the name of the column in `df`
  containing the runnames
- `coordinates::NamedTuple`: the coordinates of the source's
  position. The names of the keys are selected by the user. The
  names of the values must coincide with the names of the coordinates
  in the `df`

# Example

```jldoctest
julia> df =  CSV.read(datadir("logbook/0.25mm_13anodes_bakelite/mapping/mapping5.csv"), DataFrame, limit=5)
5×13 DataFrame
 Row │ Runname   ArcTheta (cm)  Gas       Pressure (bar)  HV0 (V)  HV1 (V)  Longitude  Anode    Phi    Theta    Nanodes  Comments  ArcThetaErr (cm)
     │ String15  Int64          String15  Int64           Int64    Int64    Int64      String3  Int64  Float64  Int64    String1   Float64
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ yj29f018              3  Ar+2%CH4               1     1150     1150          1  S1           0  11.465        13  -                      0.5
   2 │ yj29f019              4  Ar+2%CH4               1     1150     1150          1  S1           0  15.2866       13  -                      0.5
   3 │ yj29f020              5  Ar+2%CH4               1     1150     1150          1  S1           0  19.1083       13  -                      0.5
   4 │ yj29f021              6  Ar+2%CH4               1     1150     1150          1  S1           0  22.9299       13  -                      0.5
   5 │ yj29f022              7  Ar+2%CH4               1     1150     1150          1  S1           0  26.7516       13  -                      0.5

julia> logbook = construct_logbook(df, :Runname, (θ=:Theta, ϕ=:Phi, longitude=:Longitude,))
```
"""
function construct_logbook(df::DataFrame, colrunname::Symbol, coordinates::NamedTuple)

    entries = Vector{MapEntry}(undef, nrow(df))

    # for i in eachindex(nrow(logbook))
    for i in 1:nrow(df)

        # convert from String15 to String
        runname = String(df[i, colrunname])

        # get source position from the logbook
        coord_names = []
        coord_vals = []

        for (k,v) in zip(keys(coordinates), coordinates)

            coord_val = df[i, v]

            push!(coord_names, k)
            push!(coord_vals, coord_val)

        end

        # position must be NamedTuple
        coord_names = Tuple(x for x in coord_names)
        position = NamedTuple{coord_names}(coord_vals)

        entryindex = i
        entries[i] = MapEntry(entryindex, runname, position)

    end

    logbook = MapLogbook(entries)

    return logbook

end

# """
# Construct hist of arbitrary variable
# """
# function construct_hist(
#     lzconf::LazyTreeConfig,
#     histconf::Hist1DConfig,
#     config::Function)

#     # unpack hist parameters
#     binedges = histconf.binedges

#     # get lazy tree
#     lz_tree = get_lazytree(lzconf)

#     # create histogram
#     h = Hist1D(;binedges=binedges)

#     # loop through the events
#     for i in eachindex(lz_tree)

#         event = lz_tree[i]
#         var = config(event)

#         if !isnothing(var)
#             atomic_push!(h, var[1])
#         end

#     end

#     return h

# end

# TODO: Decide whether to change the types of the positional
# arguments from abstracts to Mapping.
"""
    construct_experiment(
    logbook::L,
    histconfig::A,
    rootconfig::R
    ) where {L<:AbstractLogbook, A<:AbstractHist1DConfig, R<:AbstractROOTConfig}

    construct_experiment(
    logbook::L,
    histconfig::A,
    rootconfig::R
    ) where {L<:AbstractLogbook, A<:AbstractHist2DConfig, R<:AbstractROOTConfig}

Construct a 1D or 2D histograms based on the `histconfigs`.
Returns an object of type `Experiment`
"""
function construct_experiment(
    logbook::L,
    histconfig::A,
    rootconfig::R
    ) where {L<:AbstractLogbook, A<:AbstractHist1DConfig, R<:AbstractROOTConfig}

    # A vector of sensors equal in length to the number of runs.
    # Conceptually should reflect the result of the sensor for each run.
    # Holds the histograms for each run for each sensor readout channel
    runs = Vector{MappingRun}(undef, length(logbook.entries))

    # loop through runs of the experiment
    for e in eachindex(logbook.entries)
        println("Looping run $(logbook.entries[e].runname)")

        # get the lazy tree for run r
        lz_tree = construct_lazytree(logbook.entries[e], rootconfig)

        # create the vector holding the histogram for each sensor readout channel
        readouts = Vector{Readout}(undef, length(histconfig.channels))

        # loop through the channels
        for j in eachindex(histconfig.channels)

            # construct histogram for channel j
            hj = Hist1D(;binedges=histconfig.binedges[j])

            # loop through the events
            for (i,event) in enumerate(lz_tree)

                if !isnothing(histconfig.maxval)
                    if i > histconfig.maxval[j]
                        break
                    end
                end

                # initialize mask
                mask = nothing

                # create mask
                # in case of `Nothing` as cuts
                if isnothing(histconfig.cuts)
                    mask = event[:Channel] .== histconfig.channels[j]

                # in case of `Vector` as cuts
                elseif isnothing(histconfig.cuts[j])
                    mask = event[:Channel] .== histconfig.channels[j]
                else
                    mask = event[:Channel] .== histconfig.channels[j] .&& histconfig.cuts[j](event)
                end

                # mask false
                if iszero(mask)
                    continue
                end

                # # algorithm to apply xcuts
                # if !isnothing(histconfig.xcuts[j])

                #     # xmask = mask_function(event, xcuts)
                #     xmask = histconfig.xcuts[j](event)

                #     # mask=true & xmask=false
                #     if iszero(xmask)
                #         continue
                #     end

                #     # mask=true & xmask=true
                #     # if xmask is zero (false)(also must contain a channel cut), move on to
                #     # apply xcut
                #     x = event[histconfig.xvar][mask]
                #     atomic_push!(hj, x[1])

                #     continue

                # end

                x = event[histconfig.xvar][mask]
                atomic_push!(hj, x[1])

            end # lz loop

            # the histogram corresponding to channel j
            readouts[j] = Readout(histconfig.channels[j], hj)

        end # channels loop

        runs[e] = MappingRun(readouts)

    end # runs loop

    experiment = MappingExperiment(
        (x=histconfig.xvar,),
        logbook,
        runs,
        histconfig.channels
    )

    return experiment
end

function construct_experiment(
    logbook::L,
    histconfig::A,
    rootconfig::R
    ) where {L<:AbstractLogbook, A<:AbstractHist2DConfig, R<:AbstractROOTConfig}

    # A vector of sensors equal in length to the number of runs.
    # Conceptually should reflect the result of the sensor for each run.
    # Holds the histograms for each run for each sensor readout channel
    runs = Vector{MappingRun}(undef, length(logbook.entries))

    # loop through runs of the experiment
    for e in eachindex(logbook.entries)
        println("Looping run $(logbook.entries[e].runname)")

        # get the lazy tree for run r
        lz_tree = construct_lazytree(logbook.entries[e], rootconfig)

        # create the vector holding the histogram for each sensor readout channel
        readouts = Vector{Readout}(undef, length(histconfig.channels))

        # loop through the channels
        for j in eachindex(histconfig.channels)

            # construct histogram for channel j
            hj = Hist2D(;binedges=histconfig.binedges[j])

            # loop through the events
            for (i,event) in enumerate(lz_tree)

                if !isnothing(histconfig.maxval)
                    if i > histconfig.maxval[j]
                        break
                    end
                end

                # initialize mask
                mask = nothing

                # create mask
                # in case of `Nothing` as cuts
                if isnothing(histconfig.cuts)
                    mask = event[:Channel] .== histconfig.channels[j]

                # in case of `Vector` as cuts
                elseif isnothing(histconfig.cuts[j])
                    mask = event[:Channel] .== histconfig.channels[j]
                else
                    mask = event[:Channel] .== histconfig.channels[j] .&& histconfig.cuts[j](event)
                end

                # mask false
                if iszero(mask)
                    continue
                end

                # # algorithm to apply xcuts
                # if !isnothing(histconfig.xcuts[j])

                #     # xmask = mask_function(event, xcuts)
                #     xmask = histconfig.xcuts[j](event)

                #     # mask=true & xmask=false
                #     if iszero(xmask)
                #         continue
                #     end

                #     # mask=true & xmask=true
                #     # if xmask is zero (false)(also must contain a channel cut), move on to
                #     # apply xcut
                #     x = event[histconfig.xvar][mask]
                #     atomic_push!(hj, x[1])

                #     continue

                # end

                x = event[histconfig.xvar][mask]
                y = event[histconfig.yvar][mask]
                atomic_push!(hj, x[1], y[1])

            end # lz loop

            # the histogram corresponding to channel j
            readouts[j] = Readout(histconfig.channels[j], hj)

        end # channels loop

        runs[e] = MappingRun(readouts)

    end # runs loop

    experiment = MappingExperiment(
        (x=histconfig.xvar, y=histconfig.yvar,),
        logbook,
        runs,
        histconfig.channels
    )

    return experiment
end
