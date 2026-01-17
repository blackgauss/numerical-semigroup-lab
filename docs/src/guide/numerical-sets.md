# Working with Numerical Sets

Numerical sets are the dual objects to partitions, representing sets of non-negative integers with finitely many gaps.

## What is a Numerical Set?

A **numerical set** is a subset $N \subseteq \mathbb{N}_0 = \{0, 1, 2, 3, \ldots\}$ such that:
- The complement $\mathbb{N}_0 \setminus N$ (the **gaps**) is finite
- We always have $0 \in N$ (by convention)

The numerical set is completely determined by its finite set of gaps.

## Creating Numerical Sets

### From a List of Gaps

```julia
using NumericalSemigroupLab

# Create a numerical set with gaps {1, 2, 4, 5, 7}
ns = NumericalSet([1, 2, 4, 5, 7])

# The set contains: {0, 3, 6, 8, 9, 10, 11, 12, ...}
# (all non-negative integers except the gaps)
```

### Order Doesn't Matter

```julia
# These all create the same numerical set
ns1 = NumericalSet([1, 2, 4, 5, 7])
ns2 = NumericalSet([7, 5, 4, 2, 1])
ns3 = NumericalSet([2, 5, 1, 7, 4])

# All have the same gaps
gaps(ns1) == gaps(ns2)  # true (as BitSets)
```

### Empty Gaps

```julia
# A set with no gaps (all of ℕ₀)
ns_all = NumericalSet(Int[])

frobenius_number(ns_all)  # -1 (convention for no gaps)
multiplicity(ns_all)      # 1 (smallest positive element)
```

## Fundamental Properties

### Frobenius Number

The **largest gap** in the set:

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
F = frobenius_number(ns)  # 7
```

**Meaning:** All integers greater than $F$ are in the set.

```julia
# Check: all integers > 7 should be in the set
# (i.e., not be gaps)
for n in 8:20
    @assert !(n in gaps(ns))  # n is NOT a gap
end
```

### Multiplicity  

The **smallest positive element** in the set:

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
m = multiplicity(ns)  # 3
```

**Meaning:** 3 is the smallest positive integer not in the gap list.

```julia
# Verify
@assert !(3 in gaps(ns))  # 3 is not a gap
@assert all(i in gaps(ns) for i in 1:2)  # 1,2 are gaps
```

### Small Elements

All elements less than the Frobenius number:

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
smalls = small_elements(ns)  # [0, 3, 6]
```

These are the non-negative integers $< F$ that are **not** gaps:

```julia
F = frobenius_number(ns)  # 7
gaps_set = Set(gaps(ns))
manual_smalls = [x for x in 0:F-1 if !(x in gaps_set)]
manual_smalls == smalls  # true
```

### Accessing Gaps

```julia
ns = NumericalSet([1, 2, 4, 5, 7])

# Get gaps as a BitSet
g = gaps(ns)

# Convert to sorted array
sorted_gaps = sort(collect(g))  # [1, 2, 4, 5, 7]

# Check membership
1 in g  # true
3 in g  # false
```

## The Partition Correspondence

### Converting to Partition

Every numerical set corresponds to a unique partition:

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
p_parts = partition(ns)

println(p_parts)  # [3, 3, 2, 2, 1, 1]
```

### Round-Trip Conversion

The correspondence is a bijection:

```julia
# Start with gaps
original_gaps = [1, 2, 4, 5, 7]
ns = NumericalSet(original_gaps)

# Convert to partition
p_parts = partition(ns)
p = Partition(p_parts)

# Convert back to gaps
recovered_gaps = sort(collect(gaps(p)))

println(original_gaps == recovered_gaps)  # true
```

### How the Bijection Works

The algorithm uses a "walk" on a grid:

1. Start at $(0, F)$ where $F$ is the Frobenius number
2. Walk to $(F, 0)$ following these rules:
   - At position $(x, y)$, check if $x+1$ is a gap
   - If yes: move down $(x, y) \to (x, y-1)$
   - If no: move right $(x, y) \to (x+1, y)$
3. The $y$-coordinates form the partition

**Example:** For gaps $\{1, 2, 4, 5, 7\}$:

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
F = frobenius_number(ns)  # 7

# Walk from (0,7) to (7,0):
# x=0: 1 is gap → down → y stays at 7-1=6
# x=1: 2 is gap → down → y stays at 6-1=5  
# x=2: 3 NOT gap → right → record y=5, reset
# x=3: 4 is gap → down → y=5-1=4
# ...

# This produces partition [3, 3, 2, 2, 1, 1]
```

## Advanced Operations

### Atom Monoid

The **atom monoid** is a related numerical set with special properties:

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
atom_gaps = atom_monoid_gaps(ns)

println(sort(collect(atom_gaps)))
```

**Mathematical meaning:** Elements that cannot be written as sums of two positive elements in the set.

### Relationship to Partition Hooks

The atom monoid gaps are related to the hook lengths of the corresponding partition:

