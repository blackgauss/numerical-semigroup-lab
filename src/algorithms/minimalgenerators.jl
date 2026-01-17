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
