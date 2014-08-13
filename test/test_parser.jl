let
    parser = OBOParser("test/data/go.obo")
    @test parser.filepath == "test/data/go.obo"
    @test parser.version == "1.2"
    @test parser.headertags["data-version"] == "releases/2014-08-09"
    @test parser.headertags["auto-generated-by"] == "TermGenie 1.0"
end

let
    parser = OBOParser("test/data/go.obo")
    terms = Array(Term, 0)
    for term in eachterm(parser)
        push!(terms, term)
    end

    # NOTE: the equality of two terms is defined by their GO id only
    @test isequal(terms[1], Term("GO:0000001", "mitochondrion inheritance"))
    @test terms[1] == Term("GO:0000001", "mitochondrion inheritance")
    @test terms[2] == Term("GO:0000002", "mitochondrial genome maintenance")
    # ...
    @test terms[end] == Term("GO:0000086", "G2/M transition of mitotic cell cycle")

    # [Term]
    # id: GO:0000001
    # name: mitochondrion inheritance
    # namespace: biological_process
    # def: "The distribution of mitochondria, including the mitochondrial genome, into daughter cells after mitosis or meiosis, mediated by interactions between mitochondria and the cytoskeleton." [GOC:mcc, PMID:10873824, PMID:11389764]
    # synonym: "mitochondrial inheritance" EXACT []
    # is_a: GO:0048308 ! organelle inheritance
    # is_a: GO:0048311 ! mitochondrion distribution
    @test is(terms[1].namespace, BiologicalProcess)
    @test terms[1].def == "The distribution of mitochondria, including the mitochondrial genome, into daughter cells after mitosis or meiosis, mediated by interactions between mitochondria and the cytoskeleton."
end
