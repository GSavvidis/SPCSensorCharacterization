# SPCSensorCharacterization


## Introduction
The project aims at creating an interface for the analysis of sensor calibration
data from a Spherical Proportional Counter (SPC). The reasoning behind the
structure and implementation of the code focuses on reproducibility,
speed, code readability/reusability, and flexibility in code expansion.

> [!IMPORTANT]
> The project is still under development. The philosophy of the project and
> the core implementation is not expected to change. However, optimizations,
> improvements and expansion is expected to take place. 

## Aspects
- This project is using [DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/) 
to provide reproducibility and a flexible working environment.

- [UnROOT](https://github.com/JuliaHEP/UnROOT.jl) combined with [FHist](https://github.com/Moelf/FHist.jl)
are used to analyze the the ROOT files. 

- [Makie](https://docs.makie.org/v0.22/) is used for vizualization.

- [Turing](https://turinglang.org/) is used for fitting.

## Overview
The philosophy of the project is based on the nature of the work for the
calibration of the sensor in an SPC. A variety of calibrations share a 
common basis but differ in the final handling of the data. The common basis
consists the part of reading the data, vizualizing and performing cuts. 
This pipeline usually involves the analysis of multiple data files and 
in some occations a single data file. Depending on the kind of calibration, 
the next steps differ from one another.

Consequently, a number of `abstract structs` is used to encapsulate the
nature of the workflow.

> [!Note]
> For the moment, the code is used only for the mapping calibration.
> Next step is to expand it for pressure and gain-curve calinrations.
> A more detailed documentation is expected once a concrete design is
> achieved.

## Local reproduction
This code base is using the [Julia Language](https://julialang.org/) and
[DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> SPCSensorCharacterization

It is authored by gsavvidis.

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:
   ```
   julia> using Pkg
   julia> Pkg.add("DrWatson") # install globally, for using `quickactivate`
   julia> Pkg.activate("path/to/this/project")
   julia> Pkg.instantiate()
   ```

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box, including correctly finding local paths.

You may notice that most scripts start with the commands:
```julia
using DrWatson
@quickactivate "SPCSensorCharacterization"
```
which auto-activate the project and enable local path handling from DrWatson.

> [!IMPORTANT]
> To correctly reproduce the project, the local Julia version of the user should
> be the same with the Julia version used to create the project. To check the
> Julia version of the project, the user should look at the `Project.toml` file 
> on the `[compat]` section.

> [!NOTE]
> For users who don't have Julia installed, it is recommended to install the 
> [Juliaup](https://github.com/JuliaLang/juliaup) version manager which provides
> a flexible way for installing and managing julia.
