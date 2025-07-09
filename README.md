
The package `Corpuscles.jl`, maintained by the JuliaPhysics community, is the equivalent of Python's scikit-hep `particle` for Julia users, providing access to different particles and their properties. It is very nice!

However, it does not yet currently handle nuclear isotopes, and adding them will require some restructuring of their particle catalog system (see https://github.com/JuliaPhysics/Corpuscles.jl/issues/20). As a quick fix for the time being, I hacked together Gregstrq's `IsotopeTable.jl`. You can now "construct" nuclei as 

```julia
julia> p = Particle(; A=12, Z=6 )
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

julia> p.A
12

julia> p.Z
6

julia> pdgid( p )
PDGID(1000060120)
```

Additionally, I really love the `print_particle_decays` function in Anatoli Feydnitch's `particletools` Python package, so I added an optional extension package to add that functionality. If particletools in installed and you are `using PyCall`, then the decay modes of a given particle can be accessed using the `decay_modes` function:

```julia
julia> decay_modes( Particle(12) )
nu_e is stable

julia> decay_modes( Particle(13) )
mu- decays into:
	       100%, nu_ebar, e-, nu_mu

julia> decay_modes( Particle("K+") )
K+ decays into:
	     63.43%, mu+, nu_mu
	    20.911%, pi+, pi0
	      5.59%, pi+, pi+, pi-
	      4.98%, nu_e, e+, pi0
	      3.32%, nu_mu, mu+, pi0
	     1.757%, pi+, pi0, pi0
	    0.0041%, e+, nu_e, pi+, pi-
	    0.0028%, mu+, nu_mu, pi+, pi-
	    0.0022%, e+, nu_e, pi0, pi0
	    0.0015%, e+, nu_e
	    0.0014%, mu+, nu_mu, pi0, pi0
```