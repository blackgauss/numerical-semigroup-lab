# Tests for weight computations (Kunz coordinates, Apéry weight, etc.)

using Test
using NumericalSemigroupLab

@testset "Weights" begin
    
    @testset "Effective weight" begin
        S = NumericalSemigroup([3, 5])
        
        # 6 = 3 + 3, effective weight is 1
        @test effective_weight(S, 6) == 1
        
        # Gap 1 cannot be sum of two positive elements in S
        @test effective_weight(S, 1) == 0
        
        # Dictionary form
        weights = effective_weight(S)
        @test weights isa Dict{Int, Int}
        @test haskey(weights, 7)
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
