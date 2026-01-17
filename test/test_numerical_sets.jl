# Tests for NumericalSet type and operations

using Test
using NumericalSemigroupLab

@testset "Numerical Sets" begin
    
    @testset "Construction" begin
        ns = NumericalSet([1, 2, 4, 5])
        @test ns.frobenius_number == 5
        @test 1 in ns.gaps
        @test 2 in ns.gaps
        @test 4 in ns.gaps
        @test 5 in ns.gaps
        @test 3 ∉ ns.gaps
        
        # Unsorted input is handled
        ns2 = NumericalSet([5, 2, 1, 4])
        @test ns2.frobenius_number == 5
    end
    
    @testset "Empty gaps" begin
        ns = NumericalSet(Int[])
        @test ns.frobenius_number == -1
        @test isempty(ns.gaps)
    end
    
    @testset "Accessors" begin
        ns = NumericalSet([1, 2, 4, 5, 7])
        
        @test frobenius_number(ns) == 7
        @test length(gaps(ns)) == 5
        @test gaps(ns) isa BitSet
    end
    
    @testset "Small elements" begin
        ns = NumericalSet([1, 2, 4, 5, 7])
        small = small_elements(ns)
        
        @test 0 in small
        @test 3 in small
        @test 6 in small
        @test !(1 in small)
        @test !(7 in small)
    end
    
    @testset "Multiplicity" begin
        ns = NumericalSet([1, 2, 4, 5, 7])
        @test multiplicity(ns) == 3  # Smallest positive non-gap
        
        ns2 = NumericalSet([1, 3, 5])
        @test multiplicity(ns2) == 2
        
        # No gaps means multiplicity is 1
        ns3 = NumericalSet(Int[])
        @test multiplicity(ns3) == 1
    end
    
    @testset "Partition bijection" begin
        ns = NumericalSet([1, 2, 4, 5, 7])
        p = partition(ns)
        
        @test p isa Vector{Int}
        @test length(p) > 0
        @test all(x -> x > 0, p)
    end
    
    @testset "Atom monoid gaps" begin
        ns = NumericalSet([1, 2, 4, 5, 7])
        atom = atom_monoid_gaps(ns)
        
        @test atom isa Set{Int}
        @test !isempty(atom)
    end
    
    @testset "Bijection round-trip" begin
        test_gaps = [
            [1, 2, 3],
            [1, 2, 4, 5],
            [1, 3, 5, 7, 9],
            [1, 2, 4, 7],
        ]
        
        for gaps_list in test_gaps
            ns = NumericalSet(gaps_list)
            p_parts = partition(ns)
            p = Partition(p_parts)
            gaps_back = sort(collect(gaps(p)))
            
            @test gaps_back == sort(gaps_list)
        end
    end
    
    @testset "AbstractNumericalSet interface" begin
        ns = NumericalSet([1, 2, 4, 7])
        
        @test ns isa AbstractNumericalSet
        @test gaps(ns) isa BitSet
        @test frobenius_number(ns) == 7
        @test multiplicity(ns) == 3
    end
    
end
