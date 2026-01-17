# Tests for Partition type and operations

using Test
using NumericalSemigroupLab

@testset "Partitions" begin
    
    @testset "Construction" begin
        # Basic construction
        p = Partition([5, 4, 3, 1])
        @test p.parts == [5, 4, 3, 1]
        
        # Auto-sorting
        p2 = Partition([1, 5, 3, 4])
        @test p2.parts == [5, 4, 3, 1]
        
        # Empty partition
        p_empty = Partition(Int[])
        @test isempty(p_empty.parts)
        
        # Single part
        p_single = Partition([7])
        @test p_single.parts == [7]
    end
    
    @testset "Validation" begin
        @test_throws ArgumentError Partition([0, 1, 2])
        @test_throws ArgumentError Partition([-1, 2, 3])
    end
    
    @testset "Conjugate" begin
        p = Partition([5, 4, 3, 1])
        conj = conjugate(p)
        @test length(conj.parts) > 0
        
        # Involution: conjugate(conjugate(p)) == p
        @test conjugate(conj).parts == p.parts
        
        # Preserves size
        @test sum(conj.parts) == sum(p.parts)
        
        # Rectangular partition
        rect = Partition([5, 5, 5])
        conj_rect = conjugate(rect)
        @test conj_rect.parts == [3, 3, 3, 3, 3]
        
        # Single row/column duality
        row = Partition([10])
        @test conjugate(row).parts == ones(Int, 10)
        
        col = Partition(ones(Int, 5))
        @test conjugate(col).parts == [5]
    end
    
    @testset "Hook lengths" begin
        p = Partition([5, 4, 3, 1])
        hooks = hook_lengths(p)
        
        # Correct dimensions
        @test length(hooks) == 4
        @test length(hooks[1]) == 5
        @test length(hooks[2]) == 4
        @test length(hooks[3]) == 3
        @test length(hooks[4]) == 1
        
        # Corner values
        @test hooks[1][1] == 8  # Top-left corner
        @test hooks[4][1] == 1  # Bottom-left corner of last row
        
        # Simple case: staircase
        stair = Partition([3, 2, 1])
        h = hook_lengths(stair)
        @test h == [[5, 3, 1], [3, 1], [1]]
    end
    
    @testset "Profile" begin
        p = Partition([3, 2, 1])
        prof = profile(p)
        
        # All moves are right or down
        @test all(move -> move == (1, 0) || move == (0, 1), prof)
        
        # Length equals sum of parts
        @test length(prof) == sum(p.parts)
    end
    
    @testset "Gaps from partition" begin
        p = Partition([5, 4, 3, 1])
        gaps_vec = gaps(p)
        @test !isempty(gaps_vec)
    end
    
    @testset "Atom partition" begin
        p = Partition([5, 4, 3, 1])
        atom = atom_partition(p)
        @test length(atom) > 0
    end
    
    @testset "Atom monoid gaps" begin
        p = Partition([5, 4, 3, 1])
        atom_gaps = atom_monoid_gaps(p)
        @test !isempty(atom_gaps)
    end
    
    @testset "Is semigroup partition" begin
        p = Partition([5, 4, 3, 1])
        result = is_semigroup(p)
        @test result isa Bool
    end
    
    @testset "Caching" begin
        clear_all_caches!()
        
        p = Partition([5, 4, 3, 1])
        
        # First call computes
        hooks1 = hook_lengths(p)
        conj1 = conjugate(p)
        
        # Cache should have entries
        stats = NumericalSemigroupLab.cache_stats()
        @test stats.hooks.size > 0
        @test stats.conjugate.size > 0
        
        # Second call uses cache (same result)
        hooks2 = hook_lengths(p)
        conj2 = conjugate(p)
        @test hooks1 == hooks2
        @test conj1.parts == conj2.parts
        
        # Clear and verify
        clear_all_caches!()
        stats = NumericalSemigroupLab.cache_stats()
        @test stats.hooks.size == 0
        @test stats.conjugate.size == 0
    end
    
end
