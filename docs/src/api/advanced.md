# Advanced Features API

This page documents the advanced features: posets, weight computations, tree navigation, and special gaps.

## Poset Operations

A `Poset{T}` represents a partially ordered set with elements of type `T` and a set of relations.

```@docs
Poset
gap_poset
void_poset
cover_relations
is_below
is_above
upper_set
lower_set
maximal_elements
minimal_elements
is_chain
```

### Examples

```julia
using NumericalSemigroupLab

S = NumericalSemigroup([3, 5, 7])  # gaps = [1, 2, 4]

# Create the gap poset (divisibility order)
P = gap_poset(S)
P.elements  # [1, 2, 4]

# Check relations: 1 | 2 and 1 | 4
is_below(P, 1, 2)  # true (1 divides 2)
is_below(P, 2, 4)  # true (2 divides 4)
is_below(P, 1, 4)  # true (1 divides 4, by transitivity)

# Maximal elements in divisibility order
maximal_elements(P)  # [4]

# Cover relations (Hasse diagram edges)
cover_relations(P)   # [(1, 2), (2, 4)]
```

## Weight Computations

Weight functions measure various structural properties of numerical semigroups.

```@docs
effective_weight
apery_weight
kunz_coordinates
depth
delta_set
catenary_degree
```

### Examples

```julia
using NumericalSemigroupLab

S = NumericalSemigroup([3, 5])

# Effective weight: pairs (s₁, s₂) in S with s₁ + s₂ = g
effective_weight(S, 6)   # 1 (pair: 3+3)
effective_weight(S, 8)   # 1 (pair: 3+5)
effective_weight(S, 10)  # 1 (pair: 5+5)

# Kunz coordinates
kunz_coordinates(S)  # Kunz tuple relative to multiplicity

# Depth
depth(S)  # Maximum ⌊w/m⌋ for w in Apéry set
```

## Tree Navigation

Functions for navigating the genus tree of numerical semigroups.

```@docs
get_parent
get_children
effective_generators
remove_minimal_generator
genus_path
ancestors
descendants
```

### Examples

```julia
using NumericalSemigroupLab

S = NumericalSemigroup([3, 5])  # genus 4

# Parent: add back the Frobenius number
parent = get_parent(S)
genus(parent)  # 3

# Full ancestry back to ℕ₀
path = genus_path(S)
length(path)  # 5 (ℕ₀ → ... → S)

# Children in genus tree
children = get_children(S)

# Effective generators: can be removed to get children
effective_generators(S)
```

## Special Gaps

Functions for working with pseudo-Frobenius numbers and symmetry properties.

```@docs
special_gaps
is_symmetric
is_pseudo_symmetric
fundamental_gaps
forced_gaps
add_specialgap
get_frobchildren
```

### Definitions

- **Special gaps** (pseudo-Frobenius numbers): Gaps g such that g + s ∈ S for all s > 0 in S
- **Symmetric semigroup**: For each gap g, F - g is in S (where F is the Frobenius number)
- **Pseudo-symmetric**: Has exactly 2 pseudo-Frobenius numbers with specific structure
- **Fundamental gaps**: Minimal gaps that generate all gaps under the semigroup operation

### Examples

```julia
using NumericalSemigroupLab

# Symmetric semigroup
S = NumericalSemigroup([3, 5])  # gaps = [1, 2, 4, 7], F = 7
is_symmetric(S)       # true
special_gaps(S)       # [7] (only the Frobenius)

# Non-symmetric semigroup
T = NumericalSemigroup([3, 7, 11])
is_symmetric(T)       # false
special_gaps(T)       # Multiple pseudo-Frobenius numbers

# Frobenius children: semigroups with same Frobenius as children
frobchildren = get_frobchildren(S)
```

### Mathematical Background

A numerical semigroup S is **symmetric** if and only if it has a unique pseudo-Frobenius number (which must be the Frobenius number). Equivalently:

$$\text{S is symmetric} \iff |\text{PF}(S)| = 1 \iff \forall g \in G(S): F - g \in S$$

where G(S) is the gap set and F is the Frobenius number.

The **type** of a semigroup is the number of pseudo-Frobenius numbers:
- Type 1 = symmetric
- Type 2 with F/2 ∈ PF(S) = pseudo-symmetric

## See Also

- [Numerical Semigroups API](numerical-semigroups.md) - Core semigroup functions
- [Guide: Semigroups](../guide/semigroups.md) - User guide with examples
