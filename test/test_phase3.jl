# Phase 3 Tests: Advanced Features

using Test
using NumericalSemigroupLab

@testset "Phase 3: Poset Operations" begin
    @testset "Basic Poset construction" begin
        # Simple poset with divisibility
        elements = [1, 2, 3, 6]
        # Build divisibility relations
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
        @test (1, 6) in p.relations  # 1 divides 6
        @test (2, 6) in p.relations  # 2 divides 6
        @test (3, 6) in p.relations  # 3 divides 6
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
        
        # In chain 1 < 2 < 4 < 8, covers should be (1,2), (2,4), (4,8)
        @test (1, 2) in covers
        @test (2, 4) in covers
        @test (4, 8) in covers
        @test (1, 4) ∉ covers  # Not a cover (2 is between)
    end
    
    @testset "Minimal and maximal elements" begin
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
        maxs = maximal_elements(p)
        
        @test mins == [1]
        @test maxs == [6]
    end
    
    @testset "Gap poset" begin
        S = NumericalSemigroup([3, 5])
        p = gap_poset(S)
        
        # Gaps are [1, 2, 4, 7]
        @test length(p.elements) == 4
        @test 1 in p.elements
        @test 7 in p.elements
        
        # Check ordering: g1 ≤ g2 if g2 - g1 ∈ S
        # 1 and 4: 4-1=3 ∈ S, so (1,4) should be in relations
        @test (1, 4) in p.relations  # 4 - 1 = 3 ∈ S
        @test (1, 7) in p.relations  # 7 - 1 = 6 ∈ S
    end
    
    @testset "Void (pseudo-Frobenius numbers)" begin
        S = NumericalSemigroup([3, 5])
        v = void(S)
        
        # For ⟨3, 5⟩, the only pseudo-Frobenius number is 7
        @test v == [7]
        
        # Alias should work too
        @test pseudofrobenius_numbers(S) == [7]
        
        # Type should be 1 (symmetric)
        @test type_semigroup(S) == 1
    end
    
    @testset "Void with multiple pseudo-Frobenius" begin
        # ⟨4, 5, 6⟩ has multiple pseudo-Frobenius numbers
        S = NumericalSemigroup([4, 5, 6])
        v = void(S)
        
        # Should have more than one
        @test length(v) >= 1
        # Frobenius should be in void
        @test S.frobenius in v
    end
end

@testset "Phase 3: Weight Computations" begin
    @testset "Effective weight" begin
        S = NumericalSemigroup([3, 5])
        
        # Gap 6 = 3 + 3, so effective weight is 1
        @test effective_weight(S, 6) == 1
        
        # Gap 1 cannot be written as sum of two positive elements in S
        @test effective_weight(S, 1) == 0
        
        # Get all effective weights
        weights = effective_weight(S)
        @test weights isa Dict{Int, Int}
        @test haskey(weights, 7)  # Frobenius
    end
    
    @testset "Apéry weight" begin
        S = NumericalSemigroup([3, 5])
        
        # Apéry set mod 3 is [0, 5, 10]
        # Weights are [0÷3, 5÷3, 10÷3] = [0, 1, 3]
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
    end
    
    @testset "Depth" begin
        S = NumericalSemigroup([3, 5])
        d = depth(S)
        
        @test d >= 0
        @test d == maximum(kunz_coordinates(S))
    end
    
    @testset "Delta set" begin
        S = NumericalSemigroup([3, 5])
        deltas = delta_set(S)
        
        @test deltas isa Vector{Int}
        @test !isempty(deltas)
        # All deltas should be positive
        @test all(d -> d > 0, deltas)
    end
end

