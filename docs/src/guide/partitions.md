# Working with Partitions

Integer partitions are fundamental objects in combinatorics. This guide shows you how to work with them in NumericalSemigroupLab.jl.

## Creating Partitions

### Basic Creation

```julia
using NumericalSemigroupLab

# Create a partition from a list of parts
p = Partition([5, 4, 3, 1])
println(p.parts)  # [5, 4, 3, 1]
```

### Automatic Sorting

Partitions are automatically sorted in non-increasing order:

```julia
# Parts given out of order
p = Partition([3, 1, 5, 4])
println(p.parts)  # [5, 4, 3, 1] - automatically sorted!
```

### Input Validation

The constructor validates that all parts are positive integers:

```julia
# These will throw errors:
try
    Partition([0, 1, 2])  # ❌ Zero not allowed
catch e
    println("Error: Parts must be positive")
end

try
    Partition([-1, 3, 5])  # ❌ Negative not allowed
catch e
    println("Error: Parts must be positive")
end
```

## Partition Properties

### Size and Length

```julia
p = Partition([5, 4, 3, 1])

# Sum of parts (size of the partition)
n = sum(p.parts)  # 13

# Number of parts
k = length(p.parts)  # 4
```

### Visualizing as Ferrers Diagram

```julia
function show_ferrers(p::Partition)
    for part in p.parts
        println("■"^part)
    end
end

p = Partition([5, 4, 3, 1])
show_ferrers(p)
# Output:
# ■■■■■
# ■■■■
# ■■■
# ■
```

## Partition Operations

### Conjugate (Transpose)

The conjugate partition is obtained by reflecting the Ferrers diagram:

```julia
p = Partition([5, 4, 3, 1])
conj = conjugate(p)

println(p.parts)     # [5, 4, 3, 1]
println(conj.parts)  # [4, 3, 3, 2, 1]
```

**Mathematical insight:** The $j$-th part of the conjugate equals the number of parts in the original partition that are $\geq j$.

```julia
# Verify this property
p = Partition([5, 4, 3, 1])
conj = conjugate(p)

# conj.parts[1] should equal # of parts >= 1
count(x -> x >= 1, p.parts) == conj.parts[1]  # true: 4 == 4

# conj.parts[2] should equal # of parts >= 2  
count(x -> x >= 2, p.parts) == conj.parts[2]  # true: 3 == 3
```

### Hook Lengths

The hook length of box $(i,j)$ counts boxes in the "hook" shape: the box itself, all boxes to its right, and all boxes below it.

```julia
p = Partition([5, 4, 3, 1])
hooks = hook_lengths(p)

# Display the hook length matrix
for (i, row) in enumerate(hooks)
    println("Row $i: ", row)
end
# Output:
# Row 1: [8, 6, 5, 3, 1]
# Row 2: [6, 4, 3, 1]
# Row 3: [4, 2, 1]
# Row 4: [1]
```

**Formula:** For box at position $(i,j)$:
$$h(i,j) = \lambda_i - j + \lambda'_j - i + 1$$

where $\lambda$ is the partition and $\lambda'$ is its conjugate.

### Profile

The profile represents the boundary walk of the Ferrers diagram:

```julia
p = Partition([5, 4, 3, 1])
prof = profile(p)

println(length(prof))  # Number of steps
println(prof[1:5])     # First few steps: [(1,0), (0,1), (1,0), (1,0), (0,1)]
```

Each step is either:
- `(1, 0)`: Move right
- `(0, 1)`: Move down

### Gaps from Partition

Convert a partition to its corresponding gaps:

```julia
p = Partition([5, 4, 3, 1])
gaps_vec = gaps(p)

println(gaps_vec)  # [1, 2, 4, 5, 8]
```

This uses the partition-semigroup bijection (see [Mathematical Background](@ref)).

## Advanced Operations

### Atom Partition

The atom partition represents the "atomic" structure:

```julia
p = Partition([5, 4, 3, 1])
atom_p = atom_partition(p)

println(atom_p)  # Partition derived from hook structure
```

### Is Semigroup?

Check if a partition equals its own atom partition:

