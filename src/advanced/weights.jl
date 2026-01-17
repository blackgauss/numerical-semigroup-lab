# Weight Computations for Numerical Semigroups
#
# This module implements various weight functions used in the study of
# numerical semigroups, including effective weight and Apéry weight.

"""
    effective_weight(S::NumericalSemigroup, a::Int) -> Int

Compute the effective weight of a minimal generator `a` in the semigroup S.

The effective weight of a minimal generator `a` is defined as:
    ew(a) = #{l | l ∉ S and l > a}

That is, the count of gaps that are greater than `a`.

Returns 0 if `a` is not a minimal generator of S.

# Examples
```julia
S = NumericalSemigroup([3, 5])
# Gaps are [1, 2, 4, 7], Frobenius = 7
effective_weight(S, 3)   # 2 (gaps > 3 are: 4, 7)
effective_weight(S, 5)   # 1 (gaps > 5 are: 7)
effective_weight(S, 2)   # 0 (2 is not a minimal generator)
```
"""
function effective_weight(S::NumericalSemigroup, a::Int)
    # Only defined for minimal generators
    a in S.generators || return 0
    
    # Count gaps greater than a
    return count(g -> g > a, S.gaps)
end

"""
    effective_weight(S::NumericalSemigroup) -> Int

Compute the effective weight of the semigroup S.

The effective weight of S is the sum of the effective weights of all 
minimal generators:
    ew(S) = Σ_{a ∈ generators(S)} ew(a)

# Examples
```julia
S = NumericalSemigroup([3, 5])
# ew(3) = 2, ew(5) = 1
effective_weight(S)  # 3
```
"""
function effective_weight(S::NumericalSemigroup)
    return sum(effective_weight(S, a) for a in S.generators)
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
