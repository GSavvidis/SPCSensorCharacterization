
"""
Holds parameters that configures the Turing.sample() function
"""
struct MCMCConfig{T <: Turing.Inference.InferenceAlgorithm}
    sampler::T
    mcmcthreads::MCMCThreads
    nsamples::Int
    nchains::Int
    samplekwargs::NamedTuple

    function MCMCConfig(
        sampler::T,
        mcmcthreads::MCMCThreads,
        nsamples::Int,
        nchains::Int;
        samplekwargs::NamedTuple=NamedTuple()
        ) where {T <: Turing.Inference.InferenceAlgorithm}

        new{T}(sampler, mcmcthreads, nsamples, nchains, samplekwargs)
    end
end

"""
Holds the model to be used for fitting
"""
struct HistModelConfig <: AbstractDataModels
    modelname::Symbol
    modelfunction::Function
    initial_params::NamedTuple
end