```julia
p = Partition([5, 4, 3, 1])
is_sg = is_semigroup(p)

println("Is semigroup partition: ", is_sg)  # false or true
```

### Atom Monoid Gaps

Get the gaps of the atom monoid:

```julia
p = Partition([5, 4, 3, 1])
atom_gaps = atom_monoid_gaps(p)

println(sort(collect(atom_gaps)))  # Flattened hook lengths
```

## Performance Considerations

### Caching

Hook lengths and conjugates are automatically cached:

```julia
p = Partition([20, 19, 18, 17, 16])

# First call: computed (~30 μs)
@time hooks1 = hook_lengths(p)

# Second call: cached (~10 μs)  
@time hooks2 = hook_lengths(p)

# Same object returned
hooks1 === hooks2  # true
```

### Clearing Caches

When memory is a concern:

```julia
# Check cache usage
stats = cache_stats()
println("Hook cache size: ", stats.hooks.size)

# Clear all caches
clear_all_caches!()

# Verify
stats = cache_stats()
println("Hook cache size: ", stats.hooks.size)  # 0
```

### Batch Processing

Process many partitions efficiently:

```julia
# Generate partitions
partitions = [Partition([i, i-1, i-2]) for i in 5:100]

# Compute all conjugates
@time conjugates = [conjugate(p) for p in partitions]

# Compute all hook lengths  
@time all_hooks = [hook_lengths(p) for p in partitions]
```

## Common Patterns

### Finding Partitions with Properties

```julia
# Find all 3-part partitions of n=12
function partitions_3parts(n)
    result = []
    for a in 1:n
        for b in 1:a
            c = n - a - b
            if 0 < c <= b
                push!(result, Partition([a, b, c]))
            end
        end
    end
    return result
end

parts = partitions_3parts(12)
for p in parts
    println(p.parts)
end
```

### Computing Statistics

```julia
# Average hook length
p = Partition([5, 4, 3, 1])
hooks = hook_lengths(p)
all_hooks = vcat(hooks...)  # Flatten
avg_hook = sum(all_hooks) / length(all_hooks)
println("Average hook length: ", avg_hook)
```

### Comparing Partitions

```julia
p1 = Partition([5, 4, 3, 1])
p2 = Partition([4, 3, 3, 2, 1])  # Conjugate of p1
p3 = Partition([5, 4, 3, 1])     # Same as p1

# Equality checks the parts
p1.parts == p3.parts  # true
p1.parts == p2.parts  # false

# Size comparison
sum(p1.parts) == sum(p2.parts)  # true: both partition 13
```

## Example Workflows

### Exploring Conjugate Symmetry

```julia
# Create several partitions
partitions = [
    Partition([5, 5, 5]),      # Rectangular
    Partition([10]),           # Single row
    Partition([1, 1, 1, 1, 1]) # Single column
]

for p in partitions
    conj = conjugate(p)
    println("$(p.parts) → $(conj.parts)")
end
# Output:
# [5, 5, 5] → [3, 3, 3, 3, 3]
# [10] → [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
# [1, 1, 1, 1, 1] → [5]
```

### Hook Length Product

Used in counting standard Young tableaux:

```julia
function hook_product(p::Partition)
    hooks = hook_lengths(p)
    prod(vcat(hooks...))
end

p = Partition([3, 2, 1])
n = sum(p.parts)  # 6

# Number of standard Young tableaux
num_tableaux = factorial(n) ÷ hook_product(p)
println("Number of SYT: ", num_tableaux)  # 16
```

## Tips and Tricks

1. **Empty Partitions**: `Partition(Int[])` represents the empty partition
2. **Single Part**: `Partition([n])` is the partition with one part
3. **Staircase**: `Partition([n, n-1, n-2, ..., 1])` is called a staircase partition
4. **Self-conjugate**: Some partitions equal their conjugate (e.g., `[4, 3, 1, 1]`)

## Next Steps

- Learn about [Numerical Sets](@ref) and their properties
- Understand the [partition-semigroup bijection](@ref)
- Explore [Examples](@ref) with real applications