```julia
ns = NumericalSet([1, 2, 4, 5, 7])

# Via numerical set
atom_gaps_ns = sort(collect(atom_monoid_gaps(ns)))

# Via partition
p = Partition(partition(ns))
atom_gaps_p = sort(atom_monoid_gaps(p))

# They match!
atom_gaps_ns == atom_gaps_p  # true
```

## Practical Examples

### Example 1: Checking Semigroup Properties

```julia
function is_numerical_semigroup(gaps_list)
    ns = NumericalSet(gaps_list)
    g = Set(collect(gaps(ns)))
    F = frobenius_number(ns)
    
    # Check closure under addition
    for x in 0:F
        for y in 0:F
            if !(x in g) && !(y in g)  # both in set
                z = x + y
                if z <= F && z in g  # sum is a gap
                    return false
                end
            end
        end
    end
    return true
end

# Test with known semigroup
is_numerical_semigroup([1, 2, 4, 5, 7])  # true

# Test with non-semigroup
is_numerical_semigroup([1, 3, 5, 7])     # Check result
```

### Example 2: Exploring the Genus

```julia
# Genus is the number of gaps
function genus(gaps_list)
    length(gaps_list)
end

# Create numerical sets of genus 5
examples_genus_5 = [
    [1, 2, 3, 4, 5],
    [1, 2, 4, 5, 7],
    [2, 3, 4, 6, 7],
]

for gaps in examples_genus_5
    ns = NumericalSet(gaps)
    println("Gaps: $gaps")
    println("  Frobenius: ", frobenius_number(ns))
    println("  Multiplicity: ", multiplicity(ns))
    println("  Partition: ", partition(ns))
    println()
end
```

### Example 3: Frobenius Numbers

```julia
# For 2-generator numerical semigroups <a,b> with gcd(a,b)=1,
# the Frobenius number is ab - a - b

function check_frobenius_formula(a, b)
    @assert gcd(a, b) == 1
    
    # Compute gaps up to ab
    gaps = Int[]
    for n in 1:a*b
        if !any(n == i*a + j*b for i in 0:n÷a for j in 0:n÷b)
            push!(gaps, n)
        end
    end
    
    ns = NumericalSet(gaps)
    F_computed = frobenius_number(ns)
    F_formula = a*b - a - b
    
    return F_computed == F_formula
end

# Test the formula
check_frobenius_formula(3, 5)   # true: F = 3*5-3-5 = 7
check_frobenius_formula(7, 11)  # true: F = 7*11-7-11 = 59
```

## Performance Tips

### Efficient Gap Checking

```julia
# Get gaps as BitSet for O(1) membership testing
ns = NumericalSet([1, 2, 4, 5, 7])
g = gaps(ns)  # Returns BitSet

# Fast checking
@time 100 in g  # Very fast with BitSet

# Don't convert to array unless needed
# sorted_gaps = sort(collect(g))  # Avoid if possible
```

### Batch Operations

```julia
# Process many numerical sets
function analyze_batch(gap_lists)
    results = []
    for gaps in gap_lists
        ns = NumericalSet(gaps)
        push!(results, (
            frobenius = frobenius_number(ns),
            multiplicity = multiplicity(ns),
            genus = length(gaps)
        ))
    end
    return results
end

gap_lists = [
    [1, 2, 4],
    [1, 3, 5],
    [2, 3, 4, 6],
]

@time results = analyze_batch(gap_lists)
```

## Common Patterns

### Finding All Gaps Up To Frobenius

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
F = frobenius_number(ns)
g = gaps(ns)

all_gaps = sort([x for x in collect(g) if x <= F])
println(all_gaps)  # [1, 2, 4, 5, 7]
```

### Computing Genus

```julia
# Genus = number of gaps
ns = NumericalSet([1, 2, 4, 5, 7])
genus_value = length(collect(gaps(ns)))  # 5
```

### Checking Element Membership

```julia
ns = NumericalSet([1, 2, 4, 5, 7])
g = gaps(ns)

function in_numerical_set(n, gaps_set)
    !(n in gaps_set)
end

in_numerical_set(3, g)  # true: 3 is in the set
in_numerical_set(5, g)  # false: 5 is a gap
```

## Connection to Semigroups

A numerical set corresponds to a **numerical semigroup** if and only if it's closed under addition.

```julia
# The numerical set with gaps [1,2,4,5,7] corresponds to
# the semigroup generated by {3, 8}
ns = NumericalSet([1, 2, 4, 5, 7])

# Check: is 3 in the set? (Yes, not a gap)
@assert !(3 in gaps(ns))

# Check: is 8 in the set? (Yes, not a gap)  
@assert !(8 in gaps(ns))

# All other elements can be generated from 3 and 8
# 6 = 3+3, 9 = 3+3+3, 11 = 3+8, etc.
```

## Next Steps

- Learn about [Numerical Semigroups](semigroups.md) and generators
- Explore the [Mathematical Background](../math-background.md) of the bijection
- Try [Advanced Examples](../examples/advanced.md) with real computations
