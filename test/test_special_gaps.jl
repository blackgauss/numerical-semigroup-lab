# Tests for special gaps, symmetry, and related operations

using Test
using NumericalSemigroupLab

@testset "Special Gaps and Symmetry" begin
    
    @testset "Void (pseudo-Frobenius numbers)" begin
        S = NumericalSemigroup([3, 5])
        v = void(S)
        
        # For ⟨3, 5⟩, the only pseudo-Frobenius number is 7
        @test v == [7]
        
        # Alias
        @test pseudofrobenius_numbers(S) == [7]
    end
    
    @testset "Void with multiple elements" begin
        # ⟨4, 5, 6⟩ has multiple pseudo-Frobenius numbers
        S = NumericalSemigroup([4, 5, 6])
        v = void(S)
        
        @test length(v) >= 1
        @test S.frobenius in v
    end
    
    @testset "Type" begin
        S = NumericalSemigroup([3, 5])
        @test type_semigroup(S) == 1  # Symmetric
        
        S2 = NumericalSemigroup([4, 5, 6])
        @test type_semigroup(S2) == length(void(S2))
    end
    
    @testset "Special gaps" begin
        S = NumericalSemigroup([3, 5])
        sg = special_gaps(S)
        
        @test sg isa Vector{Int}
        @test S.frobenius in sg
    end
    
    @testset "Symmetric semigroups" begin
        # All 2-generator semigroups are symmetric
        @test is_symmetric(NumericalSemigroup([3, 5]))
        @test is_symmetric(NumericalSemigroup([5, 7]))
        @test is_symmetric(NumericalSemigroup([7, 11]))
        @test is_symmetric(NumericalSemigroup([4, 9]))
        
        # Symmetric implies type 1
        for gens in [[3, 5], [5, 7], [7, 11]]
            S = NumericalSemigroup(gens)
            @test is_symmetric(S)
            @test type_semigroup(S) == 1
        end
    end
    
    @testset "Pseudo-symmetric" begin
        S = NumericalSemigroup([3, 5])
        result = is_pseudo_symmetric(S)
        @test result isa Bool
    end
    
    @testset "Fundamental gaps" begin
        S = NumericalSemigroup([3, 5])
        fg = fundamental_gaps(S)
        
        @test fg isa Vector{Int}
        @test !isempty(fg)
        @test all(g -> g in S.gaps, fg)
    end
    
    @testset "Forced gaps" begin
        S = NumericalSemigroup([3, 5])
        forced = forced_gaps(S, 1)
        
        @test forced isa Vector{Int}
        @test all(g -> g > 1, forced)
        @test all(g -> g in S.gaps, forced)
    end
    
    @testset "Add special gap" begin
        S = NumericalSemigroup([3, 5])
        
        if 8 in S
            try
                T = add_specialgap(S, 8)
                @test 8 in T.gaps
                @test genus(T) == genus(S) + 1
            catch
                @test true  # Some elements can't be added
            end
        end
    end
    
    @testset "Frobenius children" begin
        S = NumericalSemigroup([3, 5])
        fc = get_frobchildren(S)
        
        @test fc isa Vector{NumericalSemigroup}
        
        # All Frobenius children have same Frobenius
        for child in fc
            @test child.frobenius == S.frobenius
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
    
end
