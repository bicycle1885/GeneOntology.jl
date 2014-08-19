using GeneOntology
using Base.Test

const testdir = dirname(@__FILE__)

include("test_term.jl")
include("test_typedef.jl")
include("test_annotation.jl")
include("test_parser.jl")
include("test_graph.jl")
