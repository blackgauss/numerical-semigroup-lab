using Test
using NumericalSemigroupLab

@testset "NumericalSemigroupLab" begin
    # Core data structures
    include("test_partitions.jl")
    include("test_numerical_sets.jl")
    include("test_semigroups.jl")
    
    # Advanced features
    include("test_posets.jl")
    include("test_weights.jl")
    include("test_tree.jl")
    include("test_special_gaps.jl")
    
    # Utilities
    include("test_utilities.jl")
end
