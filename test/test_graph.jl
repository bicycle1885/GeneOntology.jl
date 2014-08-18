function test_isa(go, term1, term2)
    @test is_a(go, term1, term2)
    @test !is_a(go, term2, term1)
end

let
    go = gograph("test/data/go_mini.obo")
    term1 = Term("GO:0000001", "one")
    term2 = Term("GO:0000002", "two")
    term4 = Term("GO:0000004", "four")
    term5 = Term("GO:0000005", "five")

    test_isa(go, term1, term2)
    test_isa(go, term4, term2)
    test_isa(go, term5, term4)
    test_isa(go, term5, term2)

    @test !is_a(go, term1, term5)
    @test !is_a(go, term5, term1)

    @test parents(go, term1) == [term2]
    @test isempty(parents(go, term2))
    @test parents(go, term4) == [term2]
    @test parents(go, term5) == [term4]

    @test isempty(children(go, term1))
    @test children(go, term2) == [term1, term4]
    @test children(go, term4) == [term5]
    @test isempty(children(go, term5))
end
