module ParticleTable

using PyCall
using Corpuscles

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

import Base: broadcastable

broadcastable( p::Particle ) = Ref(p)

export Particle

end # module ParticleTable
