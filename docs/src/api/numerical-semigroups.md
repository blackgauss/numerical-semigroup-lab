# Numerical Semigroup Operations

Complete API reference for numerical semigroup operations.

## Overview

A **numerical semigroup** is a subset $S \subseteq \mathbb{N}_0$ that is:
1. Closed under addition: $a, b \in S \Rightarrow a + b \in S$
2. Contains zero: $0 \in S$
3. Has finite complement in $\mathbb{N}_0$ (finitely many gaps)

Every numerical semigroup can be uniquely represented by its minimal generating set.

## Constructors

### `NumericalSemigroup`

```julia
NumericalSemigroup(generators::Vector{Int})
```

Create a numerical semigroup from its generators.

**Arguments:**
- `generators::Vector{Int}`: Positive integers that generate the semigroup

**Returns:**
- `NumericalSemigroup`: The numerical semigroup

**Examples:**

```julia
# Create semigroup ⟨3, 5⟩
S = NumericalSemigroup([3, 5])
S.frobenius  # 7
S.genus      # 4
```

### `semigroup_from_generators`

```julia
semigroup_from_generators(generators::Vector{Int}) -> NumericalSemigroup
```

Explicit factory function to create a semigroup from generators.

**Examples:**

```julia
S = semigroup_from_generators([5, 7, 11])
```

### `semigroup_from_gaps`

```julia
semigroup_from_gaps(gap_list::Vector{Int}) -> NumericalSemigroup
```

Create a numerical semigroup from its gap set.

**Arguments:**
- `gap_list::Vector{Int}`: The gaps of the semigroup

**Returns:**
- `NumericalSemigroup`: The numerical semigroup with these gaps

**Examples:**

```julia
S = semigroup_from_gaps([1, 2, 4, 7])
generators(S)  # [3, 5]
```

## Property Accessors

### `gaps`

```julia
gaps(S::NumericalSemigroup) -> BitSet
```

Return the gaps of the semigroup as a BitSet.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
gaps(S)  # BitSet([1, 2, 4, 7])
```

### `generators`

```julia
generators(S::NumericalSemigroup) -> Vector{Int}
```

Return the minimal generating set of the semigroup.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
generators(S)  # [3, 5]
```

### `genus`

```julia
genus(S::NumericalSemigroup) -> Int
```

Return the genus (number of gaps) of the semigroup.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
genus(S)  # 4
```

### `frobenius_number`

```julia
frobenius_number(S::NumericalSemigroup) -> Int
```

Return the Frobenius number (largest gap) of the semigroup.
Returns -1 if the semigroup has no gaps (i.e., is $\mathbb{N}_0$).

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
frobenius_number(S)  # 7
```

### `multiplicity`

```julia
multiplicity(S::NumericalSemigroup) -> Int
```

Return the multiplicity (smallest positive element) of the semigroup.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
multiplicity(S)  # 3
```

### `embedding_dimension`

```julia
embedding_dimension(S::NumericalSemigroup) -> Int
```

Return the embedding dimension (cardinality of minimal generating set).

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
embedding_dimension(S)  # 2
```

## Membership and Elements

### `in`

```julia
n in S
Base.in(n::Int, S::NumericalSemigroup) -> Bool
```

Check if an integer belongs to the semigroup.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
3 in S   # true
4 in S   # false
8 in S   # true (8 = 3 + 5)
```

### `elements_up_to`

```julia
elements_up_to(S::NumericalSemigroup, n::Int) -> Vector{Int}
```

Return all elements of the semigroup that are at most `n`.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
elements_up_to(S, 15)  # [0, 3, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15]
```

### `small_elements`

```julia
small_elements(S::NumericalSemigroup) -> Vector{Int}
```

Return elements smaller than the Frobenius number.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
small_elements(S)  # [0, 3, 5, 6]
```

## Apéry Sets

### `apery_set`

```julia
apery_set(S::NumericalSemigroup, n::Int) -> Vector{Int}
apery_set(S::NumericalSemigroup) -> Vector{Int}
```

Compute the Apéry set of `S` with respect to `n`.

The Apéry set $\text{Ap}(S, n)$ consists of the smallest element in each residue class modulo $n$:

$$\text{Ap}(S, n) = \{s \in S : s - n \notin S\}$$

If `n` is not provided, uses the multiplicity.

**Arguments:**
- `S::NumericalSemigroup`: The semigroup
- `n::Int`: The modulus (must be in the semigroup)

**Returns:**
- `Vector{Int}`: The Apéry set (length `n`)

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
apery_set(S, 3)  # [0, 5, 10] - smallest in each class mod 3
apery_set(S)     # Same as apery_set(S, multiplicity(S))
```

## Minimal Generators

### `is_minimal_generator`

```julia
is_minimal_generator(S::NumericalSemigroup, n::Int) -> Bool
```

Check if `n` is a minimal generator of the semigroup.

An element is a minimal generator if it cannot be expressed as a sum of smaller elements of the semigroup.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
is_minimal_generator(S, 3)  # true
is_minimal_generator(S, 5)  # true
is_minimal_generator(S, 6)  # false (6 = 3 + 3)
```

### `minimal_generating_set`

```julia
minimal_generating_set(S::NumericalSemigroup) -> Vector{Int}
```

Return the minimal generating set of the semigroup. Alias for `generators(S)`.

## Gap Computation

### `compute_gaps_from_generators`

```julia
compute_gaps_from_generators(generators::Vector{Int}) -> Vector{Int}
```

Compute the gaps of a numerical semigroup from its generators.

Uses an optimized algorithm for two coprime generators based on the Sylvester-Frobenius theorem.

**Examples:**

```julia
compute_gaps_from_generators([3, 5])  # [1, 2, 4, 7]
compute_gaps_from_generators([7, 11]) # 30 gaps, largest is 59
```

## Partition Correspondence

### `partition`

```julia
partition(S::NumericalSemigroup) -> Vector{Int}
```

Convert the semigroup to its corresponding partition via the walk profile algorithm.

**Examples:**

```julia
S = NumericalSemigroup([3, 5])
partition(S)  # The partition corresponding to gaps [1, 2, 4, 7]
```

### `atom_monoid_gaps`

```julia
atom_monoid_gaps(S::NumericalSemigroup) -> Set{Int}
```

Compute the gaps of the atom monoid of the semigroup.

## Type Hierarchy

`NumericalSemigroup <: AbstractNumericalSet`

All functions that work on `AbstractNumericalSet` (like `gaps`, `frobenius_number`, `partition`, etc.) work on both `NumericalSet` and `NumericalSemigroup`.

## See Also

- [Numerical Set Operations](@ref) - Functions for numerical sets
- [Core Types](@ref) - Type definitions
- [Mathematical Background](@ref) - Theory of numerical semigroups
