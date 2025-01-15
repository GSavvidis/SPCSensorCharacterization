
"""
Filter filenames in a directory using regex.
Returns a vector of Strings containing the filenames.
"""
function filterdir(path_to_dir;
                   regex_patterns::Union{Nothing, Vector{<:Pair}}=nothing,
                   filters::Union{Nothing, Dict}=nothing,
                   comb::Union{Nothing, Function}=nothing,
                   sort_by::Union{Nothing, Function}=nothing)

    println("Reading directory $(path_to_dir)")
    files = readdir(path_to_dir)

    if !isnothing(sort_by)
        # extract_val(str) = parse(Int, match(r"Longitude=(\d+)", str).captures[1])
        files = sort(files, by=sort_by)
    end

    filtered_files = []

    # filter files
    for i in eachindex(files)
        file = files[i]

        if !isnothing(regex_patterns) && !isnothing(filters)

            if length(regex_patterns) != length(filters)
                throw("`regex_patterns` and `filters` must have the same length.")
            end

            regex_result = Dict()

            for j in eachindex(regex_patterns)
                regex_pattern_j = regex_patterns[j].second
                regex_match_j = match(regex_pattern_j, file)

                if isnothing(regex_match_j)
                    throw("regex_match returned nothing. Check typos in regex_pattern.")
                end

                regex_value_j = parse(Int, regex_match_j.captures[1])
                var_j = regex_patterns[j].first
                filter_func_j = filters[var_j]

                regex_result[var_j] = filter_func_j(regex_value_j)

            end

            if comb(regex_result) == true
                # files that pass the filter
                push!(filtered_files, file)
            end

        end
    end

    return filtered_files
end
