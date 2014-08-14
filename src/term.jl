# GO Terms
# http://www.geneontology.org/page/ontology-structure

# Three root ontologies
abstract RootOntology
immutable CellularComponentOntology <: RootOntology; end
immutable BiologicalProcessOntology <: RootOntology; end
immutable MolecularFunctionOntology <: RootOntology; end

const cellular_component = CellularComponentOntology()
const biological_process = BiologicalProcessOntology()
const molecular_function = MolecularFunctionOntology()

immutable Term
    id::Int
    name::ASCIIString
    obsolete::Bool
    namespace::RootOntology
    def::ASCIIString
    isa::Vector{Int}
    synonyms::Vector{String}
    tags::Dict{ASCIIString,String}

    # Required two fields defined in 'The OBO Flat File Format Specification, version 1.2'
    # link: http://geneontology.org/GO.format.obo-1_2.shtml
    function Term(id::ASCIIString, name::ASCIIString; obsolete::Bool=false)
        id_ = parseid(id)
        new(id_, name, obsolete)
    end

    # Essential five elements defined in 'Ontology Structure'
    # link: http://www.geneontology.org/page/ontology-structure
    function Term(id::ASCIIString, name::ASCIIString,
                  namespace::ASCIIString, def::ASCIIString,
                  isa::Vector{ASCIIString}; obsolete::Bool=false)
        id_ = parseid(id)
        namespace_ = namespaceof(namespace)
        isa_ = [parseid(id) for id in isa]
        new(id_, name, obsolete, namespace_, def, isa_)
    end
end

import Base: ==

Base.isequal(term1::Term, term2::Term) = term1.id == term2.id
==(term1::Term, term2::Term) = isequal(term1, term2)
Base.hash(term::Term) = hash(term.id)
Base.show(io::IO, term::Term) = @printf io "Term(\"GO:%07d\", \"%s\")" term.id term.name
Base.showcompact(io::IO, term::Term) = @printf io "GO:%07d" term.id

isobsolete(term::Term) = term.obsolete

const termid_re = r"^GO:(\d{7})$"

function parseid(id::ASCIIString)
    m = match(termid_re, id)
    is(m, nothing) && error("invalid term id: '$id'")
    int(m.captures[1])
end

function namespaceof(namespace::ASCIIString)
    if namespace == "cellular_component"
        return cellular_component
    elseif namespace == "biological_process"
        return biological_process
    elseif namespace == "molecular_function"
        return molecular_function
    end
    error("invalid namespace: '$namespace'")
end
