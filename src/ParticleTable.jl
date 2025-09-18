module ParticleTable

using Corpuscles
using Corpuscles: pdgid, Particle
using IsotopeTable # Corpuscles doesn't have nuclear isotope functionality yet

export Particle
export Isotope
export pdgid, PDGID

Base.broadcastable( p::Particle ) = Ref(p)

# ====================
# functionality for nuclei

function Base.getproperty( N::Isotope, sym::Symbol )

    if sym in fieldnames( Isotope )
        return getfield( N, sym )
    elseif sym == :A
        return N.mass_number
    elseif sym == :Z
        return N.atomic_number
    end

end

Corpuscles.pdgid(; A, Z, L=0, I=0 ) = PDGID( Int( 1e9 + L * 1e5 + Z * 1e4 + A * 10 + I ) )
Corpuscles.pdgid( N::Isotope ) = Corpuscles.pdgid(; A=N.A, Z=N.Z )

function Corpuscles.Particle(; A, Z )
    return isotopes(Z,A)
end
Corpuscles.Particle( nt::@NamedTuple{A::Int64, Z::Int64} ) = Corpuscles.Particle(; nt... )

# let's write a sub method to handle nuclei for the time being...
function Corpuscles.Particle( id::Corpuscles.PDGID )  
    if isnucleus( id ) && ! any( in.( id.value, values.( (Corpuscles.scikit_common, Corpuscles.more_common, Corpuscles.inv_catalog) ) ) )
        return Particle(; A=Corpuscles.A(id), Z=Corpuscles.Z(id) )
    else
        # default 
        return Corpuscles.catalog.particle_dict[Base.convert(PDGID, id)]
    end
end

# ========================

# note to self: do not specify p type below! that will cause method re-definition during pre-compilation

"""
    decay_modes( p::Particle )

Lists the decay modes of a given particle, using Anatoli Feydnitch's `particletools` python package.
"""
decay_modes( p ) = error("pip install particletools + load PyCall to see decays")

decay_modes( p_str::String ) = decay_modes( Particle(p_str) )

export decay_modes 


end # module ParticleTable