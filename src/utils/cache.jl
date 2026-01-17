"""
Caching utilities for expensive computations.

Uses simple Dict-based caching for now. Can be upgraded to LRU caches later.

Performance considerations:
- Cache keys must be hashable and comparable
- Cache size affects memory usage
- Clear caches periodically in long-running applications
"""

"""
Global cache for Apéry set computations.
Key: (BitSet of gaps, modulus)
Value: Vector{Int} (Apéry set)
"""
const APERY_CACHE = Dict{Tuple{BitSet,Int}, Vector{Int}}()

"""
Global cache for minimal generating set computations.
Key: BitSet of gaps
Value: Vector{Int} (minimal generators)
"""
const MINGENS_CACHE = Dict{BitSet, Vector{Int}}()

"""
Global cache for hook length computations.
Key: Vector{Int} (partition parts)
Value: Vector{Vector{Int}} (hook lengths)
"""
const HOOKS_CACHE = Dict{Vector{Int}, Vector{Vector{Int}}}()

"""
Global cache for conjugate partitions.
Key: Vector{Int} (partition parts)
Value: Vector{Int} (conjugate partition)
"""
const CONJUGATE_CACHE = Dict{Vector{Int}, Vector{Int}}()

"""
    clear_all_caches!()

Clear all global caches to free memory.

Use this in long-running applications or after processing many semigroups.

# Examples
```julia
# Process many semigroups
for g in 1:100
    S = NumericalSemigroup(generators=[g, g+1])
    minimal_generating_set(S)
end

# Free memory
clear_all_caches!()
```
"""
function clear_all_caches!()
    empty!(APERY_CACHE)
    empty!(MINGENS_CACHE)
    empty!(HOOKS_CACHE)
    empty!(CONJUGATE_CACHE)
    return nothing
end

"""
    cache_stats()

Return statistics about cache usage.

# Returns
A named tuple with cache statistics for each cache.
"""
function cache_stats()
    return (
        apery = (size=length(APERY_CACHE),),
        mingens = (size=length(MINGENS_CACHE),),
        hooks = (size=length(HOOKS_CACHE),),
        conjugate = (size=length(CONJUGATE_CACHE),)
    )
end

