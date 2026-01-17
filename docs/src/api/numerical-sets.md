# Numerical Set Operations

Complete API reference for numerical set operations.

## Constructors

See [Core Types - NumericalSet](#NumericalSet) for detailed constructor documentation.

## Accessors

### `gaps(::NumericalSet)`

```julia
gaps(ns::NumericalSet) -> BitSet
```

Return the BitSet of gaps from a numerical set.

**Arguments:**
- `ns::NumericalSet`: The numerical set

**Returns:**
- `BitSet`: The set of gaps

**Examples:**

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
g = gaps(ns)

# Check membership (O(1))
1 in g  # true
3 in g  # false

# Convert to sorted array
sort(collect(g))  # [1, 2, 4, 5, 7]
```

### `frobenius_number(::NumericalSet)`

```julia
frobenius_number(ns::NumericalSet) -> Int
```

Return the Frobenius number (largest gap) of a numerical set.

**Arguments:**
- `ns::NumericalSet`: The numerical set

**Returns:**
- `Int`: The Frobenius number, or -1 if no gaps exist

**Examples:**

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
frobenius_number(ns)  # 7

ns_empty = NumericalSet(Int[])
frobenius_number(ns_empty)  # -1
```

**Property:** All integers > F are in the numerical set (not gaps).

## Properties

### `multiplicity`

```julia
multiplicity(ns::NumericalSet) -> Int
```

Compute the multiplicity (smallest positive element) of a numerical set.

The multiplicity is the smallest positive integer that is NOT a gap.

**Arguments:**
- `ns::NumericalSet`: The numerical set

**Returns:**
- `Int`: The multiplicity

**Examples:**

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
multiplicity(ns)  # 3

ns = NumericalSet([2, 3, 4, 6, 7, 8])
multiplicity(ns)  # 1 (nothing prevents 1)
# Actually 1 IS a generator

ns = NumericalSet([1, 3, 5, 7])
multiplicity(ns)  # 2
```

**Algorithm:** O(F) where F is the Frobenius number

**See Also:** `small_elements`

### `small_elements`

```julia
small_elements(ns::NumericalSet) -> Vector{Int}
```

Return all elements less than the Frobenius number.

These are the non-negative integers smaller than F that are NOT gaps.

**Arguments:**
- `ns::NumericalSet`: The numerical set

**Returns:**
- `Vector{Int}`: Sorted vector of small elements

**Examples:**

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
small_elements(ns)  # [0, 3, 6]

# Verify: these are elements < 7 that aren't gaps
F = frobenius_number(ns)  # 7
g = gaps(ns)
[x for x in 0:F-1 if !(x in g)] == small_elements(ns)  # true
```

**Algorithm:** O(F) where F is the Frobenius number

**See Also:** `frobenius_number`, `multiplicity`

## Conversion to Partition

### `partition`

```julia
partition(ns::NumericalSet) -> Vector{Int}
```

Convert a numerical set to its corresponding partition using the bijection.

Uses a walk algorithm on a grid from (0, F) to (F, 0), where F is the Frobenius number. At each position, move down if the next integer is a gap, otherwise move right.

**Arguments:**
- `ns::NumericalSet`: The numerical set

**Returns:**
- `Vector{Int}`: Parts of the corresponding partition

**Examples:**

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
p_parts = partition(ns)  # [3, 3, 2, 2, 1, 1]

# Create partition object
p = Partition(p_parts)

# Round-trip
ns2 = NumericalSet(gaps(p))
gaps(ns) == gaps(ns2)  # true (as BitSets)
```

**Algorithm:** O(F²) where F is the Frobenius number

**Mathematical Background:**  
The bijection between numerical sets and partitions is based on a boundary walk of the Ferrers diagram. See [Mathematical Background](../math-background.md) for details.

**See Also:** [`gaps(::Partition)`](@ref)

## Atom Monoid

### `atom_monoid_gaps`

```julia
atom_monoid_gaps(ns::NumericalSet) -> BitSet
```

Compute the gaps of the atom monoid of a numerical set.

The atom monoid consists of elements that cannot be written as sums of two positive elements in the set. This function returns the gaps of that atom monoid.

**Arguments:**
- `ns::NumericalSet`: The numerical set

**Returns:**
- `BitSet`: Gaps of the atom monoid

**Examples:**

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
atom_gaps = atom_monoid_gaps(ns)
println(sort(collect(atom_gaps)))
```

**Algorithm:**  
1. Identify small elements S = {s₁, ..., sₖ}
2. For each potential gap g, check if g = s + t for some s, t ∈ N with s,t > 0
3. If no such representation exists and g ≤ max gap, g is an atom gap

**Complexity:** O(F² · |S|) where F is Frobenius number and S is small elements

**See Also:** `small_elements`, `atom_monoid_gaps`

## Practical Examples

### Example: Two-Generator Semigroups

```julia
# For coprime a, b, the semigroup <a,b> has Frobenius number ab-a-b
function two_generator_semigroup(a::Int, b::Int)
    @assert gcd(a, b) == 1 "Generators must be coprime"
    
    # Find all gaps up to ab
    gaps = Int[]
    for n in 1:a*b
        # Check if n can be written as ia + jb with i,j ≥ 0
        is_gap = true
        for i in 0:n÷a
            if (n - i*a) % b == 0
                is_gap = false
                break
            end
        end
        if is_gap
            push!(gaps, n)
        end
    end
    
    return NumericalSet(gaps)
end

# Example: <3, 5>
ns = two_generator_semigroup(3, 5)
frobenius_number(ns)  # 7 (= 3*5 - 3 - 5)
multiplicity(ns)      # 3
small_elements(ns)    # [0, 3, 5, 6]
```

### Example: Genus and Frobenius Relationship

```julia
function analyze_genus_frobenius(gap_lists)
    results = []
    for gaps in gap_lists
        ns = NumericalSet(gaps)
        push!(results, (
            gaps = gaps,
            genus = length(gaps),
            frobenius = frobenius_number(ns),
            multiplicity = multiplicity(ns)
        ))
    end
    return results
end

examples = [
    [1, 2, 3],
    [1, 2, 4, 5],
    [1, 3, 5, 7, 9],
    [2, 3, 4, 6, 7, 8],
]

results = analyze_genus_frobenius(examples)
for r in results
    println("Gaps: ", r.gaps)
    println("  Genus: ", r.genus, ", Frobenius: ", r.frobenius, 
            ", Multiplicity: ", r.multiplicity)
end
```

### Example: Element Membership Testing

```julia
function is_in_numerical_set(n::Int, ns::NumericalSet)
    g = gaps(ns)
    return !(n in g) && n >= 0
end

ns = NumericalSet([1, 2, 4, 5, 7])

# Test membership
for n in 0:10
    if is_in_numerical_set(n, ns)
        println("$n ∈ N")
    else
        println("$n ∉ N (gap)")
    end
end
# Output:
# 0 ∈ N
# 1 ∉ N (gap)
# 2 ∉ N (gap)
# 3 ∈ N
# ... etc
```

### Example: Verifying Semigroup Property

```julia
function verify_semigroup_closure(ns::NumericalSet)
    g = Set(collect(gaps(ns)))
    F = frobenius_number(ns)
    
    # Check all pairs of elements up to F
    for x in 0:F
        for y in 0:F
            # If both x and y are in the set
            if !(x in g) && !(y in g)
                z = x + y
                # Then z should also be in the set
                if z <= F && z in g
                    return false, "Closure fails: $x + $y = $z is a gap"
                end
            end
        end
    end
    return true, "Closure verified"
end

ns = NumericalSet([1, 2, 4, 5, 7])
is_closed, msg = verify_semigroup_closure(ns)
println(msg)
```

## Performance Tips

### Efficient Gap Testing

```julia
# gaps(ns) returns a BitSet - very fast membership testing
ns = NumericalSet([1, 2, 4, 5, 7])
g = gaps(ns)

# O(1) membership check
@time 1 in g    # Very fast
@time 100 in g  # Very fast

# Avoid converting to arrays unless necessary
# gaps_array = collect(g)  # Only if you need to iterate
```

### Batch Processing

```julia
# Process multiple numerical sets efficiently
function compute_invariants(gap_lists)
    map(gap_lists) do gaps
        ns = NumericalSet(gaps)
        (
            frobenius = frobenius_number(ns),
            genus = length(gaps),
            multiplicity = multiplicity(ns),
            partition = partition(ns)
        )
    end
end

gap_lists = [
    [1, 2, 4],
    [1, 3, 5],
    [2, 3, 4, 6, 7],
]

@time results = compute_invariants(gap_lists)
```

### Caching Considerations

Most NumericalSet operations don't use caching (gaps are stored directly). However, if you convert to Partition and use partition operations, those will be cached.

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
p = Partition(partition(ns))

# These will be cached
@time hooks1 = hook_lengths(p)  # Computed
@time hooks2 = hook_lengths(p)  # Cached
```

## See Also

- [Partition Operations](partitions.md): Converting between representations
- `Partition`: The dual type
- [Mathematical Background](../math-background.md): Theory behind the bijection
