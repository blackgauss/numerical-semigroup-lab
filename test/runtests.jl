using Test
using NumericalSemigroupLab

@testset "NumericalSemigroupLab All Tests" begin
    # Phase 1: Core data structures
    include("test_phase1.jl")
    
    # Phase 2: Numerical semigroups from generators
    include("test_phase2.jl")
    
    # Phase 3: Advanced features (posets, weights, tree navigation, special gaps)
    include("test_phase3.jl")
end
