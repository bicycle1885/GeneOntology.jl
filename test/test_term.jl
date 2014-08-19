let
    # constructor
    term = Term("GO:0000001", "mitochondrion inheritance")
    @test isa(term, Term)
    @test term.id == 1
    @test term.name == "mitochondrion inheritance"
    @test !isobsolete(term)
    @test go"GO:0000001" == term
    @test go"0000001" == term
    @test string(term) == "Term(\"GO:0000001\", \"mitochondrion inheritance\")"

    obsolete_term = Term("GO:0000005", "ribosomal chaperone activity", obsolete=true)
    @test isobsolete(obsolete_term)
end
