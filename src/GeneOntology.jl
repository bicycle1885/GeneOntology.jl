module GeneOntology

export Term, OBOParser,
       CellularComponent, BiologicalProcess, MolecularFunction,
       eachterm

include("term.jl")
include("parser.jl")

end # GeneOntology module
