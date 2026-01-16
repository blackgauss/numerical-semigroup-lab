# Phase 2 Tests: Numerical Semigroups from Generators

using Test
using NumericalSemigroupLab

@testset "Phase 2: Gaps from Generators" begin
    @testset "Two-generator semigroups" begin
        # Classic example: <3, 5>
        gaps = compute_gaps_from_generators([3, 5])
        @test gaps == [1, 2, 4, 7]
        @test length(gaps) == 4  # genus
        @test maximum(gaps) == 7  # Frobenius number
        
        # Verify Frobenius formula: F(a,b) = ab - a - b
        @test 7 == 3*5 - 3 - 5
        
        # Another example: <7, 11>
        gaps = compute_gaps_from_generators([7, 11])
        @test maximum(gaps) == 7*11 - 7 - 11  # 59
        @test length(gaps) == (7-1)*(11-1)÷2  # genus = 30
        
        # Small example: <2, 3>
        gaps = compute_gaps_from_generators([2, 3])
        @test gaps == [1]
        @test maximum(gaps) == 1  # F(2,3) = 6-2-3 = 1
    end
    
    @testset "Three-generator semigroups" begin
        # <3, 4, 5>
        gaps = compute_gaps_from_generators([3, 4, 5])
        @test 1 in gaps
        @test 2 in gaps
        # Frobenius should be small since generators are close
        @test maximum(gaps) < 10
        
        # <5, 7, 11>
        gaps = compute_gaps_from_generators([5, 7, 11])
        @test 1 in gaps
        @test 2 in gaps
        @test 3 in gaps
        @test 4 in gaps
        # Should have relatively large Frobenius
        @test maximum(gaps) > 10
    end
    
    @testset "Special cases" begin
        # <1> has no gaps
        gaps = compute_gaps_from_generators([1])
        @test isempty(gaps)
        
        # <2, 3> minimal gaps
        gaps = compute_gaps_from_generators([2, 3])
        @test gaps == [1]
        
        # Duplicate generators
        gaps = compute_gaps_from_generators([3, 5, 3, 5])
        @test gaps == [1, 2, 4, 7]
    end
    
    @testset "Error handling" begin
        # Empty generators
        @test_throws ArgumentError compute_gaps_from_generators(Int[])
        
        # Non-positive generators
        @test_throws ArgumentError compute_gaps_from_generators([3, 0, 5])
        @test_throws ArgumentError compute_gaps_from_generators([-1, 5])
        
        # Non-coprime generators
        @test_throws ArgumentError compute_gaps_from_generators([4, 6])
        @test_throws ArgumentError compute_gaps_from_generators([6, 9, 12])
    end
end

@testset "Phase 2: NumericalSemigroup Type" begin
    @testset "Construction from generators" begin
        S = NumericalSemigroup([3, 5])
        @test S.frobenius == 7
        @test S.genus == 4
        @test S.multiplicity == 3
        @test S.embedding_dimension >= 2
        @test 3 in S.generators
        @test 5 in S.generators
    end
    
    @testset "Construction from gaps" begin
        S = semigroup_from_gaps([1, 2, 4, 7])
        @test S.frobenius == 7
        @test S.genus == 4
        @test S.multiplicity == 3
        @test !isempty(S.generators)
    end
    
    @testset "Trivial semigroup" begin
        # <1> has no gaps
        S = NumericalSemigroup([1])
        @test S.genus == 0
        @test S.frobenius == -1
        @test S.multiplicity == 1
    end
    
    @testset "Properties and accessors" begin
        S = NumericalSemigroup([3, 5])
        
        @test genus(S) == 4
        @test frobenius_number(S) == 7
        @test multiplicity(S) == 3
        @test embedding_dimension(S) >= 2
        
        gens = generators(S)
        @test !isempty(gens)
        @test all(g > 0 for g in gens)
    end
    
    @testset "Display" begin
        S = NumericalSemigroup([3, 5])
        str = sprint(show, S)
        @test occursin("3", str)
        @test occursin("5", str)
        
        # Detailed display
        str = sprint(show, MIME"text/plain"(), S)
        @test occursin("Genus", str)
        @test occursin("Frobenius", str)
    end
end

@testset "Phase 2: Membership Testing" begin
    S = NumericalSemigroup([3, 5])
    
    @testset "Basic membership" begin
        # 0 is always in a semigroup
        @test 0 in S
        
        # Generators are in S
        @test 3 in S
        @test 5 in S
        
        # Gaps are not in S
        @test !(1 in S)
        @test !(2 in S)
        @test !(4 in S)
        @test !(7 in S)
        
        # Sums of generators
        @test 6 in S   # 3+3
        @test 8 in S   # 3+5
        @test 9 in S   # 3+3+3
        @test 10 in S  # 5+5
    end
    
    @testset "Beyond Frobenius" begin
        # Everything beyond Frobenius is in the semigroup
        for n in 8:20
            @test n in S
        end
    end
    
    @testset "Negative numbers" begin
        @test !(-1 in S)
        @test !(-10 in S)
    end
