# Tests for Poset type and operations

using Test
using NumericalSemigroupLab

@testset "Posets" begin
    
    @testset "Construction" begin
        elements = [1, 2, 3, 6]
        relations = Tuple{Int,Int}[]
        for a in elements
            for b in elements
                if b % a == 0
                    push!(relations, (a, b))
                end
            end
        end
        
        p = Poset(elements, relations)
        @test length(p.elements) == 4
        @test (1, 6) in p.relations
        @test (2, 6) in p.relations
        @test (3, 6) in p.relations
    end
    
    @testset "Cover relations" begin
        elements = [1, 2, 4, 8]
        relations = Tuple{Int,Int}[]
        for a in elements
            for b in elements
                if b % a == 0
                    push!(relations, (a, b))
                end
            end
        end
        
        p = Poset(elements, relations)
        covers = cover_relations(p)
        
        # Chain 1 < 2 < 4 < 8
        @test (1, 2) in covers
        @test (2, 4) in covers
        @test (4, 8) in covers
        @test (1, 4) ∉ covers  # Not a cover
        @test (1, 8) ∉ covers  # Not a cover
    end
    
    @testset "Minimal elements" begin
        elements = [1, 2, 3, 6]
        relations = Tuple{Int,Int}[]
        for a in elements
            for b in elements
                if b % a == 0
                    push!(relations, (a, b))
                end
            end
        end
        
        p = Poset(elements, relations)
        mins = minimal_elements(p)
        @test mins == [1]
    end
    
    @testset "Maximal elements" begin
        elements = [1, 2, 3, 6]
        relations = Tuple{Int,Int}[]
        for a in elements
            for b in elements
                if b % a == 0
                    push!(relations, (a, b))
                end
            end
        end
        
        p = Poset(elements, relations)
        maxs = maximal_elements(p)
        @test maxs == [6]
    end
    
    @testset "Multiple minimal/maximal" begin
        # Anti-chain: no relations except reflexive
        elements = [2, 3, 5, 7]
        relations = [(x, x) for x in elements]
        
        p = Poset(elements, relations)
        mins = minimal_elements(p)
        maxs = maximal_elements(p)
        
        @test Set(mins) == Set(elements)
        @test Set(maxs) == Set(elements)
    end
    
    @testset "Gap poset" begin
        S = NumericalSemigroup([3, 5])
        p = gap_poset(S)
        
        # Gaps are [1, 2, 4, 7]
        @test length(p.elements) == 4
        @test 1 in p.elements
        @test 2 in p.elements
        @test 4 in p.elements
        @test 7 in p.elements
        
        # Ordering: g1 ≤ g2 if g2 - g1 ∈ S
        @test (1, 4) in p.relations  # 4 - 1 = 3 ∈ S
        @test (1, 7) in p.relations  # 7 - 1 = 6 ∈ S
        @test (4, 7) in p.relations  # 7 - 4 = 3 ∈ S
    end
    
    @testset "Void poset" begin
        S = NumericalSemigroup([3, 5])
        vp = void_poset(S)
        
        # For symmetric semigroup, void = {Frobenius}
        @test 7 in vp.elements
    end
    
    @testset "Gap poset maximal = void" begin
        S = NumericalSemigroup([3, 5])
        p = gap_poset(S)
        maxs = maximal_elements(p)
        v = void(S)
        
        @test Set(maxs) == Set(v)
    end
    
end
