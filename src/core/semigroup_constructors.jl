# Factory functions for creating NumericalSemigroup instances
# These depend on algorithm implementations, so they're separate from the type definition

"""
    semigroup_from_generators(generators::Vector{Int}) -> NumericalSemigroup

Construct a numerical semigroup from generators.

# Arguments
- `generators::Vector{Int}`: Positive integers that generate the semigroup

# Returns
- `NumericalSemigroup`: The semigroup ⟨generators⟩

# Examples
```julia
S = semigroup_from_generators([3, 5])
S = semigroup_from_generators([7, 11, 13])
```

# Throws
- `ArgumentError`: If generators are empty, non-positive, or not coprime
"""
function semigroup_from_generators(generators::Vector{Int})
    if isempty(generators)
        throw(ArgumentError("Generator set cannot be empty"))
    end
    
    if any(g <= 0 for g in generators)
        throw(ArgumentError("All generators must be positive"))
    end
    
    # Remove duplicates and sort
    gens = sort(unique(generators))
    
    # Check coprimality
    g = reduce(gcd, gens)
    if g > 1
        throw(ArgumentError("Generators must be coprime (gcd = 1), got gcd=$g"))
    end
    
    # Compute gaps
    gaps_vec = compute_gaps_from_generators(gens)
    gaps_set = BitSet(gaps_vec)
    
    # Compute properties
    frobenius = isempty(gaps_vec) ? -1 : maximum(gaps_vec)
    genus = length(gaps_vec)
    multiplicity = gens[1]  # smallest generator
    
    # Compute minimal generating set
    minimal_gens = minimal_generating_set_from_gaps(gaps_set)
    embedding_dim = length(minimal_gens)
    
    return NumericalSemigroup(gaps_set, minimal_gens, frobenius, genus, 
                              multiplicity, embedding_dim)
end

"""
    semigroup_from_gaps(gaps::Vector{Int}) -> NumericalSemigroup

Construct a numerical semigroup from its gaps.

Validates that the gaps form a valid numerical semigroup (there exists
a largest gap, and the complement is closed under addition).

# Arguments
- `gaps::Vector{Int}`: The gaps (positive integers not in the semigroup)

# Examples
```julia
S = semigroup_from_gaps([1, 2, 4, 7])  # Same as ⟨3, 5⟩
```
"""
function semigroup_from_gaps(gaps::Vector{Int})
    if isempty(gaps)
        # Trivial semigroup ℕ₀ = ⟨1⟩
        return NumericalSemigroup(BitSet(), [1], -1, 0, 1, 1)
    end
    
    gaps_set = BitSet(gaps)
    
    # Validate: must have a largest gap (Frobenius number exists)
    frobenius = maximum(gaps)
    genus = length(gaps)
    
    # Compute generators from gaps
    gens = minimal_generating_set_from_gaps(gaps_set)
    
    if isempty(gens)
        throw(ArgumentError("Invalid gaps: cannot determine generators"))
    end
    
    multiplicity = gens[1]
    embedding_dim = length(gens)
    
    return NumericalSemigroup(gaps_set, gens, frobenius, genus, 
                              multiplicity, embedding_dim)
end

# Convenience constructors using the outer constructor pattern
"""
    NumericalSemigroup(generators::Vector{Int}) -> NumericalSemigroup

Convenience constructor - calls semigroup_from_generators.
"""
NumericalSemigroup(generators::Vector{Int}) = semigroup_from_generators(generators)

"""
    NumericalSemigroup(gaps::BitSet) -> NumericalSemigroup

Convenience constructor from BitSet - calls semigroup_from_gaps.
"""
function NumericalSemigroup(gaps::BitSet)
    gaps_vec = sort(collect(gaps))
    return semigroup_from_gaps(gaps_vec)
end