end

@testset "Phase 2: Elements Generation" begin
    S = NumericalSemigroup([3, 5])
    
    @testset "elements_up_to" begin
        elems = elements_up_to(S, 10)
        @test 0 in elems
        @test 3 in elems
        @test 5 in elems
        @test 6 in elems
        @test 8 in elems
        @test 9 in elems
        @test 10 in elems
        
        # Gaps should not be in elements
        @test !(1 in elems)
        @test !(2 in elems)
        @test !(4 in elems)
        @test !(7 in elems)
    end
    
    @testset "Small ranges" begin
        elems = elements_up_to(S, 5)
        @test elems == [0, 3, 5]
        
        elems = elements_up_to(S, 0)
        @test elems == [0]
        
        elems = elements_up_to(S, -5)
        @test isempty(elems)
    end
end

@testset "Phase 2: Apéry Sets" begin
    @testset "Basic Apéry set" begin
        S = NumericalSemigroup([3, 5])
        ap = apery_set(S, 3)
        
        # Should have length 3
        @test length(ap) == 3
        
        # First element should be 0
        @test ap[1] == 0
        
        # All elements should be in S
        for a in ap
            @test a in S
        end
        
        # Elements should represent different residue classes mod 3
        @test ap[1] % 3 == 0
        @test ap[2] % 3 == 1
        @test ap[3] % 3 == 2
    end
    
    @testset "Apéry with respect to multiplicity" begin
        S = NumericalSemigroup([3, 5])
        ap = apery_set(S)  # Should use multiplicity = 3
        @test length(ap) == 3
        @test ap[1] == 0
    end
    
    @testset "Different element" begin
        S = NumericalSemigroup([3, 5])
        
        # Apéry set w.r.t. 5
        ap = apery_set(S, 5)
        @test length(ap) == 5
        @test ap[1] == 0
        
        # All should be minimal in their residue class
        for (i, a) in enumerate(ap)
            @test a % 5 == (i - 1) % 5
        end
    end
    
    @testset "Error handling" begin
        S = NumericalSemigroup([3, 5])
        
        # n must be positive
        @test_throws ArgumentError apery_set(S, 0)
        @test_throws ArgumentError apery_set(S, -1)
        
        # n must be in S
        @test_throws ArgumentError apery_set(S, 2)  # 2 is a gap
        @test_throws ArgumentError apery_set(S, 4)  # 4 is a gap
    end
end

@testset "Phase 2: Minimal Generators" begin
    @testset "is_minimal_generator" begin
        S = NumericalSemigroup([3, 5])
        
        # Actual minimal generators
        @test is_minimal_generator(S, 3)
        @test is_minimal_generator(S, 5)
        
        # Not minimal (can be expressed as sums)
        @test !is_minimal_generator(S, 6)   # 3+3
        @test !is_minimal_generator(S, 8)   # 3+5
        @test !is_minimal_generator(S, 9)   # 3+3+3
        @test !is_minimal_generator(S, 10)  # 5+5
        
        # Gaps are not generators
        @test !is_minimal_generator(S, 1)
        @test !is_minimal_generator(S, 2)
        @test !is_minimal_generator(S, 4)
        
        # 0 is not a generator
        @test !is_minimal_generator(S, 0)
    end
    
    @testset "minimal_generating_set" begin
        S = NumericalSemigroup([3, 5])
        gens = minimal_generating_set(S)
        
        @test !isempty(gens)
        @test all(g > 0 for g in gens)
        @test 3 in gens
        @test 5 in gens
        
        # For <3,5>, minimal set should be exactly {3, 5}
        @test length(gens) == 2
    end
    
    @testset "Redundant generators" begin
        # Create from redundant generators
        S = NumericalSemigroup([3, 5, 8])  # 8 = 3+5
        gens = minimal_generating_set(S)
        
        # 8 should not be in minimal set
        @test 3 in gens
        @test 5 in gens
        # The minimal set should have size 2 or 3 depending on algorithm
        @test length(gens) >= 2
    end
end

@testset "Phase 2: Equality and Hashing" begin
    S1 = NumericalSemigroup([3, 5])
    S2 = NumericalSemigroup([3, 5])
    S3 = semigroup_from_gaps([1, 2, 4, 7])  # Same gaps as S1
    S4 = NumericalSemigroup([7, 11])
    
    @testset "Equality" begin
        @test S1 == S2
        @test S1 == S3  # Same gaps
        @test S1 != S4
    end
    
    @testset "Hashing" begin
        # Equal objects should have equal hashes
        @test hash(S1) == hash(S2)
        @test hash(S1) == hash(S3)
        
        # Can be used in Sets and Dicts
        set = Set([S1, S2, S4])
        @test length(set) == 2  # S1 and S2 are equal
        @test S1 in set
        @test S4 in set
    end
end

