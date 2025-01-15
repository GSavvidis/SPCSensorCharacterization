
# @model function hist_mixture_model(
#     bin_counts,
#     ::Type{T}=Float64;
#     bin_centers,
#     bw,
#     Σcounts
#     ) where {T}

#     # for posterior predictive check
#     if bin_counts === missing
#         bin_counts = Vector{T}(undef, length(bin_centers))
#     end

#     # prior p(θ)
#     μ ~ Uniform(3_000, 20_000)
#     σ ~ Uniform(1_000, 10_000)
#     p ~ Uniform(0, 1)

#     # for i in 1:length(bin_counts)
#     for i in eachindex(bin_counts)

#         # Mixture model
#         bin_centers[i] ~ MixtureModel([Normal(μ, σ), Uniform(0,1)], [p, 1-p])
#         λ = bin_centers[i] * bw * Σcounts
#         bin_counts[i] ~ Poisson(λ)

#     end

#     return(; bin_counts, μ, σ, p)

# end

"""
Defines a custom mixture model assuming signal + background
"""
@model function mixture_model(
    bin_counts,
    ::Type{T}=Float64;
    bincenters,
    bw,
    Σcounts
    ) where {T}

    # for posterior predictive check
    if bin_counts === missing
        bin_counts = Vector{T}(undef, length(bincenters))
    end

    # prior p(θ)
    μ ~ Uniform(3_000, 20_000)
    σ ~ Uniform(1_000, 10_000)
    α ~ Uniform(0, 1)
    β ~ Uniform(0, 1)

    # for i in 1:length(bin_counts)
    for i in eachindex(bin_counts)

        # # Gaussian component
        gaussian_comp = pdf(Normal(μ, σ), bincenters[i])

        # Background component (uniform probability density over the bin width)
        background_comp = β

        # Mixture model - Expectedcounts per bin
        λ = (α*gaussian_comp + (1 - α)*background_comp) * Σcounts * bw

        bin_counts[i] ~ Poisson(λ)
    end

    return(; bin_counts, μ, σ, α, β)
    # return(; bin_counts, μ, σ, β)

    # return(; bin_counts, μ, σ, λ, β)

end
