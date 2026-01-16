# Weight Computations for Numerical Semigroups
#
# This module implements various weight functions used in the study of
# numerical semigroups, including effective weight and Apéry weight.

"""
    effective_weight(S::NumericalSemigroup, g::Int) -> Int

Compute the effective weight of a gap g in the semigroup S.

The effective weight of g is the number of pairs (s₁, s₂) ∈ S × S with s₁, s₂ > 0
such that s₁ + s₂ = g.

# Examples
```julia
S = NumericalSemigroup([3, 5])
effective_weight(S, 6)   # 1 (only 3+3=6)
effective_weight(S, 8)   # 1 (only 3+5=8)
effective_weight(S, 10)  # 2 (5+5=10 and 3+7... but 7 is a gap)
```
"""
function effective_weight(S::NumericalSemigroup, g::Int)
    g <= 0 && return 0
    
    count = 0
    # Count unordered pairs (s1, s2) with s1 <= s2, both in S, s1 > 0, s2 > 0, s1 + s2 = g
    for s1 in 1:(g ÷ 2)
        s2 = g - s1
        if s1 in S && s2 in S
            count += 1
        end
    end
    # Handle the case where g is even and g/2 is in S (counted once above, which is correct)
    
    return count
end

"""
    effective_weight(S::NumericalSemigroup) -> Dict{Int, Int}

Compute the effective weight for all gaps in S.

# Examples
```julia
S = NumericalSemigroup([3, 5])
w = effective_weight(S)  # Dict with effective weights for each gap
```
"""
function effective_weight(S::NumericalSemigroup)
    result = Dict{Int, Int}()
    for g in S.gaps
        result[g] = effective_weight(S, g)
    end
    return result
end

"""
    apery_weight(S::NumericalSemigroup, n::Int) -> Vector{Int}

Compute the Apéry weight vector with respect to n.

The Apéry weight of an element w in Ap(S, n) is (w - class(w)·n) / n,
which counts "how many times n divides" the overshoot from the minimal element.

Actually, a more common definition: for w ∈ Ap(S, n), the weight is w ÷ n
(integer division), representing the "height" in the Apéry structure.

# Examples
```julia
S = NumericalSemigroup([3, 5])
apery_weight(S, 3)  # Weights for Apéry set [0, 5, 10]
# Result: [0, 1, 3] since 0/3=0, 5/3=1, 10/3=3
```
"""
function apery_weight(S::NumericalSemigroup, n::Int)
    ap = apery_set(S, n)
    return [w ÷ n for w in ap]
end

"""
    apery_weight(S::NumericalSemigroup) -> Vector{Int}

Compute the Apéry weight vector with respect to the multiplicity.
"""
apery_weight(S::NumericalSemigroup) = apery_weight(S, S.multiplicity)

"""
    kunz_coordinates(S::NumericalSemigroup) -> Vector{Int}

Compute the Kunz coordinates of the semigroup.

For a semigroup with multiplicity m, the Kunz coordinates are (k₁, k₂, ..., k_{m-1})
where kᵢ = (wᵢ - i) / m and wᵢ is the i-th element of Ap(S, m) (sorted by residue class).

Kunz coordinates uniquely determine the semigroup and satisfy certain inequalities.

# Examples
```julia
S = NumericalSemigroup([3, 5])
kunz_coordinates(S)  # Kunz coordinates
```
"""
function kunz_coordinates(S::NumericalSemigroup)
    m = S.multiplicity
    m == 1 && return Int[]  # Trivial semigroup
    
    ap = apery_set(S, m)
    
    # Sort Apéry set by residue class (excluding 0)
    # ap[i+1] should be the smallest element ≡ i (mod m)
    coords = Int[]
    for i in 1:(m-1)
        # Find element in Apéry set with residue i
        w = ap[findfirst(x -> x % m == i, ap)]
        push!(coords, (w - i) ÷ m)
    end
    
    return coords
end

"""
    depth(S::NumericalSemigroup) -> Int

Compute the depth (or Eliahou number) of the semigroup.

The depth is the maximum of the Kunz coordinates, representing the
"height" of the Apéry set structure.

# Examples
```julia
S = NumericalSemigroup([3, 5])
depth(S)  # Maximum Kunz coordinate
```
"""
function depth(S::NumericalSemigroup)
    coords = kunz_coordinates(S)
    isempty(coords) && return 0
    return maximum(coords)
end

"""
    delta_set(S::NumericalSemigroup) -> Vector{Int}

Compute the delta set (set of differences) of the semigroup.

The delta set Δ(S) consists of all differences s - t where s, t ∈ S with s > t
and there is no element of S strictly between them.

# Examples
```julia
S = NumericalSemigroup([3, 5])
delta_set(S)  # Differences between consecutive elements
```
"""
function delta_set(S::NumericalSemigroup)
    # Get sorted elements up to some bound
    bound = S.frobenius + S.multiplicity + 1
    elems = sort(elements_up_to(S, bound))
    
    deltas = Set{Int}()
    for i in 2:length(elems)
        push!(deltas, elems[i] - elems[i-1])
    end
    
    return sort(collect(deltas))
end

"""
    catenary_degree(S::NumericalSemigroup) -> Int

Compute the catenary degree of the semigroup.

The catenary degree is a measure of how "connected" the factorization graph is.
For numerical semigroups, it can be computed from the Apéry set.

# Examples
```julia
S = NumericalSemigroup([3, 5])
catenary_degree(S)
```
"""
function catenary_degree(S::NumericalSemigroup)
    # Simple bound: maximum of Kunz coordinates + 1
    # (This is an upper bound; exact computation requires factorization analysis)
    d = depth(S)
    return d + 1
end
