# Tests for tree navigation (parent, children, ancestors, descendants)

using Test
using NumericalSemigroupLab

@testset "Tree Navigation" begin
    
    @testset "Parent" begin
        S = NumericalSemigroup([3, 5])
        P = get_parent(S)
        
        @test P !== nothing
        @test genus(P) == genus(S) - 1
        @test P.frobenius < S.frobenius
        @test S.frobenius ∉ P.gaps
    end
    
    @testset "Parent of ℕ₀" begin
        S = NumericalSemigroup([1])
        P = get_parent(S)
        @test P === nothing
    end
    
    @testset "Children" begin
        S = NumericalSemigroup([3, 5])
        children = get_children(S)
        
        @test children isa Vector{NumericalSemigroup}
        
        for child in children
            @test genus(child) == genus(S) + 1
        end
    end
    
    @testset "Children of ℕ₀" begin
        S = NumericalSemigroup([1])
        children = get_children(S)
        
        # Only child is {1} removed, giving gaps = [1]
        @test length(children) == 1
        @test genus(children[1]) == 1
    end
    
    @testset "Genus path" begin
        S = NumericalSemigroup([3, 5])
        path = genus_path(S)
        
        # Path starts with S
        @test path[1] == S
        
        # Path ends with ℕ₀
        @test genus(path[end]) == 0
        
        # Length = genus + 1
        @test length(path) == genus(S) + 1
        
        # Each step reduces genus by 1
        for i in 1:(length(path)-1)
            @test genus(path[i]) == genus(path[i+1]) + 1
        end
    end
    
    @testset "Ancestors" begin
        S = NumericalSemigroup([3, 5])
        anc = ancestors(S, 2)
        
        @test length(anc) == 2
        @test genus(anc[1]) == genus(S) - 1
        @test genus(anc[2]) == genus(S) - 2
        
        # Full ancestors (up to genus)
        all_anc = ancestors(S, genus(S))
        @test length(all_anc) == genus(S)
    end
    
    @testset "Descendants" begin
        S = NumericalSemigroup([3, 5])
        desc = descendants(S, 2)
        
        # All descendants should have genus > genus(S)
        for d in desc
            @test genus(d) > genus(S)
            @test genus(d) <= genus(S) + 2
        end
    end
    
    @testset "Effective generators" begin
        S = NumericalSemigroup([3, 5])
        eff = effective_generators(S)
        
        @test eff isa Vector{Int}
        # All effective generators are in the semigroup
        for g in eff
            @test g in S
        end
    end
    
    @testset "Remove minimal generator" begin
        S = NumericalSemigroup([3, 5, 7])
        
        @test is_minimal_generator(S, 7)
        T = remove_minimal_generator(S, 7)
        
        @test 7 ∉ T.generators
        @test T == NumericalSemigroup([3, 5])
    end
    
    @testset "Parent-child consistency" begin
        S = NumericalSemigroup([5, 7])
        P = get_parent(S)
        
        @test P !== nothing
        
        children = get_children(P)
        # S should be among the children of its parent
        @test any(c -> c.gaps == S.gaps, children)
    end
    
    @testset "Tree structure" begin
        # Start from ℕ₀ and explore the tree
        N0 = NumericalSemigroup([1])
        @test genus(N0) == 0
        
        # Get genus-1 semigroups
        gen1 = get_children(N0)
        @test length(gen1) == 1
        @test genus(gen1[1]) == 1
        
        # Get genus-2 semigroups
        gen2 = get_children(gen1[1])
        @test all(s -> genus(s) == 2, gen2)
    end
    
end
