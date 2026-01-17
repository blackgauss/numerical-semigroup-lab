# Tree Navigation for Numerical Semigroups
#
# This module implements navigation in the tree of numerical semigroups
# organized by genus. Each semigroup has a unique parent (obtained by
# adding the Frobenius number) and potentially multiple children
# (obtained by removing certain generators).

"""
    get_parent(S::NumericalSemigroup) -> Union{NumericalSemigroup, Nothing}

Get the parent of S in the semigroup tree.

The parent is obtained by adding the Frobenius number to the semigroup,
which decreases the genus by 1.

Returns `nothing` if S has genus 0 (i.e., S = ℕ₀).

# Examples
```julia
S = NumericalSemigroup([3, 5])
P = get_parent(S)  # Has genus 3, Frobenius 4
```
"""
function get_parent(S::NumericalSemigroup)
    S.genus == 0 && return nothing
    
    # New gaps = old gaps minus Frobenius number
    new_gaps = filter(g -> g != S.frobenius, collect(S.gaps))
    
    if isempty(new_gaps)
        # Parent is ℕ₀ (generator [1])
        return semigroup_from_generators([1])
    end
    
    return semigroup_from_gaps(new_gaps)
end

"""
    get_children(S::NumericalSemigroup) -> Vector{NumericalSemigroup}

Get all children of S in the semigroup tree.

A child is obtained by removing an element from S (making it a new gap),
which must be a valid operation that preserves the semigroup structure.

Children have genus(S) + 1.

# Examples
```julia
S = NumericalSemigroup([3, 5])
children = get_children(S)  # Semigroups with genus 5
```
"""
function get_children(S::NumericalSemigroup)
    children = NumericalSemigroup[]
    
    # Special case: ℕ₀ has one child: ⟨2, 3⟩ (adding 1 as gap)
    if S.frobenius < 0
        try
            child = semigroup_from_gaps([1])
            push!(children, child)
        catch
            # Should not happen
        end
        return children
    end
    
    # Find candidates: elements that can be removed
    candidates = effective_generators(S)
    
    for c in candidates
        # Create child by adding c to the gaps
        new_gaps = vcat(collect(S.gaps), c)
        try
            child = semigroup_from_gaps(new_gaps)
            push!(children, child)
        catch
            # Invalid semigroup, skip
            continue
        end
    end
    
    return children
end

"""
    effective_generators(S::NumericalSemigroup) -> Vector{Int}

Find elements that can be removed from S to create a valid child semigroup.

An element n > F(S) can be removed (made into a gap) if and only if:
1. n is in S
2. n cannot be written as a + b where a, b ∈ S \\ {0, n}

These correspond to the minimal generators greater than F(S).

# Examples
```julia
S = NumericalSemigroup([3, 5])
effective_generators(S)  # Elements that can become new gaps
```
"""
function effective_generators(S::NumericalSemigroup)
    F = S.frobenius
    
    # For genus 0 (S = ℕ₀), the only child is obtained by adding 1 as a gap
    if F < 0
        return [1]
    end
    
    candidates = Int[]
    m = S.multiplicity
    
    # Check elements from F+1 up to F+m (beyond this, all elements are expressible)
    # Actually, minimal generators > F must be in {F+1, F+2, ..., F+m}
    for n in (F + 1):(F + m)
        if n in S && can_be_new_frobenius(S, n)
            push!(candidates, n)
        end
    end
    
    return candidates
end

"""
    can_be_new_frobenius(S::NumericalSemigroup, n::Int) -> Bool

Check if n can become the new Frobenius number (i.e., a new gap).

For n to be removable:
- n must not be expressible as a sum of two elements in S \\ {0, n}
- Or equivalently, n is a "special element" in a certain sense
"""
function can_be_new_frobenius(S::NumericalSemigroup, n::Int)
    # n must be > current Frobenius
    n <= S.frobenius && return false
    
    # n must be in S
    n ∉ S && return false
    
    # For n to become a gap, it must not break closure
    # Check: if we remove n, can we still generate all elements > n?
    
    # Key condition: n should not be the only way to reach elements > n
    # Specifically: for all m in S with m > n, there should be a way to
    # write m without using n
    
    # Simpler heuristic: n is removable if n is a "pseudo-generator"
    # i.e., n cannot be written as a + b with a, b ∈ S, a, b > 0, a, b ≠ n
    
    for a in 1:(n-1)
        b = n - a
        if b > 0 && b != n && a != n && a in S && b in S
            # n = a + b with a, b ∈ S (neither equal to n)
            return false
        end
    end
    
    return true
end

"""
    remove_minimal_generator(S::NumericalSemigroup, g::Int) -> NumericalSemigroup

Remove a minimal generator from S, creating a new semigroup.

Note: This doesn't directly create a child in the genus tree, but rather
creates a "sibling" or related semigroup with different generators.

# Examples
```julia
S = NumericalSemigroup([3, 5, 7])
T = remove_minimal_generator(S, 7)  # ⟨3, 5⟩
```
"""
function remove_minimal_generator(S::NumericalSemigroup, g::Int)
    if !is_minimal_generator(S, g)
        throw(ArgumentError("$g is not a minimal generator of S"))
    end
    
    if length(S.generators) == 1
        throw(ArgumentError("Cannot remove the only generator"))
    end
    
    new_gens = filter(x -> x != g, S.generators)
    
    # Check that remaining generators are coprime
    if length(new_gens) >= 2
        if gcd(new_gens...) != 1
            throw(ArgumentError("Remaining generators are not coprime"))
        end
    end
    
    return semigroup_from_generators(new_gens)
end

"""
    genus_path(S::NumericalSemigroup) -> Vector{NumericalSemigroup}

Compute the path from S to ℕ₀ in the genus tree.

Returns a vector [S, parent(S), parent(parent(S)), ..., ℕ₀].

# Examples
```julia
S = NumericalSemigroup([3, 5])
path = genus_path(S)  # [S, genus-3 semigroup, genus-2, genus-1, ℕ₀]
```
"""
function genus_path(S::NumericalSemigroup)
    path = [S]
    current = S
    
    while current.genus > 0
        current = get_parent(current)
        push!(path, current)
    end
    
    return path
end

"""
    ancestors(S::NumericalSemigroup, n::Int) -> Vector{NumericalSemigroup}

Get the first n ancestors of S (or all ancestors up to ℕ₀).

# Examples
```julia
S = NumericalSemigroup([3, 5])
anc = ancestors(S, 2)  # [parent(S), grandparent(S)]
```
"""
function ancestors(S::NumericalSemigroup, n::Int)
    result = NumericalSemigroup[]
    current = S
    
    for _ in 1:n
        parent = get_parent(current)
        parent === nothing && break
        push!(result, parent)
        current = parent
    end
    
    return result
end

"""
    descendants(S::NumericalSemigroup, depth::Int) -> Vector{NumericalSemigroup}

Get all descendants of S up to a given depth in the tree.

# Examples
```julia
S = NumericalSemigroup([3, 5])
desc = descendants(S, 2)  # All semigroups reachable in ≤2 steps
```
"""
function descendants(S::NumericalSemigroup, depth::Int)
    depth <= 0 && return NumericalSemigroup[]
    
    result = NumericalSemigroup[]
    queue = [(S, 0)]
    
    while !isempty(queue)
        current, d = popfirst!(queue)
        
        if d > 0
            push!(result, current)
        end
        
        if d < depth
            for child in get_children(current)
                push!(queue, (child, d + 1))
            end
        end
    end
    
    return result
end
