
# abstract type AbstractPlots end
# abstract type AbstractPlotExperiment <: AbstractPlots end
# abstract type Facet <: AbstractPlots end

# struct ReadoutGrid
#     grid::GridLayout
# end

struct MappingFacet <: Facet
    fig::Figure
    grid::GridLayout
    axes::Array
    rowvar::Symbol
    colvar::Symbol
    rowvals::Vector
    colvals::Vector
end

struct HeatmapPlotExperiment <: AbstractPlotExperiment
    fig::Figure
    grid::GridLayout
    hm::Vector{HeatmapExperiment}
end
