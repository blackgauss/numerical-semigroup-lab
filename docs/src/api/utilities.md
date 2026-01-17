# Utility Functions

Internal utility functions and cache management.

## Cache Management

### `clear_all_caches!`

```julia
clear_all_caches!()
```

Clear all internal caches (hook lengths, conjugates, Apéry sets, minimal generators).

Use this function to free memory or when benchmarking to ensure fresh computations.

**Examples:**

```julia
# Compute some values
p = Partition([10, 9, 8, 7])
hooks = hook_lengths(p)  # Cached

# Clear caches
clear_all_caches!()

# Next call will recompute
hooks = hook_lengths(p)  # Computed fresh
```

**See Also:** [`cache_stats`](@ref)

### `cache_stats`

```julia
cache_stats() -> NamedTuple
```

Return statistics about current cache usage.

**Returns:**

A NamedTuple with fields:
- `apery`: Apéry set cache info `(size=n,)`
- `mingens`: Minimal generators cache info `(size=n,)`
- `hooks`: Hook lengths cache info `(size=n,)`
- `conjugate`: Conjugate cache info `(size=n,)`

**Examples:**

```julia
# Check initial state
stats = cache_stats()
println("Hook cache size: ", stats.hooks.size)  # 0

# Compute some values
p1 = Partition([5, 4, 3])
p2 = Partition([6, 5, 4])
hook_lengths(p1)
hook_lengths(p2)

# Check again
stats = cache_stats()
println("Hook cache size: ", stats.hooks.size)  # 2

# Clear and verify
clear_all_caches!()
stats = cache_stats()
println("Hook cache size: ", stats.hooks.size)  # 0
```

**See Also:** [`clear_all_caches!`](@ref)

## Internal Helper Functions

These functions are used internally and are not part of the public API, but may be useful for advanced users.

### `flatten`

```julia
flatten(nested::Vector{Vector{T}}) where T -> Vector{T}
```

Flatten a vector of vectors into a single vector.

**Internal use:** Used in hook length computations and atom monoid calculations.

**Examples:**

```julia
using NumericalSemigroupLab

nested = [[1, 2, 3], [4, 5], [6]]
flat = NumericalSemigroupLab.flatten(nested)  # [1, 2, 3, 4, 5, 6]
```

### `compute_conjugate_partition`

```julia
compute_conjugate_partition(parts::Vector{Int}) -> Vector{Int}
```

Compute conjugate partition parts from given parts.

Uses the relationship: `conj[j]` = number of parts ≥ j.

**Algorithm:** O(n + m) where n is number of parts, m is largest part.

**Internal use:** Called by `conjugate(::Partition)`.

### `compute_hook_lengths_matrix`

```julia
compute_hook_lengths_matrix(parts::Vector{Int}, conj::Vector{Int}) -> Vector{Vector{Int}}
```

Compute hook length matrix from partition and its conjugate.

Uses formula: `h(i,j) = parts[i] - j + conj[j] - i + 1`

**Algorithm:** O(n·m) where n, m are dimensions.

**Internal use:** Called by `hook_lengths(::Partition)`.

### `remove_sum_of_two_elements`

```julia
remove_sum_of_two_elements(A::Vector{Int}) -> Vector{Int}
```

Remove elements that can be expressed as sums of two other elements.

**Internal use:** Used in atom monoid computations.

**Examples:**

```julia
using NumericalSemigroupLab

A = [1, 2, 3, 4, 5]  # 3 = 1+2, 4 = 1+3, 5 = 1+4 or 2+3
result = NumericalSemigroupLab.remove_sum_of_two_elements(A)
# Returns elements that are NOT sums: [1, 2]
```

### `boxes_above`

```julia
boxes_above(gaps::BitSet, s::Int) -> Int
```

Count the number of gaps strictly greater than s.

**Internal use:** Used in weight computations.

## Validation Functions

### Input Validation

The package performs automatic input validation. These functions are called internally:

**`validate_positive_integers`**: Ensures all elements are positive
- Used in: `Partition` constructor
- Throws: `ArgumentError` if any element <= 0

**`validate_non_increasing`**: Ensures sequence is sorted
- Used in: Partition sorting verification
- Note: Partitions auto-sort, so this is mainly for verification

**`validate_coprime`**: Ensures generators are coprime
- Used in: `NumericalSemigroup` constructor for 2-generator case
- Throws: `ArgumentError` if gcd != 1

**`validate_poset_properties`**: Ensures valid partial order
- Used in: Poset construction
- Checks: reflexivity, antisymmetry, transitivity

## Performance Utilities

### Memory Usage

Check memory usage of objects:

```julia
using Base: summarysize

p = Partition([100, 99, 98, ..., 1])
println("Partition size: ", summarysize(p), " bytes")

ns = NumericalSet(collect(1:1000))
println("NumericalSet size: ", summarysize(ns), " bytes")
```

### Profiling

Profile computations to find bottlenecks:

```julia
using Profile

# Create test case
partitions = [Partition(collect(i:-1:1)) for i in 1:20]

# Profile hook length computations
@profile for p in partitions
    hook_lengths(p)
end

# View results
Profile.print()
```

## Type Utilities

### Type Inspection

```julia
# Check field types
fieldnames(NumericalSet)  # (:gaps, :frobenius_number)
fieldtypes(NumericalSet)  # (BitSet, Int64)

fieldnames(Partition)     # (:parts,)
fieldtypes(Partition)     # (Vector{Int64},)

# Check if type is concrete
isconcretetype(NumericalSet)  # true
isconcretetype(Partition)     # true
```

### Memory Layout

```julia
# Check object layout
sizeof(Int64)  # 8 bytes

# BitSet is efficient for sparse sets
# Vector{Int} stores elements densely
```

## Common Patterns

### Safe Cache Access

```julia
function compute_with_fresh_cache(f, args...)
    clear_all_caches!()
    result = f(args...)
    return result
end

# Use it
p = Partition([10, 9, 8])
hooks = compute_with_fresh_cache(hook_lengths, p)
```

### Cache-Aware Batch Processing

```julia
function process_batch_with_cache_management(partitions, max_cache_size=1000)
    results = []
    
    for (i, p) in enumerate(partitions)
        result = hook_lengths(p)
        push!(results, result)
        
        # Clear cache periodically
        if i % max_cache_size == 0
            clear_all_caches!()
        end
    end
    
    return results
end
```

### Measuring Cache Effectiveness

```julia
function cache_hit_rate_test(partitions)
    clear_all_caches!()
    
    # First pass (all misses)
    @time for p in partitions
        hook_lengths(p)
    end
    
    # Second pass (all hits)
    @time for p in partitions
        hook_lengths(p)
    end
    
    # Compare times to see cache speedup
end

# Test with duplicates
test_parts = [[5,4,3,1], [5,4,3,1], [6,5,4], [6,5,4]]
partitions = [Partition(parts) for parts in test_parts]
cache_hit_rate_test(partitions)
```

## See Also

- [Core Types](types.md): Main data structures
- [Partition Operations](partitions.md): Partition-specific functions
- [Numerical Set Operations](numerical-sets.md): NumericalSet-specific functions
