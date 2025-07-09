module ParticleTable

using Corpuscles
using Corpuscles: pdgid, Particle
using IsotopeTable # Corpuscles doesn't have nuclear isotope functionality yet

export Particle
export Isotope
export pdgid

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

# let's overwrite this to handle nuclei for the time being...
function Corpuscles.Particle( id::Corpuscles.ParticleID ) 
    
    if isnucleus( id )
        return Particle(; A=Corpuscles.A(id), Z=Corpuscles.Z(id) )
    else
        # default 
        return Corpuscles.catalog.particle_dict[Base.convert(PDGID, id)]
    end

end

# ========================

decay_modes( p::Particle ) = error("load PyCall + pip install particletools to see decays")
export decay_modes 


end # module ParticleTable