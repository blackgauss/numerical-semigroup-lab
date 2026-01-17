"""
NumericalSet implementation with partition correspondence and atom monoid.

This file implements the NumericalSet type and all its methods including:
- Gap and frobenius number accessors
- Atom monoid computation
- Partition correspondence (gaps ↔ partition bijection)
- Small elements and multiplicity

Functions are defined on AbstractNumericalSet where possible so they work
on both NumericalSet and NumericalSemigroup.
"""

# ============================================================================
# Interface for AbstractNumericalSet
# Both NumericalSet and NumericalSemigroup must implement these
# ============================================================================

"""
    gaps(ns::AbstractNumericalSet) -> BitSet

Return the gaps (elements not in the set) of the numerical set or semigroup.

# Examples
```julia
ns = NumericalSet([1, 2, 4, 5])
gaps(ns)  # Returns BitSet([1, 2, 4, 5])

S = NumericalSemigroup([3, 5])
gaps(S)   # Returns BitSet([1, 2, 4, 7])
```
"""
gaps(ns::NumericalSet) = ns.gaps
gaps(ns::AbstractNumericalSet) = ns.gaps  # Default: assume .gaps field exists

"""
    frobenius_number(ns::AbstractNumericalSet) -> Int

Return the Frobenius number (largest gap) of the numerical set or semigroup.
Returns -1 if there are no gaps.

# Examples
```julia
ns = NumericalSet([1, 2, 4, 5])
frobenius_number(ns)  # Returns 5

S = NumericalSemigroup([3, 5])
frobenius_number(S)   # Returns 7
```
"""
frobenius_number(ns::NumericalSet) = ns.frobenius_number

# ============================================================================
# Functions that work on any AbstractNumericalSet
# ============================================================================

"""
    atom_monoid_gaps(ns::AbstractNumericalSet) -> Set{Int}

Compute the gaps of the atom monoid.

For each x, checks if x + t is in gaps for some non-gap t ≤ max_gap.

# Examples
```julia
ns = NumericalSet([1, 2, 4, 5])
atom_gaps = atom_monoid_gaps(ns)

S = NumericalSemigroup([3, 5])
atom_gaps = atom_monoid_gaps(S)
```

# Algorithm
For each candidate x from 0 to 2*F where F is the Frobenius number:
- If there exists a non-gap t such that x + t is a gap, then x is in the atom monoid gaps
"""
function atom_monoid_gaps(ns::AbstractNumericalSet)
    gap_set = gaps(ns)
    isempty(gap_set) && return Set{Int}()
    
    max_gap = maximum(gap_set)
    atom_gaps = Set{Int}()
    
    # Check each potential atom monoid gap
    for x in 0:(2 * max_gap)
        # Check if x + t is in gaps for some non-gap t
        for t in 0:max_gap
            if t ∉ gap_set && (x + t) in gap_set
                push!(atom_gaps, x)
                break
            end
        end
    end
    
    return atom_gaps
end

"""
    partition(ns::AbstractNumericalSet) -> Vector{Int}

Create a partition from the numerical set using a lattice path bijection.

The algorithm walks from 0 to the Frobenius number:
- Non-gaps correspond to East steps (moving right)
- Gaps correspond to North steps (moving up)

At each gap (North step), record the current x-coordinate (number of non-gaps 
seen so far). This gives the row lengths of the Young diagram.

# Examples
```julia
ns = NumericalSet([1, 2, 4, 5, 7])
p = partition(ns)  # Returns a partition vector

S = NumericalSemigroup([3, 5])
p = partition(S)   # Also works on semigroups
# S = ⟨3,4⟩ has gaps {1,2,5}, partition is [3,1,1]
```

# Algorithm
This establishes a bijection between numerical sets and integer partitions.
The partition sum equals the Frobenius number.
"""
function partition(ns::AbstractNumericalSet)
    gap_set = gaps(ns)
    isempty(gap_set) && return Int[]
    
    max_gap = maximum(gap_set)
    
    # x = number of non-gaps (East steps) seen so far
    x = 0
    partition_vec = Int[]
    
    # Walk from 0 to max_gap
    for i in 0:max_gap
        if i in gap_set
            # North step: record current x-coordinate as row length
            if x > 0
                push!(partition_vec, x)
            end
        else
            # East step: increment x
            x += 1
        end
    end
    
    # Sort in descending order
    sort!(partition_vec, rev=true)
    
    return partition_vec
end

"""
    small_elements(ns::AbstractNumericalSet) -> Vector{Int}

Compute the small elements (elements less than Frobenius number) of the numerical set or semigroup.

# Examples
```julia
ns = NumericalSet([1, 2, 4, 5, 7])
small = small_elements(ns)  # Returns non-gaps less than 7

S = NumericalSemigroup([3, 5])
small = small_elements(S)   # Also works on semigroups
```
"""
function small_elements(ns::AbstractNumericalSet)
    gap_set = gaps(ns)
    isempty(gap_set) && return Int[]
    
    frob = maximum(gap_set)
    small = Int[]
    
    for s in 0:(frob-1)
        if s ∉ gap_set
            push!(small, s)
        end
    end
    
    return small
end

"""
    multiplicity(ns::AbstractNumericalSet) -> Int

Compute the multiplicity (smallest positive non-gap) of the numerical set or semigroup.

# Examples
```julia
ns = NumericalSet([1, 2, 4, 5, 7])
m = multiplicity(ns)  # Returns 3 (first non-gap after 0)

S = NumericalSemigroup([3, 5])
m = multiplicity(S)   # Returns 3 (smallest generator)
```
"""
function multiplicity(ns::AbstractNumericalSet)
    gap_set = gaps(ns)
    
    # Find smallest positive integer not in gaps
    m = 1
    while m in gap_set
        m += 1
        # Safety check to avoid infinite loop
        if m > 10000
            return m  # or throw error
        end
    end
    
    return m
end
