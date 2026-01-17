# Tests for NumericalSemigroup type and core operations

using Test
using NumericalSemigroupLab

@testset "Numerical Semigroups" begin
    
    @testset "Gap computation from generators" begin
        @testset "Two-generator semigroups" begin
            # Classic: ⟨3, 5⟩
            gaps = compute_gaps_from_generators([3, 5])
            @test gaps == [1, 2, 4, 7]
            @test length(gaps) == 4  # genus
            @test maximum(gaps) == 7  # Frobenius = 3*5 - 3 - 5
            
            # ⟨7, 11⟩
            gaps = compute_gaps_from_generators([7, 11])
            @test maximum(gaps) == 7*11 - 7 - 11  # 59
            @test length(gaps) == (7-1)*(11-1)÷2  # genus = 30
            
            # ⟨2, 3⟩
            gaps = compute_gaps_from_generators([2, 3])
            @test gaps == [1]
        end
        
        @testset "Three or more generators" begin
            # ⟨3, 4, 5⟩
            gaps = compute_gaps_from_generators([3, 4, 5])
            @test 1 in gaps
            @test 2 in gaps
            @test maximum(gaps) < 10
            
            # ⟨5, 7, 11⟩
            gaps = compute_gaps_from_generators([5, 7, 11])
            @test 1 in gaps
            @test maximum(gaps) > 10
        end
        
        @testset "Special cases" begin
            # ⟨1⟩ has no gaps
            gaps = compute_gaps_from_generators([1])
            @test isempty(gaps)
            
            # Duplicate generators ignored
            gaps = compute_gaps_from_generators([3, 5, 3, 5])
            @test gaps == [1, 2, 4, 7]
        end
        
        @testset "Validation" begin
            @test_throws ArgumentError compute_gaps_from_generators(Int[])
            @test_throws ArgumentError compute_gaps_from_generators([3, 0, 5])
            @test_throws ArgumentError compute_gaps_from_generators([-1, 5])
            @test_throws ArgumentError compute_gaps_from_generators([4, 6])  # gcd != 1
        end
    end
    
    @testset "Construction" begin
        @testset "From generators" begin
            S = NumericalSemigroup([3, 5])
            @test S.frobenius == 7
            @test S.genus == 4
            @test S.multiplicity == 3
            @test 3 in S.generators
            @test 5 in S.generators
        end
        
        @testset "From gaps" begin
            S = semigroup_from_gaps([1, 2, 4, 7])
            @test S.frobenius == 7
            @test S.genus == 4
            @test S.multiplicity == 3
        end
        
        @testset "Trivial semigroup ⟨1⟩" begin
            S = NumericalSemigroup([1])
            @test S.genus == 0
            @test S.frobenius == -1
            @test S.multiplicity == 1
        end
    end
    
    @testset "Accessors" begin
        S = NumericalSemigroup([3, 5])
        
        @test genus(S) == 4
        @test frobenius_number(S) == 7
        @test multiplicity(S) == 3
        @test embedding_dimension(S) == 2
        
        gens = generators(S)
        @test 3 in gens
        @test 5 in gens
    end
    
    @testset "Membership" begin
        S = NumericalSemigroup([3, 5])
        
        # 0 always in semigroup
        @test 0 in S
        
        # Generators in S
        @test 3 in S
        @test 5 in S
        
        # Gaps not in S
        @test !(1 in S)
        @test !(2 in S)
        @test !(4 in S)
        @test !(7 in S)
        
        # Sums of generators
        @test 6 in S   # 3+3
        @test 8 in S   # 3+5
        @test 9 in S   # 3+3+3
        @test 10 in S  # 5+5
        
        # Everything beyond Frobenius is in S
        for n in 8:20
            @test n in S
        end
        
        # Negative numbers not in S
        @test !(-1 in S)
        @test !(-10 in S)
    end
    
    @testset "Elements generation" begin
        S = NumericalSemigroup([3, 5])
        
        elems = elements_up_to(S, 10)
        @test 0 in elems
        @test 3 in elems
        @test 5 in elems
        @test 6 in elems
        @test !(1 in elems)
        @test !(4 in elems)
        
        @test elements_up_to(S, 5) == [0, 3, 5]
        @test elements_up_to(S, 0) == [0]
        @test isempty(elements_up_to(S, -5))
    end
    
    @testset "Apéry sets" begin
        S = NumericalSemigroup([3, 5])
        
        # Apéry set mod 3
        ap = apery_set(S, 3)
        @test length(ap) == 3
        @test ap[1] == 0
        @test all(a -> a in S, ap)
        @test ap[1] % 3 == 0
        @test ap[2] % 3 == 1
        @test ap[3] % 3 == 2
        
        # Default uses multiplicity
        ap_default = apery_set(S)
        @test length(ap_default) == 3
        
        # Apéry set mod 5
        ap5 = apery_set(S, 5)
        @test length(ap5) == 5
        @test ap5[1] == 0
        
        # Validation
        @test_throws ArgumentError apery_set(S, 0)
        @test_throws ArgumentError apery_set(S, -1)
        @test_throws ArgumentError apery_set(S, 2)  # 2 is a gap
    end
    
    @testset "Minimal generators" begin
        S = NumericalSemigroup([3, 5])
        
        @test is_minimal_generator(S, 3)
        @test is_minimal_generator(S, 5)
        @test !is_minimal_generator(S, 6)   # 3+3
        @test !is_minimal_generator(S, 8)   # 3+5
        @test !is_minimal_generator(S, 1)   # gap
        @test !is_minimal_generator(S, 0)
        
        gens = minimal_generating_set(S)
        @test 3 in gens
        @test 5 in gens
        @test length(gens) == 2
        
        # Redundant generators removed
        S2 = NumericalSemigroup([3, 5, 8])  # 8 = 3+5
        gens2 = minimal_generating_set(S2)
        @test 3 in gens2
        @test 5 in gens2
    end
    
    @testset "Equality and hashing" begin
        S1 = NumericalSemigroup([3, 5])
        S2 = NumericalSemigroup([3, 5])
        S3 = semigroup_from_gaps([1, 2, 4, 7])
        S4 = NumericalSemigroup([7, 11])
        
        @test S1 == S2
        @test S1 == S3  # Same gaps
        @test S1 != S4
        
        @test hash(S1) == hash(S2)
        @test hash(S1) == hash(S3)
        
        # Works in collections
        set = Set([S1, S2, S4])
        @test length(set) == 2
    end
    
    @testset "AbstractNumericalSet interface" begin
        S = NumericalSemigroup([3, 5])
        
        @test S isa AbstractNumericalSet
        @test gaps(S) == BitSet([1, 2, 4, 7])
        @test frobenius_number(S) == 7
        @test multiplicity(S) == 3
        @test partition(S) isa Vector{Int}
        @test small_elements(S) isa Vector{Int}
        @test atom_monoid_gaps(S) isa Set{Int}
    end
    
    @testset "Consistency with NumericalSet" begin
        S = NumericalSemigroup([3, 5])
        ns = NumericalSet(collect(S.gaps))
        
        @test gaps(S) == gaps(ns)
        @test frobenius_number(S) == frobenius_number(ns)
        @test small_elements(S) == small_elements(ns)
        @test multiplicity(S) == multiplicity(ns)
        @test partition(S) == partition(ns)
        @test atom_monoid_gaps(S) == atom_monoid_gaps(ns)
    end
    
    @testset "Display" begin
        S = NumericalSemigroup([3, 5])
        str = sprint(show, S)
        @test occursin("3", str)
        @test occursin("5", str)
        
        str_full = sprint(show, MIME"text/plain"(), S)
        @test occursin("Genus", str_full)
        @test occursin("Frobenius", str_full)
    end
    
    @testset "Round-trip consistency" begin
        original_gens = [3, 5]
        S = NumericalSemigroup(original_gens)
        gaps_vec = sort(collect(S.gaps))
        T = semigroup_from_gaps(gaps_vec)
        
        @test S == T
        @test S.frobenius == T.frobenius
        @test S.genus == T.genus
    end
    
end
