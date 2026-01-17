# Tests for utility functions and caching

using Test
using NumericalSemigroupLab

@testset "Utilities" begin
    
    @testset "Helper functions" begin
        # Flatten
        @test NumericalSemigroupLab.flatten([[1, 2], [3, 4]]) == [1, 2, 3, 4]
        @test NumericalSemigroupLab.flatten([[1], [2], [3]]) == [1, 2, 3]
        @test NumericalSemigroupLab.flatten([Int[]]) == Int[]
        
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
        @test sum(parts) == sum(conj)
    end
    
    @testset "Cache management" begin
        clear_all_caches!()
        
        # Initially empty
        stats = NumericalSemigroupLab.cache_stats()
        @test stats.hooks.size == 0
        @test stats.conjugate.size == 0
        
        # Populate caches
        p = Partition([5, 4, 3, 1])
        hook_lengths(p)
        conjugate(p)
        
        stats = NumericalSemigroupLab.cache_stats()
        @test stats.hooks.size > 0
        @test stats.conjugate.size > 0
        
        # Clear all
        clear_all_caches!()
        stats = NumericalSemigroupLab.cache_stats()
        @test stats.hooks.size == 0
        @test stats.conjugate.size == 0
    end
    
    @testset "Apéry cache" begin
        clear_apery_cache!()
        
        S = NumericalSemigroup([3, 5])
        ap1 = apery_set(S, 3)
        ap2 = apery_set(S, 3)
        
        @test ap1 == ap2
        
        clear_apery_cache!()
        ap3 = apery_set(S, 3)
        @test ap1 == ap3
    end
    
    @testset "Validation helpers" begin
        # These are internal but we test behavior through public API
        
        # Non-positive parts rejected
        @test_throws ArgumentError Partition([0, 1])
        @test_throws ArgumentError Partition([-1, 2])
        
        # Empty generators rejected
        @test_throws ArgumentError compute_gaps_from_generators(Int[])
        
        # Non-coprime rejected
        @test_throws ArgumentError compute_gaps_from_generators([4, 6])
    end
    
end
