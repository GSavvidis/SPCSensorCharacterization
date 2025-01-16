module Calibrations

using UnROOT
using FHist
using DataFrames
using CairoMakie
using Turing
using DrWatson
using JLD2
using Missings

include("abstractstructs/abstractstructs.jl")

export
    MappingROOTConfig,
    MappingHist1DConfig,
    MappingHist2DConfig

include("spatialcalibration/analysisconfigs.jl")

export
    MapEntry,
    MapLogbook,
    Readout,
    MappingRun,
    MappingExperiment,
    CountsHeatmapExperiment

include("spatialcalibration/analysisexperiment.jl")

export construct_lazytree

include("utils/lazytreemethods.jl")

export
    construct_logbook,
    construct_experiment

include("spatialcalibration/analysismethods.jl")

export
    MappingFacetConfig,
    HeatmapCountsExperimentConfig

include("spatialcalibration/plotconfigs.jl")

export
    MappingFacet,
    HeatmapPlotExperiment

include("spatialcalibration/plotstructs.jl")

export
    plot_readout,
    plot_run,
    construct_facet,
    add_facet_labels!,
    add_facet_legend!,
    construct_experiment_counts_heatmap
    # plot_facet

include("spatialcalibration/plotmethods.jl")

export
    HistModelConfig,
    MCMCConfig

include("spatialcalibration/fitconfigs.jl")

export
    ReadoutFitResult,
    MappingRunFitResult

include("spatialcalibration/fitstructs.jl")

export
    mixture_model

include("spatialcalibration/fittingmodels.jl")

export
    fit_model_to_data,
    fit_experiment

include("spatialcalibration/fitmethods.jl")

export
    filterdir,
    get_uniques

include("utils/loadutils.jl")

end # module Calibrations
