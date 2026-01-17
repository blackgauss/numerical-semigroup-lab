# Core Types

This page documents the core data types provided by NumericalSemigroupLab.jl.

## NumericalSet

A numerical set is defined by its gaps (positive integers not in the set) and Frobenius number (largest gap).

### Fields

- `gaps::BitSet`: Set of gaps (positive integers not in the numerical set)
- `frobenius_number::Int`: The largest gap; -1 if no gaps exist

### Constructors

```julia
NumericalSet(gaps_list::Vector{Int})
```

Creates a numerical set from a list of gaps. The Frobenius number is computed automatically as the maximum gap, or -1 if the gap list is empty.

**Arguments:**
- `gaps_list`: Vector of non-negative integers representing gaps

**Returns:**
- `NumericalSet`: A new numerical set object

**Examples:**

```julia
# Standard numerical set
ns = NumericalSet([1, 2, 4, 5, 7])
frobenius_number(ns)  # 7

# Empty gaps (all of ℕ₀)
ns_all = NumericalSet(Int[])
frobenius_number(ns_all)  # -1

# Order doesn't matter
ns1 = NumericalSet([7, 2, 5, 1, 4])
ns2 = NumericalSet([1, 2, 4, 5, 7])
gaps(ns1) == gaps(ns2)  # true
```

**Validation:**
- All gaps must be non-negative integers
- Throws `ArgumentError` if validation fails

## Partition

An integer partition represented as a non-increasing sequence of positive integers.

### Fields

- `parts::Vector{Int}`: The parts of the partition in non-increasing order

### Constructors

```julia
Partition(parts::Vector{Int})
```

Creates a partition from a list of parts. Parts are automatically sorted in non-increasing order.

**Arguments:**
- `parts`: Vector of positive integers

**Returns:**
- `Partition`: A new partition object

**Examples:**

```julia
# Standard partition
p = Partition([5, 4, 3, 1])
p.parts  # [5, 4, 3, 1]

# Automatic sorting
p = Partition([3, 5, 1, 4])
p.parts  # [5, 4, 3, 1]

# Empty partition
p_empty = Partition(Int[])
p_empty.parts  # Int[]

# Single part
p_single = Partition([10])
p_single.parts  # [10]
```

**Validation:**
- All parts must be positive integers
- Throws `ArgumentError` if any part is ≤ 0

## NumericalSemigroup

A numerical semigroup extends `NumericalSet` with additional structure from generators.

### Fields

- `gaps::BitSet`: The gaps of the semigroup
- `frobenius::Int`: Largest gap (-1 if no gaps)
- `generators::Vector{Int}`: Minimal generating set
- `multiplicity::Int`: Smallest positive element

### Constructors

```julia
NumericalSemigroup(generators::Vector{Int})  # From generators
semigroup_from_gaps(gaps::Vector{Int})       # From gap set
```

## Poset

A partially ordered set with elements and relations.

### Fields

- `elements::Vector{T}`: Elements of the poset
- `relations::Set{Tuple{T,T}}`: Pairs (a,b) where a ≤ b

### Constructors

```julia
Poset(elements::Vector{T}, relations)  # From elements and relations
gap_poset(S::NumericalSemigroup)       # Divisibility poset on gaps
void_poset(S::NumericalSemigroup)      # Poset on pseudo-Frobenius numbers
```

## Type Hierarchy

```
Any
├── AbstractNumericalSet
│   ├── NumericalSet
│   └── NumericalSemigroup
└── Partition
└── Poset{T}
```

## Type Properties

### Immutability

All core types are **immutable structs**:

```julia
p = Partition([5, 4, 3, 1])
# p.parts[1] = 10  # ❌ Error: cannot modify immutable struct

# Must create new object
p_new = Partition([10, 4, 3, 1])  # ✓ Create new partition
```

**Rationale:** Immutability enables:
- Safe caching without defensive copying
- Thread-safe operations
- Predictable behavior

### Type Stability

All functions maintain type stability for performance:

```julia
# Return types are predictable
ns = NumericalSet([1, 2, 4])
typeof(frobenius_number(ns))  # Int64
typeof(gaps(ns))              # BitSet
typeof(partition(ns))         # Vector{Int64}

p = Partition([5, 4, 3])
typeof(conjugate(p))          # Partition
typeof(hook_lengths(p))       # Vector{Vector{Int64}}
```

### Construction Costs

| Type | Construction Time | Memory |
|------|------------------|---------|
| `NumericalSet` | O(n) | O(n) |
| `Partition` | O(n log n) | O(n) |

where n is the number of gaps/parts.

## Common Patterns

### Type Checking

```julia
ns = NumericalSet([1, 2, 4])
p = Partition([5, 4, 3])

ns isa NumericalSet  # true
p isa Partition      # true

typeof(ns) == NumericalSet  # true
typeof(p) == Partition      # true
```

### Type Conversion

```julia
# NumericalSet → Partition (via bijection)
ns = NumericalSet([1, 2, 4, 5, 7])
p_parts = partition(ns)      # Vector{Int}
p = Partition(p_parts)       # Partition

# Partition → gaps → NumericalSet
p = Partition([5, 4, 3, 1])
gaps_vec = gaps(p)           # Vector{Int}
ns = NumericalSet(gaps_vec)  # NumericalSet
```

### Working with Fields

```julia
# Access fields directly
ns = NumericalSet([1, 2, 4])
println(ns.frobenius_number)  # 4
println(typeof(ns.gaps))      # BitSet

p = Partition([5, 4, 3])
println(p.parts)              # [5, 4, 3]
println(length(p.parts))      # 3
```

## See Also

- `gaps`: Extract gaps from numerical sets or partitions
- `frobenius_number`: Get the Frobenius number
- `conjugate`: Compute partition conjugate
- `partition`: Convert numerical set to partition
