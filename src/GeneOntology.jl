module GeneOntology

export
    # term
    Term,
    cellular_component, biological_process, molecular_function,
    isobsolete, @go_str,

    # typedef
    Typedef,

    # annotation
    AnnotationRecord,

    # parser
    OBOParser, eachterm, eachtypedef,
    AnnotaionParser, eachannot,

    # graph
    GOGraph, is_a, parents, children

include("term.jl")
include("typedef.jl")
include("annotation.jl")
include("parser.jl")
include("graph.jl")

end # GeneOntology module
