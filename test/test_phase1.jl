# Phase 1 Tests: Core Data Structures (NumericalSet and Partition)

using Test
using NumericalSemigroupLab

@testset "Phase 1: Type Creation" begin
    # NumericalSet
    ns = NumericalSet([1, 2, 4, 5])
    @test ns.frobenius_number == 5
    @test 1 in ns.gaps
    @test 3 ∉ ns.gaps
    
    # Partition
    p = Partition([5, 4, 3, 1])
    @test p.parts == [5, 4, 3, 1]
    
    # Auto-sorting
    p2 = Partition([1, 5, 3, 4])
    @test p2.parts == [5, 4, 3, 1]
    
    # Validation
    @test_throws ArgumentError Partition([0, 1, 2])
    @test_throws ArgumentError Partition([-1, 2, 3])
end

@testset "Phase 1: Partition Methods" begin
    p = Partition([5, 4, 3, 1])
    
    # Conjugate
    conj = conjugate(p)
    @test length(conj.parts) > 0
    
    # Hook lengths
    hooks = hook_lengths(p)
    @test length(hooks) == 4
    @test length(hooks[1]) == 5
    
    # Profile
    prof = profile(p)
    @test all(move -> move == (1,0) || move == (0,1), prof)
    
    # Atom partition
    atom = atom_partition(p)
    @test length(atom) > 0
end

@testset "Phase 1: NumericalSet Methods" begin
    ns = NumericalSet([1, 2, 4, 5, 7])
    
    # Accessors
    @test frobenius_number(ns) == 7
    @test length(gaps(ns)) == 5
    
    # Small elements
    small = small_elements(ns)
    @test 0 in small
    @test 3 in small
    @test 6 in small
    
    # Multiplicity
    @test multiplicity(ns) == 3
    
    # Partition
    p = partition(ns)
    @test length(p) > 0
    @test all(x -> x > 0, p)
    
    # Atom monoid
    atom = atom_monoid_gaps(ns)
    @test length(atom) > 0
end

@testset "Phase 1: Bijection: Partition ↔ NumericalSet" begin
    # Test cases
    test_gaps = [
        [1, 2, 3],
        [1, 2, 4, 5],
        [1, 3, 5, 7, 9],
    ]
    
    for gaps_list in test_gaps
        ns = NumericalSet(gaps_list)
        p_parts = partition(ns)
        p = Partition(p_parts)
        gaps_back = sort(collect(gaps(p)))
        
        @test gaps_back == sort(gaps_list)
    end
end

@testset "Phase 1: Caching" begin
    clear_all_caches!()
    
    # Initially empty
    stats = NumericalSemigroupLab.cache_stats()
    @test stats.hooks.size == 0
    @test stats.conjugate.size == 0
    
    # Compute something
    p = Partition([5, 4, 3, 1])
    hook_lengths(p)
    conjugate(p)
    
    # Cache should have entries
    stats = NumericalSemigroupLab.cache_stats()
    @test stats.hooks.size > 0
    @test stats.conjugate.size > 0
    
    # Clear
    clear_all_caches!()
    stats = NumericalSemigroupLab.cache_stats()
    @test stats.hooks.size == 0
    @test stats.conjugate.size == 0
end

@testset "Phase 1: Helper Functions" begin
    # Flatten
    @test NumericalSemigroupLab.flatten([[1, 2], [3, 4]]) == [1, 2, 3, 4]
    
    # Remove sums
    A = Set([2, 3, 5, 6, 7])
    result = NumericalSemigroupLab.remove_sum_of_two_elements(A)
    @test 2 in result
    @test 3 in result
    @test 5 ∉ result  # 5 = 2 + 3
    
    # Conjugate computation
    parts = [4, 3, 1]
    conj = NumericalSemigroupLab.compute_conjugate_partition(parts)
    @test length(conj) == 4
    @test sum(parts) == sum(conj)  # Same number of boxes
end
