"""
Core type definitions for numerical semigroups and partitions.

This file defines the abstract and concrete types used throughout the package.
All types are designed for:
- Type stability (concrete field types)
- Performance (immutable where possible)
- Memory efficiency (compact representations)
"""

"""
    AbstractNumericalSet

Abstract supertype for numerical sets and semigroups.

A numerical set is a subset of ℕ (non-negative integers) that is cofinite
(has finite complement). It is typically represented by its gaps (elements not in the set).
"""
abstract type AbstractNumericalSet end

"""
    NumericalSet

A numerical set represented by its gaps.

# Fields
- `gaps::BitSet`: The set of non-negative integers not in the numerical set
- `frobenius_number::Int`: The largest gap (maximum element in gaps)

# Constructor
    NumericalSet(gaps)

Create a numerical set from an iterable of gaps.

# Examples
```julia
ns = NumericalSet([1, 2, 4, 5, 7])
gaps(ns)  # BitSet with elements {1, 2, 4, 5, 7}
frobenius_number(ns)  # 7
```
"""
struct NumericalSet <: AbstractNumericalSet
    gaps::BitSet
    frobenius_number::Int
    
    function NumericalSet(gap_iter)
        gap_set = BitSet(gap_iter)
        if isempty(gap_set)
            frob = -1
        else
            frob = maximum(gap_set)
        end
        new(gap_set, frob)
    end
end

"""
    Partition

An integer partition represented as a vector of non-increasing positive integers.

# Fields
- `parts::Vector{Int}`: The parts of the partition in non-increasing order

# Constructor
    Partition(parts)

Create a partition from a vector of positive integers.
The vector will be sorted in non-increasing order if needed.

# Examples
```julia
p = Partition([5, 4, 3, 1])
p.parts  # [5, 4, 3, 1]

# Auto-sorts if needed
p2 = Partition([1, 3, 5, 4])
p2.parts  # [5, 4, 3, 1]
```
"""
struct Partition
    parts::Vector{Int}
    
    function Partition(parts_vec::AbstractVector{Int})
        # Validate: all positive integers
        if !all(p -> p > 0, parts_vec)
            throw(ArgumentError("All partition parts must be positive integers"))
        end
        
        # Sort in non-increasing order
        sorted_parts = sort(collect(parts_vec), rev=true)
        
        new(sorted_parts)
    end
end

"""
    Poset{T}

A partially ordered set (poset) with elements of type T.

# Fields
- `elements::Set{T}`: The elements of the poset
- `relations::Set{Tuple{T,T}}`: The order relations (a,b) meaning a ≤ b

# Constructor
    Poset(elements, relations)

Create a poset from elements and relations.
Validates that the relations form a valid partial order (reflexive, antisymmetric, transitive).

# Examples
```julia
elements = [1, 2, 3, 4]
relations = [(1,1), (2,2), (3,3), (4,4),  # reflexive
             (1,2), (1,3), (1,4),          # 1 is below all
             (2,4), (3,4)]                 # 2,3 both below 4

poset = Poset(elements, relations)
```
"""
struct Poset{T}
    elements::Set{T}
    relations::Set{Tuple{T,T}}
    
    function Poset(elem_iter, rel_iter)
        elem_set = Set(elem_iter)
        rel_set = Set(Tuple{eltype(elem_set), eltype(elem_set)}[(a,b) for (a,b) in rel_iter])
        
        # Validate poset properties
        validate_poset_properties(elem_set, rel_set)
        
        new{eltype(elem_set)}(elem_set, rel_set)
    end
end

# Validation function for posets (defined in validation.jl)
# Declared here to avoid forward reference issues
function validate_poset_properties end

