
module ParticleDecays

# ====================
# functionality to print particle decays (very useful);
# from Anatoli Feydnitch's `particletools` Python package

using ParticleTable
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
function ParticleTable.decay_modes( p::Particle )
    print_decay_channels( p.pdgid.value )
end

end # module ParticleDecays