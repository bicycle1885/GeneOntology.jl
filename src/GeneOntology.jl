module GeneOntology

export
    # term
    Term,
    cellular_component, biological_process, molecular_function,
    isobsolete,

    # typedef
    Typedef,

    # parser
    OBOParser, eachterm, eachtypedef,

    # graph
    gograph, is_a

include("term.jl")
include("typedef.jl")
include("parser.jl")
include("graph.jl")

end # GeneOntology module
