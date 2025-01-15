
abstract type AbstractEntry end
abstract type AbstractLogbook end
abstract type AbstractReadout end
abstract type AbstractRun end
abstract type AbstractExperiment end

abstract type AbstractConfig end
abstract type AbstractROOTConfig <: AbstractConfig end
abstract type AbstractHist1DConfig <: AbstractConfig end
abstract type AbstractHist2DConfig <: AbstractConfig end

abstract type AbstractPlotsConfig <:AbstractConfig end
abstract type FacetConfig <: AbstractPlotsConfig end

abstract type AbstractPlots end
abstract type Facet <: AbstractPlots end
abstract type AbstractPlotExperiment <: AbstractPlots end
abstract type HeatmapExperiment <: AbstractPlotExperiment end

abstract type AbstractModelConfig <: AbstractConfig end
abstract type AbstractFit end
abstract type AbstractDataModels end
