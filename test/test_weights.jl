# Tests for weight computations (Kunz coordinates, Apéry weight, etc.)

using Test
using NumericalSemigroupLab

@testset "Weights" begin
    
    @testset "Effective weight" begin
        S = NumericalSemigroup([3, 5])
        # Gaps are [1, 2, 4, 7], Frobenius = 7
        
        # ew(3) = #{gaps > 3} = #{4, 7} = 2
        @test effective_weight(S, 3) == 2
        
        # ew(5) = #{gaps > 5} = #{7} = 1
        @test effective_weight(S, 5) == 1
        
        # Non-generator returns 0
        @test effective_weight(S, 6) == 0
        @test effective_weight(S, 1) == 0
        
        # Total effective weight of semigroup
        @test effective_weight(S) == 3  # ew(3) + ew(5) = 2 + 1
        
        # Another example
        S2 = NumericalSemigroup([4, 5, 6])
        # Gaps are [1, 2, 3, 7]
        # ew(4) = #{7} = 1, ew(5) = #{7} = 1, ew(6) = #{7} = 1
        @test effective_weight(S2, 4) == 1
        @test effective_weight(S2, 5) == 1
        @test effective_weight(S2, 6) == 1
        @test effective_weight(S2) == 3
    end
    
    @testset "Apéry weight" begin
        S = NumericalSemigroup([3, 5])
        
        # Apéry set mod 3 is [0, 5, 10]
        # Weights are floor.([0, 5, 10] ./ 3) = [0, 1, 3]
        weights = apery_weight(S, 3)
        @test 0 in weights
        @test 1 in weights
        @test 3 in weights
    end
    
    @testset "Kunz coordinates" begin
        S = NumericalSemigroup([3, 5])
        coords = kunz_coordinates(S)
        
        # For multiplicity 3, should have 2 coordinates
        @test length(coords) == 2
        @test all(c -> c >= 0, coords)
        
        # Different semigroup
        S2 = NumericalSemigroup([4, 5, 6])
        coords2 = kunz_coordinates(S2)
        @test length(coords2) == 3  # multiplicity - 1
    end
    
    @testset "Depth" begin
        S = NumericalSemigroup([3, 5])
        d = depth(S)
        
        @test d >= 0
        @test d == maximum(kunz_coordinates(S))
        
        # Trivial semigroup has depth 0
        S0 = NumericalSemigroup([1])
        @test depth(S0) == 0
    end
    
    @testset "Delta set" begin
        S = NumericalSemigroup([3, 5])
        deltas = delta_set(S)
        
        @test deltas isa Vector{Int}
        @test !isempty(deltas)
        @test all(d -> d > 0, deltas)
    end
    
    @testset "Consistency" begin
        # Kunz coordinates determine the semigroup
        S1 = NumericalSemigroup([3, 5])
        S2 = NumericalSemigroup([3, 7])
        
        @test kunz_coordinates(S1) != kunz_coordinates(S2)
        
        # Same semigroup, same Kunz coords
        S3 = semigroup_from_gaps([1, 2, 4, 7])
        @test kunz_coordinates(S1) == kunz_coordinates(S3)
    end
    
end