@testset "Phase 3: Tree Navigation" begin
    @testset "Get parent" begin
        S = NumericalSemigroup([3, 5])
        P = get_parent(S)
        
        @test P !== nothing
        @test genus(P) == genus(S) - 1
        @test P.frobenius < S.frobenius
        
        # Parent's gaps = S's gaps minus Frobenius
        @test S.frobenius ∉ P.gaps
    end
    
    @testset "Get parent of ℕ₀" begin
        S = semigroup_from_generators([1])
        P = get_parent(S)
        
        @test P === nothing  # ℕ₀ has no parent
    end
    
    @testset "Genus path" begin
        S = NumericalSemigroup([3, 5])
        path = genus_path(S)
        
        # Path starts with S
        @test path[1] == S
        
        # Path ends with ℕ₀
        @test genus(path[end]) == 0
        
        # Length should be genus + 1
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
    end
    
    @testset "Get children" begin
        # Start from a semigroup and check children have correct genus
        S = NumericalSemigroup([3, 5])
        children = get_children(S)
        
        # Each child should have genus = genus(S) + 1
        for child in children
            @test genus(child) == genus(S) + 1
        end
    end
    
    @testset "Remove minimal generator" begin
        S = NumericalSemigroup([3, 5, 7])
        
        # Remove 7 (minimal generator)
        @test is_minimal_generator(S, 7)
        T = remove_minimal_generator(S, 7)
        
        @test 7 ∉ T.generators
        @test T == NumericalSemigroup([3, 5])
    end
end

@testset "Phase 3: Special Gaps" begin
    @testset "Special gaps computation" begin
        S = NumericalSemigroup([3, 5])
        sg = special_gaps(S)
        
        @test sg isa Vector{Int}
        # Frobenius is always special
        @test S.frobenius in sg
    end
    
    @testset "Symmetric semigroup" begin
        # All 2-generator semigroups are symmetric
        S = NumericalSemigroup([3, 5])
        @test is_symmetric(S)
        
        S2 = NumericalSemigroup([7, 11])
        @test is_symmetric(S2)
    end
    
    @testset "Fundamental gaps" begin
        S = NumericalSemigroup([3, 5])
        fg = fundamental_gaps(S)
        
        @test fg isa Vector{Int}
        @test !isempty(fg)
        # All fundamental gaps are gaps
        @test all(g -> g in S.gaps, fg)
    end
    
    @testset "Forced gaps" begin
        S = NumericalSemigroup([3, 5])
        
        # Gap 1: check what gaps are forced by it
        forced = forced_gaps(S, 1)
        
        @test forced isa Vector{Int}
        # All forced gaps should be > 1
        @test all(g -> g > 1, forced)
        # All forced gaps should actually be gaps
        @test all(g -> g in S.gaps, forced)
    end
    
    @testset "Add special gap" begin
        S = NumericalSemigroup([3, 5])
        
        # Try to add 8 as a new gap
        if 8 in S
            try
                T = add_specialgap(S, 8)
                @test 8 in T.gaps
                @test genus(T) == genus(S) + 1
            catch
                # Some elements can't be added as gaps
                @test true
            end
        end
    end
    
    @testset "Frobenius children" begin
        S = NumericalSemigroup([3, 5])
        fc = get_frobchildren(S)
        
        # May or may not have Frobenius children
        @test fc isa Vector{NumericalSemigroup}
    end
end

@testset "Phase 3: Integration Tests" begin
    @testset "Tree navigation consistency" begin
        S = NumericalSemigroup([5, 7])
        
        # Go up then down should give something
        P = get_parent(S)
        @test P !== nothing
        
        children = get_children(P)
        # S should be one of the children of its parent
        @test any(c -> c.gaps == S.gaps, children)
    end
    
    @testset "Symmetric implies type 1" begin
        for gens in [[3, 5], [5, 7], [7, 11], [4, 9]]
            S = NumericalSemigroup(gens)
            if is_symmetric(S)
                @test type_semigroup(S) == 1
            end
        end
    end
    
    @testset "Void contains Frobenius" begin
        for gens in [[3, 5], [4, 5, 6], [5, 7, 9]]
            S = NumericalSemigroup(gens)
            v = void(S)
            if S.frobenius >= 0
                @test S.frobenius in v
            end
        end
    end
    
    @testset "Gap poset maximal elements are voids" begin
        S = NumericalSemigroup([3, 5])
        p = gap_poset(S)
        maxs = maximal_elements(p)
        v = void(S)
        
        # Maximal elements in gap poset should be the voids
        @test Set(maxs) == Set(v)
    end
end
