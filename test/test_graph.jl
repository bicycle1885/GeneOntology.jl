macro test_isa(term1, term2)
    quote
        @test is_a(go, term1, term2)
        @test !is_a(go, term2, term1)
    end
end

let
    go = gograph("test/data/go_mini.obo")
    term1 = Term("GO:0000001", "one")
    term2 = Term("GO:0000002", "two")
    term4 = Term("GO:0000004", "four")
    term5 = Term("GO:0000005", "five")

    @test_isa term1 term2
    @test_isa term4 term2
    @test_isa term5 term4
    @test_isa term5 term2

    @test !is_a(go, term1, term5)
    @test !is_a(go, term5, term1)
end
