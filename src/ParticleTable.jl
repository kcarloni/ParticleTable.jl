module ParticleTable

using Corpuscles
using Corpuscles: pdgid, Particle
using IsotopeTable # Corpuscles doesn't have nuclear isotope functionality yet
using PythonCall

export Particle
export Isotope
export pdgid, PDGID

# Type piracy: these methods extend Base/Corpuscles on types we don't own.
# Justified for a bridge package; ideally `broadcastable` would live upstream
# (TODO: open a one-line PR to JuliaPhysics/Corpuscles.jl).
Base.broadcastable( p::Particle ) = Ref(p)
Base.broadcastable( N::Isotope ) = Ref(N)

# ====================
# functionality for nuclei

function Base.getproperty( N::Isotope, sym::Symbol )
    if sym === :A
        return getfield(N, :mass_number)
    elseif sym === :Z
        return getfield(N, :atomic_number)
    else
        return getfield(N, sym)
    end
end

Base.propertynames(::Isotope, private::Bool=false) =
    (fieldnames(Isotope)..., :A, :Z)

Corpuscles.pdgid(; A, Z, L=0, I=0 ) = PDGID( Int( 1e9 + L * 1e5 + Z * 1e4 + A * 10 + I ) )
Corpuscles.pdgid( N::Isotope ) = Corpuscles.pdgid(; A=N.A, Z=N.Z )

function Corpuscles.Particle(; A, Z )
    return isotopes(Z,A)
end
Corpuscles.Particle( nt::@NamedTuple{A::Int, Z::Int} ) = Corpuscles.Particle(; nt... )

# Nuclei aren't in Corpuscles' catalog (JuliaPhysics/Corpuscles.jl#20), so for
# nuclear PDG ids we fall through to IsotopeTable. A few light nuclei (proton,
# neutron, deuteron, ...) satisfy `isnucleus` but DO have catalog entries — those
# should still come from Corpuscles.
function Corpuscles.Particle( id::Corpuscles.PDGID )
    pid = Base.convert(PDGID, id)
    if isnucleus(id) && !haskey(Corpuscles.catalog.particle_dict, pid)
        return Particle(; A=Corpuscles.A(id), Z=Corpuscles.Z(id))
    else
        return Corpuscles.catalog.particle_dict[pid]
    end
end

# ========================
# decay modes via Anatoli Fedynitch's `particletools` Python package

struct DecayChannel
    branching_ratio::Float64
    products::Vector{PDGID}
end

struct DecayModes
    parent::Particle
    channels::Vector{DecayChannel}
end

Base.iterate(dm::DecayModes, st...) = iterate(dm.channels, st...)
Base.length(dm::DecayModes) = length(dm.channels)
Base.isempty(dm::DecayModes) = isempty(dm.channels)
Base.getindex(dm::DecayModes, i) = dm.channels[i]

const _pythia_data = Ref{Py}()

function __init__()
    _pythia_data[] = pyimport("particletools.tables").PYTHIAParticleData()
end

"""
    decay_modes(p) -> DecayModes

Return the decay channels of a particle as structured data. `p` may be a
`Particle`, a PDG id, or a particle name string (e.g. `"K+"`). The result
iterates over [`DecayChannel`](@ref)s with fields `branching_ratio` and
`products::Vector{PDGID}`, and pretty-prints at the REPL.
"""
function decay_modes(p::Particle)
    raw = _pythia_data[].decay_channels(p.pdgid.value)
    channels = DecayChannel[]
    for entry in raw
        br = pyconvert(Float64, entry[0])
        ids = pyconvert(Vector{Int}, entry[1])
        push!(channels, DecayChannel(br, [PDGID(i) for i in ids]))
    end
    return DecayModes(p, channels)
end
decay_modes(p) = decay_modes(Particle(p))

_pdg_label(id::PDGID) = try
    Particle(id).name
catch
    string(id.value)
end

function Base.show(io::IO, ::MIME"text/plain", dm::DecayModes)
    if isempty(dm)
        print(io, dm.parent.name, " is stable")
        return
    end
    print(io, dm.parent.name, " decays into:")
    for c in dm.channels
        pct = round(100 * c.branching_ratio; sigdigits=4)
        names = join((_pdg_label(id) for id in c.products), ", ")
        print(io, "\n\t", lpad(string(pct) * "%", 10), ", ", names)
    end
end

function Base.show(io::IO, ::MIME"text/plain", c::DecayChannel)
    pct = round(100 * c.branching_ratio; sigdigits=4)
    names = join((_pdg_label(id) for id in c.products), ", ")
    print(io, pct, "%, ", names)
end

export decay_modes, DecayModes, DecayChannel


end # module ParticleTable