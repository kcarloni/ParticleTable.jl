module ParticleTable

using Corpuscles
using Corpuscles: pdgid 
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
        return catalog.particle_dict[Base.convert(PDGID, id)]
    end

end

# ====================
# functionality to print particle decays (very useful);
# from Anatoli Feydnitch's `particletools` Python package

using PyCall 
const print_decay_channels = PyNULL()
# const PythiaTable = PyNull()

function __init__()
    py"""
    import particletools.tables as pt 
    from particletools.tables import print_decay_channels
    """
    copy!( print_decay_channels, py"print_decay_channels" )
    # copy!( PythiaTable, py"pt.PYTHIAParticleData()" )
end

"""
    decay_modes( p )

Print the decay channels of a Particle `p`
"""
function decay_modes( p::Particle )
    print_decay_channels( p.pdgid.value )
end
export decay_modes

end # module ParticleTable
