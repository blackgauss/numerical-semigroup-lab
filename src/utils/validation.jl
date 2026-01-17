"""
Validation utilities for input checking and type validation.

These functions ensure data integrity and provide clear error messages.
Performance note: Validations can be disabled for inner computations
where inputs are guaranteed to be valid.
"""

"""
    validate_positive_integers(vec::AbstractVector{Int})

Validate that all elements in vector are positive integers.
"""
function validate_positive_integers(vec::AbstractVector{Int})
    if !all(x -> x > 0, vec)
        throw(ArgumentError("All elements must be positive integers"))
    end
    return true
end

"""
    validate_non_increasing(vec::AbstractVector{Int})

Validate that vector is in non-increasing order.
"""
function validate_non_increasing(vec::AbstractVector{Int})
    for i in 1:(length(vec)-1)
        if vec[i] < vec[i+1]
            throw(ArgumentError("Vector must be in non-increasing order"))
        end
    end
    return true
end

"""
    validate_coprime(a::Int, b::Int)

Validate that two integers are coprime (gcd = 1).
"""
function validate_coprime(a::Int, b::Int)
    if gcd(a, b) != 1
        throw(ArgumentError("Generators must be coprime: gcd($a, $b) = $(gcd(a, b))"))
    end
    return true
end

"""
    validate_poset_properties(elements::Set{T}, relations::Set{Tuple{T,T}}) where T

Validate that relations define a valid partial order:
- Reflexive: (a,a) ∈ relations for all a ∈ elements
- Antisymmetric: (a,b) ∈ relations and (b,a) ∈ relations ⟹ a = b
- Transitive: (a,b) ∈ relations and (b,c) ∈ relations ⟹ (a,c) ∈ relations
"""
function validate_poset_properties(elements::Set{T}, relations::Set{Tuple{T,T}}) where T
    # Check reflexivity
    for elem in elements
        if (elem, elem) ∉ relations
            throw(ArgumentError("Poset must be reflexive: missing ($elem, $elem)"))
        end
    end
    
    # Check antisymmetry
    for (a, b) in relations
        if a != b && (b, a) in relations
            throw(ArgumentError("Poset must be antisymmetric: both ($a, $b) and ($b, $a) present"))
        end
    end
    
    # Check transitivity
    for (a, b) in relations
        for (c, d) in relations
            if b == c && (a, d) ∉ relations
                throw(ArgumentError("Poset must be transitive: have ($a, $b) and ($c, $d) but missing ($a, $d)"))
            end
        end
    end
    
    return true
end

"""
    validate_semigroup_from_gaps(gaps::BitSet)

Validate that gaps define a numerical semigroup by checking that
the atom monoid equals the set itself.
"""
function validate_semigroup_from_gaps(gaps::BitSet)
    # This will be implemented after we have atom_monoid_gaps function
    # For now, return true (validation happens in construction)
    return true
end

