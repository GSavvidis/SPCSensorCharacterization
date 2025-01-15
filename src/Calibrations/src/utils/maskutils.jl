
"""
    mask_function(evnt::UnROOT.LazyEvent, condition::Function)

Function for masking. Meant to be used with the UnROOT framework.
It works for any length of `LazyEvent`.
Returns a mask.

# Arguments
- `evnt::UnROOT.LazyEvent`: `LazyEvent` to be masked. It is usually obtained from `for` loops.
- `condition::Function`: Anonymous function holding the mask condition (cut). e.g `x -> x.Channel .== 0 .&& 5 .< x.DD_RawRise .< 30`.
"""
function mask_function(evnt::UnROOT.LazyEvent, condition::Function)
        msk = condition(evnt)
        return msk
end

"""
To combine two masks simultaneously in lazy event
"""
function combine_functions(f1::Function, f2::Function)
        return x -> f1(x) .&& (f2(x))
end
