"""
    NumericalSemigroupLab

A high-performance Julia package for computing with numerical semigroups, 
numerical sets, and integer partitions.

This package provides:
- Fast algorithms for numerical semigroup computations
- Efficient data structures optimized for performance
- Clean API suitable for Python interoperability
- Comprehensive testing and benchmarking

# Main Types
- `NumericalSet`: A numerical set defined by its gaps
- `NumericalSemigroup`: A numerical semigroup (closed under addition)
- `Partition`: An integer partition

# Quick Start
```julia
using NumericalSemigroupLab

# Create a numerical semigroup from generators
S = NumericalSemigroup(generators=[3, 5, 7])

# Access properties
genus(S)           # Number of gaps
frobenius_number(S)  # Largest gap

# Compute minimal generators
minimal_generating_set(S)

# Create from gaps
S2 = NumericalSemigroup(gaps=[1, 2, 4, 5, 7, 8])
```
"""
module NumericalSemigroupLab

# Core types and functionality
include("core/types.jl")
include("utils/helpers.jl")
include("utils/validation.jl")
include("utils/cache.jl")

# Core implementations
include("core/partition.jl")
include("core/numerical_set.jl")
include("core/numerical_semigroup.jl")  # Define type before algorithms

# Algorithm implementations (depend on types)
include("algorithms/gaps.jl")
include("algorithms/apery.jl")
include("algorithms/minimalgenerators.jl")

# Semigroup constructors (depend on algorithms)
include("core/semigroup_constructors.jl")

# Advanced features
include("advanced/poset.jl")
include("advanced/weights.jl")
include("advanced/tree_navigation.jl")
include("advanced/special_gaps.jl")

# Exports - Core Types
export AbstractNumericalSet,
       NumericalSet,
       NumericalSemigroup,
       Partition,
       Poset

# Exports - NumericalSet methods
export gaps,
       frobenius_number,
       atom_monoid_gaps,
       partition,
       small_elements,
       multiplicity

# Exports - NumericalSemigroup methods
export genus,
       minimal_generating_set,
       generators,
       embedding_dimension,
       is_minimal_generator,
       apery_set,
       elements_up_to,
       compute_gaps_from_generators,
       semigroup_from_generators,
       semigroup_from_gaps,
       clear_apery_cache!

# Exports - Poset methods
export cover_relations,
       add_element,
       add_relation,
       minimal_elements,
       maximal_elements,
       gap_poset,
       void,
       void_poset,
       pseudofrobenius_numbers,
       type_semigroup

# Exports - Weight computations
export effective_weight,
       apery_weight,
       kunz_coordinates,
       depth,
       delta_set,
       catenary_degree

# Exports - Tree navigation
export get_parent,
       get_children,
       effective_generators,
       remove_minimal_generator,
       genus_path,
       ancestors,
       descendants

# Exports - Special gaps
export special_gaps,
       is_symmetric,
       is_pseudo_symmetric,
       add_specialgap,
       get_frobchildren,
       left_primitive,
       right_primitive,
       almost_symmetric_gaps,
       fundamental_gaps,
       forced_gaps

# Exports - Partition methods
export conjugate,
       hook_lengths,
       profile,
       atom_partition,
       is_semigroup

# Exports - Utility functions
export clear_all_caches!

end # module
