# Partition Operations

Complete API reference for partition-related functions.

## Constructors

See [Core Types - Partition](#Partition) for detailed constructor documentation.

## Basic Properties

### `gaps(::Partition)`

```julia
gaps(p::Partition) -> Vector{Int}
```

Compute the gaps corresponding to a partition using the partition-semigroup bijection.

Uses a walk algorithm on the boundary of the Ferrers diagram to determine which positive integers are gaps in the corresponding numerical set.

**Arguments:**
- `p::Partition`: The partition

**Returns:**
- `Vector{Int}`: Sorted vector of gaps

**Examples:**

```julia
p = Partition([5, 4, 3, 1])
gaps(p)  # [1, 2, 4, 5, 8]

p = Partition([3, 3, 2, 2, 1, 1])
gaps(p)  # [1, 2, 4, 5, 7]
```

**Algorithm:** O(F²) where F is the Frobenius number

**See Also:** `partition`

## Conjugation

### `conjugate`

```julia
conjugate(p::Partition) -> Partition
```

Compute the conjugate (transpose) of a partition's Ferrers diagram.

The conjugate partition is obtained by reflecting the Ferrers diagram across the main diagonal. The j-th part of the conjugate equals the number of parts in the original partition that are ≥ j.

**Arguments:**
- `p::Partition`: The partition

**Returns:**
- `Partition`: The conjugate partition

**Examples:**

```julia
p = Partition([5, 4, 3, 1])
conj = conjugate(p)
conj.parts  # [4, 3, 3, 2, 1]

# Rectangular partitions
p = Partition([5, 5, 5])
conjugate(p).parts  # [3, 3, 3, 3, 3]

# Single row/column are conjugates
p1 = Partition([10])
conjugate(p1).parts  # [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

p2 = Partition([1, 1, 1, 1, 1])
conjugate(p2).parts  # [5]
```

**Properties:**
- Involution: `conjugate(conjugate(p)) == p`
- Preserves size: `sum(conjugate(p).parts) == sum(p.parts)`

**Algorithm:** O(n + m) where n, m are dimensions  
**Caching:** Results are cached for repeated calls

**See Also:** `hook_lengths`

## Hook Lengths

### `hook_lengths`

```julia
hook_lengths(p::Partition) -> Vector{Vector{Int}}
```

Compute the hook length matrix for a partition.

The hook length h(i,j) of box (i,j) is the number of boxes in the "hook": the box itself, all boxes directly to its right, and all boxes directly below it.

**Arguments:**
- `p::Partition`: The partition

**Returns:**
- `Vector{Vector{Int}}`: Hook length matrix (ragged array)

**Examples:**

```julia
p = Partition([5, 4, 3, 1])
hooks = hook_lengths(p)
# [[8, 6, 5, 3, 1],
#  [6, 4, 3, 1],
#  [4, 2, 1],
#  [1]]

p = Partition([3, 2, 1])
hooks = hook_lengths(p)
# [[5, 3, 1],
#  [3, 1],
#  [1]]
```

**Formula:**
$$h(i,j) = \lambda_i - j + \lambda'_j - i + 1$$
where λ is the partition and λ' is its conjugate.

**Applications:**
- Counting standard Young tableaux: $f^\lambda = \frac{n!}{\prod h(i,j)}$
- Representation theory of symmetric groups
- Combinatorial identities

**Algorithm:** O(n·m) where n, m are dimensions  
**Caching:** Results are cached for repeated calls

**See Also:** `conjugate`, `atom_partition`

## Profile and Walks

### `profile`

```julia
profile(p::Partition) -> Vector{Tuple{Int, Int}}
```

Compute the profile (boundary walk) of a partition's Ferrers diagram.

Returns a sequence of steps (1,0) for "right" and (0,1) for "down" that traces the boundary from top-left to bottom-right.

**Arguments:**
- `p::Partition`: The partition

**Returns:**
- `Vector{Tuple{Int,Int}}`: Sequence of (dx, dy) steps

**Examples:**

```julia
p = Partition([3, 2, 1])
prof = profile(p)
# [(1,0), (0,1), (1,0), (0,1), (1,0), (0,1)]

# Length equals sum of parts
length(profile(p)) == sum(p.parts)  # true
```

**Algorithm:** O(n·m)  

**See Also:** `gaps`

## Atom Operations

### `atom_partition`

```julia
atom_partition(p::Partition) -> Vector{Int}
```

Compute the atom partition corresponding to the atom monoid of p's gaps.

The atom partition is derived from the multiset of hook lengths. It represents the partition whose gaps correspond to the atom monoid.

**Arguments:**
- `p::Partition`: The partition

**Returns:**
- `Vector{Int}`: Parts of the atom partition

**Examples:**

```julia
p = Partition([5, 4, 3, 1])
atom_p = atom_partition(p)
println(atom_p)  # Derived from hook structure
```

**Algorithm:** O(n·m·log(nm))  

**See Also:** `atom_monoid_gaps`, `is_semigroup`

### `atom_monoid_gaps`

```julia
atom_monoid_gaps(p::Partition) -> Vector{Int}
```

Compute the gaps of the atom monoid by flattening and processing hook lengths.

**Arguments:**
- `p::Partition`: The partition

**Returns:**
- `Vector{Int}`: Sorted gaps of the atom monoid

**Examples:**

```julia
p = Partition([5, 4, 3, 1])
atom_gaps = atom_monoid_gaps(p)
println(sort(atom_gaps))
```

**Algorithm:** O(n·m·log(nm))  

**See Also:** `hook_lengths`, `atom_partition`

### `is_semigroup`

```julia
is_semigroup(p::Partition) -> Bool
```

Check if a partition equals its own atom partition.

A partition is a "semigroup partition" if it is invariant under the atom partition transformation.

**Arguments:**
- `p::Partition`: The partition

**Returns:**
- `Bool`: True if p equals its atom partition

**Examples:**

```julia
p1 = Partition([5, 4, 3, 1])
is_semigroup(p1)  # false

# Find semigroup partitions
for parts in [[2,1], [3,2,1], [4,3,2,1]]
    p = Partition(parts)
    if is_semigroup(p)
        println("$parts is a semigroup partition")
    end
end
```

**Algorithm:** O(n·m·log(nm))  

**See Also:** `atom_partition`

## Performance Notes

### Caching

Hook lengths and conjugates are automatically cached:

```julia
p = Partition([20, 19, 18, 17, 16])

@time hooks1 = hook_lengths(p)  # ~30 μs (computed)
@time hooks2 = hook_lengths(p)  # ~10 μs (cached)

# Verify same object
hooks1 === hooks2  # true
```

### Cache Management

```julia
# View cache statistics
stats = cache_stats()
println("Hook cache size: ", stats.hooks.size)
println("Conjugate cache size: ", stats.conjugate.size)

# Clear caches to free memory
clear_all_caches!()
```

### Complexity Summary

| Operation | Time | Space | Cached? |
|-----------|------|-------|---------|
| `conjugate` | O(n+m) | O(m) | Yes |
| `hook_lengths` | O(nm) | O(nm) | Yes |
| `profile` | O(nm) | O(n+m) | No |
| `gaps` | O(F²) | O(g) | No |
| `atom_partition` | O(nm log(nm)) | O(nm) | No |
| `is_semigroup` | O(nm log(nm)) | O(nm) | No |

where:
- n = number of parts
- m = largest part  
- F = Frobenius number
- g = number of gaps

## Examples

### Computing Standard Young Tableaux Count

```julia
function count_syt(p::Partition)
    n = sum(p.parts)
    hooks = hook_lengths(p)
    hook_prod = prod(vcat(hooks...))
    return factorial(n) ÷ hook_prod
end

p = Partition([3, 2, 1])
count_syt(p)  # 16
```

### Finding Self-Conjugate Partitions

```julia
function is_self_conjugate(p::Partition)
    conj = conjugate(p)
    return p.parts == conj.parts
end

# Test several partitions
for parts in [[4,2,2],[4,3,1,1],[5,3,1]]
    p = Partition(parts)
    if is_self_conjugate(p)
        println("$parts is self-conjugate")
    end
end
```

### Exploring Hook Length Statistics

```julia
function hook_statistics(p::Partition)
    hooks = hook_lengths(p)
    all_hooks = vcat(hooks...)
    
    return (
        min = minimum(all_hooks),
        max = maximum(all_hooks),
        mean = sum(all_hooks) / length(all_hooks),
        total = sum(all_hooks)
    )
end

p = Partition([10, 8, 6, 4, 2])
stats = hook_statistics(p)
println("Hook statistics: ", stats)
```
