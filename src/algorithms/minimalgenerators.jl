# Minimal Generating Set Algorithms
#
# An element n of a numerical semigroup S is a minimal generator if:
# 1. n > 0
# 2. n cannot be written as a sum of other elements of S \ {n}

"""
    minimal_generating_set(S::NumericalSemigroup) -> Vector{Int}

Return the minimal generating set of semigroup `S`.

The minimal generating set is the unique minimal set of generators
(with respect to inclusion).

# Examples
```julia
S = NumericalSemigroup([6, 9, 20])
minimal_generating_set(S)  # May be [6, 9, 20] or subset

S = NumericalSemigroup([4, 6, 9])
minimal_generating_set(S)  # Likely [4, 9] since 6 = 4+2 doesn't work
                            # but depends on actual gaps
```

# Properties
- Every numerical semigroup has a unique minimal generating set
- The cardinality is the embedding dimension
- Equals S.generators for semigroups constructed from generators
"""
minimal_generating_set(S::NumericalSemigroup) = S.generators

"""
    is_minimal_generator(S::NumericalSemigroup, n::Int) -> Bool

Check if `n` is a minimal generator of semigroup `S`.

# Arguments
- `S::NumericalSemigroup`: A numerical semigroup
- `n::Int`: A positive integer

# Returns
- `Bool`: true if n is a minimal generator

# Examples
```julia
S = NumericalSemigroup([3, 5])
is_minimal_generator(S, 3)   # true
is_minimal_generator(S, 5)   # true
is_minimal_generator(S, 6)   # false (6 = 3+3)
is_minimal_generator(S, 2)   # false (2 is a gap)
```

# Algorithm
An element n is a minimal generator iff:
1. n ∈ S (n is in the semigroup)
2. n cannot be written as a + b where a, b ∈ S and a, b > 0
"""
function is_minimal_generator(S::NumericalSemigroup, n::Int)
    # Must be in the semigroup
    if !(n in S)
        return false
    end
    
    # 0 is not a generator
    if n <= 0
        return false
    end
    
    # Check if n can be expressed as sum of smaller elements
    for a in 1:(n-1)
        if a in S
            b = n - a
            if b > 0 && b in S
                # n = a + b where both a, b are in S
                return false
            end
        end
    end
    
    return true
end

"""
    minimal_generating_set_from_generators(generators::Vector{Int}) -> Vector{Int}

Compute the minimal generating set from a (possibly non-minimal) generating set.

# Arguments
- `generators::Vector{Int}`: A set of generators (possibly redundant)

# Returns
- `Vector{Int}`: The minimal generating set

# Examples
```julia
# Redundant generators
minimal_generating_set_from_generators([3, 5, 8])  # [3, 5] since 8 = 3+5
```

# Algorithm
Remove any generator that can be expressed as a combination of others.
"""
function minimal_generating_set_from_generators(generators::Vector{Int})
    if isempty(generators)
        return Int[]
    end
    
    # Sort generators
    gens = sort(unique(generators))
    
    # Special case: if 1 is a generator, it's the only minimal generator
    if gens[1] == 1
        return [1]
    end
    
    minimal = Int[]
    
    for g in gens
        # Check if g can be expressed using generators before it (and those already in minimal)
        can_express = false
        
        # Try to express g as sum of elements from minimal ∪ previous generators
        # Use DP to check representability
        max_val = g - 1
        can_represent = falses(max_val + 1)
        can_represent[1] = true  # 0
        
        for n in 0:max_val
            if can_represent[n + 1]
                for h in minimal
                    if h < g && n + h <= max_val
                        can_represent[n + h + 1] = true
                    end
                end
            end
        end
        
        # Check if g-1 (or anything that makes g) is representable
        if g <= max_val + 1 && can_represent[g]
            can_express = true
        end
        
        if !can_express
            push!(minimal, g)
        end
    end
    
    return minimal
end

"""
    compute_minimal_generators_from_gaps(gaps::BitSet) -> Vector{Int}

Compute minimal generators directly from the gap set.

# Algorithm
An element n is a minimal generator iff:
1. n is not a gap
2. n cannot be written as a sum of two smaller non-gaps
"""
function compute_minimal_generators_from_gaps(gaps::BitSet)
    if isempty(gaps)
        return [1]
    end
    
    frobenius = maximum(gaps)
    minimal = Int[]
    
    # All minimal generators are ≤ Frobenius + 1
    for n in 1:(frobenius + 1)
        if n in gaps
            continue  # n is a gap, skip
        end
        
        # Check if n can be expressed as sum of smaller non-gaps
        can_express = false
        for a in 1:(n-1)
            if !(a in gaps)
                b = n - a
                if b > 0 && !(b in gaps)
                    can_express = true
                    break
                end
            end
        end
        
        if !can_express
            push!(minimal, n)
        end
    end
    
    return minimal
end
