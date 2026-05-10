# ParticleTable.jl

A small convenience package that bridges [`Corpuscles.jl`](https://github.com/JuliaPhysics/Corpuscles.jl) and [`IsotopeTable.jl`](https://github.com/Gregstrq/IsotopeTable.jl), and adds a `decay_modes` function backed by Anatoli Fedynitch's [`particletools`](https://github.com/afedynitch/particletools) Python package.

`Corpuscles.jl`, maintained by the JuliaPhysics community, is the Julia equivalent of Python's scikit-hep `particle`. It does not yet handle nuclear isotopes (see [JuliaPhysics/Corpuscles.jl#20](https://github.com/JuliaPhysics/Corpuscles.jl/issues/20)), so this package routes nuclear PDG ids through `IsotopeTable.jl` while leaving everything else to Corpuscles.

## Installation

```julia
pkg> add ParticleTable
```

`particletools` is installed automatically into a project-local Python environment via [`CondaPkg`](https://github.com/JuliaPy/CondaPkg.jl) the first time the package is loaded — no manual Python setup required.

## Particles and nuclei

```julia
julia> using ParticleTable

julia> Particle("K+")
Particle K+

julia> Particle(13)        # by PDG id
Particle mu-

julia> p = Particle(; A=12, Z=6)
Carbon ¹²C, Z=6:
               atomic number: 6
                 mass number: 12
           natural abundance: 98.94
                        mass: 12.0 ± 0.0 u
                        spin: 0//1
                      parity: 1
              is radioactive: false
                   half-life: Inf ± 0.0 s
                    g-factor: 0.0 ± 0.0
  electric quadrupole moment: 0.0 ± 0.0 barn

julia> p.A, p.Z
(12, 6)

julia> pdgid(p)
PDGID(1000060120)

julia> Particle(PDGID(1000260560))   # heavy nucleus by PDG id
```

Light nuclei that exist in Corpuscles' catalog (proton, neutron, deuteron, ...) come from Corpuscles; everything else nuclear comes from `IsotopeTable`.

## Decay modes

`decay_modes(p)` returns a `DecayModes` value: a list of `DecayChannel`s with `branching_ratio` and `products::Vector{PDGID}`. It pretty-prints at the REPL, and is also iterable and indexable for programmatic access.

```julia
julia> decay_modes(Particle(12))
nu(e)0 is stable

julia> decay_modes(Particle(13))
mu- decays into:
	    100.0%, ~nu(e)0, e-, nu(mu)0

julia> dm = decay_modes("K+")
K+ decays into:
	    63.43%, mu+, nu(mu)0
	   0.0015%, e+, nu(e)0
	    20.91%, pi+, pi0
	     5.59%, pi+, pi+, pi-
	    1.757%, pi+, pi0, pi0
	     4.98%, nu(e)0, e+, pi0
	     3.32%, nu(mu)0, mu+, pi0
	   0.0022%, e+, nu(e)0, pi0, pi0
	   0.0041%, e+, nu(e)0, pi+, pi-
	   0.0014%, mu+, nu(mu)0, pi0, pi0
	   0.0028%, mu+, nu(mu)0, pi+, pi-

julia> dm[1].branching_ratio
0.6343

julia> dm[1].products
2-element Vector{PDGID}:
 PDGID(-13)
 PDGID(14)

julia> sum(c.branching_ratio for c in dm)
0.9999999999999998
```

## Credits

Decay-channel data comes from Anatoli Fedynitch's [`particletools`](https://github.com/afedynitch/particletools) Python package — specifically `PYTHIAParticleData.decay_channels`, which sources its tables from PYTHIA. This package just wraps that call and pretty-prints the result alongside Corpuscles' particle catalog.

Particle data comes from [`Corpuscles.jl`](https://github.com/JuliaPhysics/Corpuscles.jl) (JuliaPhysics) and nuclear-isotope data from [`IsotopeTable.jl`](https://github.com/Gregstrq/IsotopeTable.jl).
