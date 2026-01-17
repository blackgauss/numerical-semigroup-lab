# Apéry Set Algorithms
#
# The Apéry set Ap(S, n) of a numerical semigroup S with respect to n ∈ S
# is the set of smallest elements in each congruence class modulo n:
#   Ap(S, n) = {s ∈ S : s - n ∉ S}

using Memoize

"""
    apery_set(S::NumericalSemigroup, n::Int) -> Vector{Int}

Compute the Apéry set of semigroup `S` with respect to element `n`.

The Apéry set Ap(S, n) consists of the smallest elements of S in each
residue class modulo n.

# Arguments
- `S::NumericalSemigroup`: A numerical semigroup
- `n::Int`: A positive element of S

# Returns
- `Vector{Int}`: Apéry set of length `n`, where index `i` contains the
  smallest element ≡ i-1 (mod n)

# Examples
```julia
S = NumericalSemigroup([3, 5])
ap = apery_set(S, 3)  # Apéry set w.r.t. multiplicity
```

# Properties
- Length of Ap(S, n) equals n
- 0 is always in Ap(S, n) at index 1
- Sum of Ap(S, n) - n·(n-1)/2 equals the Frobenius number
"""
function apery_set(S::NumericalSemigroup, n::Int)
    if n <= 0
        throw(ArgumentError("n must be positive"))
    end
    
    if !(n in S)
        throw(ArgumentError("n = $n is not in the semigroup"))
    end
    
    # Check cache
    cache_key = (S.gaps, n)
    if haskey(APERY_CACHE, cache_key)
        return APERY_CACHE[cache_key]
    end
    
    # Compute Apéry set
    apery = compute_apery_set(S, n)
    
    # Cache result
    APERY_CACHE[cache_key] = apery
    
    return apery
end

"""
    apery_set(S::NumericalSemigroup) -> Vector{Int}

Compute the Apéry set with respect to the multiplicity (smallest positive element).

This is equivalent to `apery_set(S, multiplicity(S))`.
"""
function apery_set(S::NumericalSemigroup)
    return apery_set(S, S.multiplicity)
end

"""
    compute_apery_set(S::NumericalSemigroup, n::Int) -> Vector{Int}

Internal function to compute Apéry set.

Uses a greedy algorithm: for each residue class i (mod n), find the
smallest element of S in that class.
"""
function compute_apery_set(S::NumericalSemigroup, n::Int)
    apery = fill(-1, n)
    apery[1] = 0  # 0 is always in S and ≡ 0 (mod n)
    
    # Upper bound for search: 2 * Frobenius should be more than enough
    upper = max(2 * S.frobenius + n, 10 * n)
    
    # Find smallest element in each residue class
    for k in 0:upper
        if k in S
            residue = (k % n) + 1  # Julia 1-indexing
            if apery[residue] == -1
                apery[residue] = k
            end
        end
        
        # Early exit if all residue classes found
        if all(a >= 0 for a in apery)
            break
        end
    end
    
    # Verify all residue classes were found
    if any(a < 0 for a in apery)
        error("Failed to compute Apéry set - some residue classes not found")
    end
    
    return apery
end

"""
    clear_apery_cache!()

Clear the Apéry set cache. Useful for freeing memory.
"""
function clear_apery_cache!()
    empty!(APERY_CACHE)
    return nothing
end
