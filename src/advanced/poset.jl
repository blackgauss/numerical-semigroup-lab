# Poset Operations for Numerical Semigroups
#
# This module implements poset (partially ordered set) functionality,
# particularly for the divisibility/Kunz poset structure on gaps.

"""
    cover_relations(p::Poset{T}) -> Vector{Tuple{T,T}}

Compute the cover relations (Hasse diagram edges) of the poset.

A pair (a, b) is a cover relation if a < b and there is no c with a < c < b.

# Examples
```julia
elements = [1, 2, 3, 6]
# Divisibility order
relations = [(a, b) for a in elements for b in elements if b % a == 0]
push!(relations, [(x, x) for x in elements]...)  # reflexive
p = Poset(elements, relations)
covers = cover_relations(p)  # [(1,2), (1,3), (2,6), (3,6)]
```
"""
function cover_relations(p::Poset{T}) where T
    covers = Tuple{T,T}[]
    
    for (a, b) in p.relations
        a == b && continue  # Skip reflexive relations
        
        # Check if there's any c strictly between a and b
        is_cover = true
        for c in p.elements
            if c != a && c != b
                if (a, c) in p.relations && (c, b) in p.relations
                    is_cover = false
                    break
                end
            end
        end
        
        if is_cover
            push!(covers, (a, b))
        end
    end
    
    return covers
end

"""
    minimal_elements(p::Poset{T}) -> Vector{T}

Return the minimal elements of the poset (elements with no predecessors).
"""
function minimal_elements(p::Poset{T}) where T
    minimals = T[]
    
    for elem in p.elements
        is_minimal = true
        for other in p.elements
            if other != elem && (other, elem) in p.relations
                is_minimal = false
                break
            end
        end
        if is_minimal
            push!(minimals, elem)
        end
    end
    
    return minimals
end

"""
    maximal_elements(p::Poset{T}) -> Vector{T}

Return the maximal elements of the poset (elements with no successors).
"""
function maximal_elements(p::Poset{T}) where T
    maximals = T[]
    
    for elem in p.elements
        is_maximal = true
        for other in p.elements
            if other != elem && (elem, other) in p.relations
                is_maximal = false
                break
            end
        end
        if is_maximal
            push!(maximals, elem)
        end
    end
    
    return maximals
end

"""
    add_element(p::Poset{T}, elem::T) -> Poset{T}

Add an element to the poset (with only the reflexive relation).
"""
function add_element(p::Poset{T}, elem::T) where T
    if elem in p.elements
        return p
    end
    
    new_elements = copy(p.elements)
    push!(new_elements, elem)
    
    new_relations = copy(p.relations)
    push!(new_relations, (elem, elem))
    
    return Poset(new_elements, new_relations)
end

"""
    add_relation(p::Poset{T}, a::T, b::T) -> Poset{T}

Add a relation a ≤ b to the poset and compute the transitive closure.
"""
function add_relation(p::Poset{T}, a::T, b::T) where T
    if a ∉ p.elements || b ∉ p.elements
        throw(ArgumentError("Both elements must be in the poset"))
    end
    
    if (a, b) in p.relations
        return p
    end
    
    new_relations = copy(p.relations)
    push!(new_relations, (a, b))
    
    # Compute transitive closure
    changed = true
    while changed
        changed = false
        for (x, y) in collect(new_relations)
            for (y2, z) in collect(new_relations)
                if y == y2 && (x, z) ∉ new_relations
                    push!(new_relations, (x, z))
                    changed = true
                end
            end
        end
    end
    
    return Poset(p.elements, new_relations)
end

"""
    gap_poset(S::NumericalSemigroup) -> Poset{Int}

Construct the Kunz poset on the gaps of a numerical semigroup.

The Kunz poset has gaps as elements, with g₁ ≤ g₂ if g₂ - g₁ ∈ S.
This captures the "divisibility" structure relative to the semigroup.

# Examples
```julia
S = NumericalSemigroup([3, 5])
p = gap_poset(S)  # Poset on gaps {1, 2, 4, 7}
```
"""
function gap_poset(S::NumericalSemigroup)
    gap_list = sort(collect(S.gaps))
    
    if isempty(gap_list)
        # Trivial poset with no elements
        return Poset(Int[], Tuple{Int,Int}[])
    end
    
    # Build relations: g₁ ≤ g₂ if g₂ - g₁ ∈ S (including g₁ = g₂)
    relations = Tuple{Int,Int}[]
    
    for g1 in gap_list
        # Reflexive
        push!(relations, (g1, g1))
        
        for g2 in gap_list
            if g2 > g1
                diff = g2 - g1
                # Check if diff is in S (not a gap, and non-negative)
                if diff ∉ S.gaps && diff > 0
                    push!(relations, (g1, g2))
                end
            end
        end
    end
    
    return Poset(gap_list, relations)
end

"""
    void(S::NumericalSemigroup) -> Vector{Int}

Compute the voids of a numerical semigroup.

A void is a gap g such that g + s is not a gap for any positive s ∈ S.
Equivalently, voids are the maximal elements in the gap poset.

Also known as "pseudo-Frobenius numbers" or "special gaps" in some literature.

# Examples
```julia
S = NumericalSemigroup([3, 5])
void(S)  # [7] - only the Frobenius number for this semigroup
```
"""
function void(S::NumericalSemigroup)
    gap_list = collect(S.gaps)
    isempty(gap_list) && return Int[]
    
    voids = Int[]
    
    for g in gap_list
        is_void = true
        # Check if g + s is a gap for any positive s in S
        for s in elements_up_to(S, S.frobenius - g)
            if s > 0 && (g + s) in S.gaps
                is_void = false
                break
            end
        end
        if is_void
            push!(voids, g)
        end
    end
    
    return sort(voids)
end

"""
    void_poset(S::NumericalSemigroup) -> Poset{Int}

Construct a poset on the voids (pseudo-Frobenius numbers) of a numerical semigroup.

Uses the same ordering as gap_poset but restricted to voids.
"""
function void_poset(S::NumericalSemigroup)
    v = void(S)
    
    if isempty(v)
        return Poset(Int[], Tuple{Int,Int}[])
    end
    
    relations = Tuple{Int,Int}[]
    
    for v1 in v
        push!(relations, (v1, v1))  # Reflexive
        
        for v2 in v
            if v2 > v1
                diff = v2 - v1
                if diff ∉ S.gaps && diff > 0
                    push!(relations, (v1, v2))
                end
            end
        end
    end
    
    return Poset(v, relations)
end

"""
    pseudofrobenius_numbers(S::NumericalSemigroup) -> Vector{Int}

Alias for void(S). Returns the pseudo-Frobenius numbers of the semigroup.

A pseudo-Frobenius number is a gap g such that g + s ∈ S for all s ∈ S \\ {0}.
"""
pseudofrobenius_numbers(S::NumericalSemigroup) = void(S)

"""
    type_semigroup(S::NumericalSemigroup) -> Int

Return the type of the semigroup (number of pseudo-Frobenius numbers).

# Examples
```julia
S = NumericalSemigroup([3, 5])
type_semigroup(S)  # 1 - symmetric semigroup
```
"""
type_semigroup(S::NumericalSemigroup) = length(void(S))
