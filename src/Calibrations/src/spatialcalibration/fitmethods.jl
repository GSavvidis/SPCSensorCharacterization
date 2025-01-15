
"""
    decompose_hist(h::Hist1D)

Returns the bincenters, the counts and
the bin-width of a 1D histogram
"""
function decompose_hist(h::Hist1D)
    x = bincenters(h)
    counts = bincounts(h)
    bw = binedges(h)[2] - binedges(h)[1]
    # nentries = nentries(h)

    return x, counts, bw
end

"""
    fit_model_to_data(
        fhist::Hist1D,
        modelconfig::HistModelConfig,
        mcmcconfig::MCMCConfig
       )

Fit the model specified in `modelconfig` to the
corresponding 1D histogram `fhist`, using
`Turing`'s MCMC. Returns the chain, the
posterior-predictive-check and the
posterior-predictive-check counts.
"""
function fit_model_to_data(
    fhist::Hist1D,
    modelconfig::HistModelConfig,
    mcmcconfig::MCMCConfig
    )

    bincenters, counts, bw = decompose_hist(fhist)
    Σcounts = sum(counts)

    model′ = nothing

    # posterior predictive of chain
    ppc = nothing

    # posterior predictive of y variable
    ppc_counts = nothing

    # condition
    mdl(y;) = modelconfig.modelfunction(y; bincenters, bw, Σcounts) | (y=counts,)
    model′ = mdl(counts)

    initial_params = zeros(mcmcconfig.nchains)
    initial_params = [modelconfig.initial_params for _ in 1:mcmcconfig.nchains]

    # mdl(y;) = mixture_model(y; bin_centers=bincenters, bw=bw, Σcounts=Σcounts) | (y = counts,)
    # model′ = mdl(counts)

    # MCMC
    chain = Turing.sample(
        model′,
        mcmcconfig.sampler,
        mcmcconfig.mcmcthreads,
        mcmcconfig.nsamples,
        mcmcconfig.nchains;
        initial_params=initial_params,
        mcmcconfig.samplekwargs...
    )


    # elseif model == :mixture_model
    ppc = let
        model_missing = modelconfig.modelfunction(missing; bincenters=bincenters, bw=bw, Σcounts=Σcounts)
        # model_missing = mixture_model(missing; bin_centers=bincenters, bw=bw, Σcounts=Σcounts)
        Turing.generated_quantities(model_missing, chain)
    end

    ppc_counts = map(x -> getfield(x, :bin_counts), Array(ppc))

    # end

    return chain, ppc, ppc_counts

end

# TODO: Implement an additional config for saving the result of the fit
"""
    fit_experiment(
        e::MappingExperiment,
        modelconfig::HistModelConfig,
        mcmcconfig::MCMCConfig
        )

Fits `MappingExperiment`'s multiple runs.
The fitting model is specified in `modelconfig`.
The fit is performed using `Turing`'s MCMC.
The result is saved in a jld2 file for later analysis.
"""
function fit_experiment(
    e::MappingExperiment,
    modelconfig::HistModelConfig,
    mcmcconfig::MCMCConfig
    )

    # loop through the runs
    for i in eachindex(e.runs)

        println("Run = $(e.logbook.entries[i].runname)")
        # vector to store the fit result for each readout
        readout_fits = Vector{ReadoutFitResult}(undef, length(e.runs[i].readouts))

        # loop through the readouts (channels)
        for j in eachindex(e.runs[i].readouts)

            println("Channel readout=$(e.runs[i].readouts[j].channel)")

            # get histogram
            fhist = e.runs[i].readouts[j].fhist

            println("Fitting ")
            # chain, ppc, ppc_counts = fit_model_to_data(fhist, fit_config)
            chain, ppc, ppc_counts = fit_model_to_data(fhist, modelconfig, mcmcconfig)

            readout_fits[j] = ReadoutFitResult(
                e.runs[i].readouts[j],
                chain,
                ppc,
                ppc_counts
            )

        end

        run_result = MappingRunFitResult(
            e.vars,
            readout_fits,
            e.logbook.entries[i]
        )

        println("saving")

        filename = "$(run_result.mapentry.runname)_" *
            "ϕ=$(run_result.mapentry.position[:ϕ])_" *
            "θ=$(run_result.mapentry.position[:θ])_" *
            "longitude=$(run_result.mapentry.position[:longitude])_" *
            "anode=$(run_result.mapentry.position[:anode])_" *
            "x=$(run_result.vars[:x])_" *
            "model=$(modelconfig.modelname)" *
            ".jld2"

        savedir = datadir("jld2/0.25mm_13ball_bak/mapping_fits/mapping6/")
        jldsave(savedir*filename, MappingRunFitResults = run_result)

        # wsave(
        #     savedir * filename,
        #     struct2dict(run_result)
        #       )

        println("Saving fit result in $savedir as $filename")

    end

end
