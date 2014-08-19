let
    parser = AnnotaionParser("$testdir/data/gene_association.goa_human")
    annots = Array(AnnotationRecord, 0)
    for annot in eachannot(parser)
        push!(annots, annot)
    end
    @test isa(annots[1], AnnotationRecord)
    @test string(annots[1]) == "AnnotationRecord(\"UniProtKB\", \"A0A183\", \"GO:0031424\")"
end