@testset "Phase 2: Cache Management" begin
    @testset "Apéry cache" begin
        S = NumericalSemigroup([3, 5])
        
        # First call should compute
        ap1 = apery_set(S, 3)
        
        # Second call should use cache
        ap2 = apery_set(S, 3)
        @test ap1 == ap2
        
        # Clear cache
        clear_apery_cache!()
        
        # Should still work after clearing
        ap3 = apery_set(S, 3)
        @test ap1 == ap3
    end
end

@testset "Phase 2: Integration Tests" begin
    @testset "Full workflow: generators → properties" begin
        S = NumericalSemigroup([7, 11, 13])
        
        # Should have computed all properties
        @test S.genus > 0
        @test S.frobenius > 0
        @test S.multiplicity == 7
        
        # Verify genus formula for 2-gen approximation
        # For <7,11>, F = 7*11-7-11 = 59, g = 30
        # Adding 13 should reduce gaps
        @test S.genus < 30
        
        # Check membership
        @test 7 in S
        @test 11 in S
        @test 13 in S
        @test 14 in S  # 7+7
        @test 18 in S  # 7+11
        @test !(1 in S)
        @test !(2 in S)
    end
    
    @testset "Round-trip: generators → gaps → generators" begin
        original_gens = [3, 5]
        S = NumericalSemigroup(original_gens)
        
        # Get gaps
        gaps_vec = sort(collect(S.gaps))
        
        # Construct from gaps using explicit factory function
        T = semigroup_from_gaps(gaps_vec)
        
        # Should be equal
        @test S == T
        @test S.frobenius == T.frobenius
        @test S.genus == T.genus
    end
    
    @testset "Consistency checks" begin
        S = NumericalSemigroup([5, 7, 11])
        
        # Embedding dimension ≤ number of minimal generators
        @test S.embedding_dimension == length(S.generators)
        
        # All generators should be in S
        for g in S.generators
            @test g in S
        end
        
        # Frobenius should be largest gap
        if !isempty(S.gaps)
            @test S.frobenius == maximum(S.gaps)
        end
        
        # Genus should equal number of gaps
        @test S.genus == length(S.gaps)
        
        # Multiplicity should be smallest generator
        @test S.multiplicity == minimum(S.generators)
    end
end

@testset "Phase 2: AbstractNumericalSet Interface" begin
    @testset "NumericalSet functions work on NumericalSemigroup" begin
        # Create a NumericalSemigroup
        S = semigroup_from_generators([3, 5])
        
        # Test that gaps() accessor works
        @test gaps(S) == BitSet([1, 2, 4, 7])
        @test gaps(S) isa BitSet
        
        # Test that frobenius_number() accessor works
        @test frobenius_number(S) == 7
        
        # Test atom_monoid_gaps works on semigroup
        atom_gaps = atom_monoid_gaps(S)
        @test atom_gaps isa Set{Int}
        @test !isempty(atom_gaps)
        
        # Test partition works on semigroup
        p = partition(S)
        @test p isa Vector{Int}
        
        # Test small_elements works on semigroup
        small = small_elements(S)
        @test small isa Vector{Int}
        @test 0 in small  # 0 is always in semigroup
        @test 3 in small  # multiplicity
        
        # Test multiplicity function works on semigroup
        @test multiplicity(S) == 3
    end
    
    @testset "Consistency between NumericalSet and NumericalSemigroup" begin
        # Create semigroup and corresponding numerical set with same gaps
        S = semigroup_from_generators([3, 5])
        ns = NumericalSet(collect(S.gaps))
        
        # Both should give same results for shared functions
        @test gaps(S) == gaps(ns)
        @test frobenius_number(S) == frobenius_number(ns)
        @test small_elements(S) == small_elements(ns)
        @test multiplicity(S) == multiplicity(ns)
        @test partition(S) == partition(ns)
        @test atom_monoid_gaps(S) == atom_monoid_gaps(ns)
    end
    
    @testset "AbstractNumericalSet type hierarchy" begin
        S = semigroup_from_generators([3, 5])
        ns = NumericalSet([1, 2, 4, 7])
        
        # Both should be AbstractNumericalSet
        @test S isa AbstractNumericalSet
        @test ns isa AbstractNumericalSet
        
        # But different concrete types
        @test S isa NumericalSemigroup
        @test ns isa NumericalSet
    end
    
    @testset "Edge cases" begin
        # Semigroup <1> has no gaps
        S1 = semigroup_from_generators([1])
        @test isempty(gaps(S1))
        @test frobenius_number(S1) == -1
        @test small_elements(S1) == Int[]
        @test partition(S1) == Int[]
        @test atom_monoid_gaps(S1) == Set{Int}()
        
        # Large genus semigroup
        S_large = semigroup_from_generators([11, 13])
        @test length(gaps(S_large)) > 50
        @test frobenius_number(S_large) == 11*13 - 11 - 13  # 119
        @test multiplicity(S_large) == 11
    end
end
