

"""
The MCMC result of the fit for a given readout
"""
struct ReadoutFitResult
    readout::AbstractReadout
    chain::Chains
    ppc
    ppc_counts
end

"""
Holds the results of fits for all readouts of a given run
together with the logbook information
"""
struct MappingRunFitResult
    vars::NamedTuple
    readouts::Vector{ReadoutFitResult}
    mapentry::MapEntry
end
