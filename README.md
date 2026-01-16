# NumericalSemigroupLab.jl

A high-performance Julia package for computing with numerical semigroups, numerical sets, and integer partitions.

[![Build Status](https://github.com/blackgauss/numerical-semigroup-lab/workflows/CI/badge.svg)](https://github.com/blackgauss/numerical-semigroup-lab/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Author

**Erik Imathiu-Jones** ([@blackgauss](https://github.com/blackgauss))

This project was developed with extensive use of [Claude](https://claude.ai) (Anthropic) as an AI programming assistant. While Claude assisted with code generation, documentation, and testing, all mathematical concepts, architectural decisions, and final implementations were carefully reviewed and directed by the author.

## Overview

This is a Julia port of [pocketpartition](https://github.com/blackgauss/pocketpartition) with a focus on:

- **Performance**: 10-100x faster than Python implementation
- **Type Safety**: Leverages Julia's powerful type system
- **Modularity**: Clean architecture for easy maintenance and extension
- **Python Interoperability**: Callable from Python via PythonCall.jl

## Features

### Core Data Structures
- `NumericalSet`: Numerical sets defined by gaps with bijection to partitions
- `Partition`: Integer partitions with hook lengths, conjugation, and profiles
- Efficient caching infrastructure for expensive computations

### Numerical Semigroups
- `NumericalSemigroup`: Full implementation with constructors from gaps/generators
- Apéry set computation with caching
- Minimal generating set algorithms
- Membership testing and element generation
- Gap computation from generators (with optimized 2-generator algorithm)

### Advanced Features
- `Poset`: Partially ordered sets with divisibility posets
- Weight computations (effective weight, Apéry weight, Kunz coordinates)
- Tree navigation (parent/children in genus tree, ancestors, descendants)
- Special gaps, symmetry detection, and Frobenius children

## Installation

```julia
# In Julia REPL
using Pkg
Pkg.add(url="https://github.com/blackgauss/numerical-semigroup-lab")
```

Or activate the local package:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## Quick Start

```julia
using NumericalSemigroupLab

# Create a numerical semigroup from generators
S = NumericalSemigroup([3, 5])

# Access properties
genus(S)              # 4 - number of gaps
frobenius_number(S)   # 7 - largest gap
multiplicity(S)       # 3 - smallest positive element
embedding_dimension(S) # 2 - number of minimal generators

# Get the generators and gaps
generators(S)         # [3, 5]
collect(S.gaps)       # [1, 2, 4, 7]

# Membership testing
3 in S                # true
4 in S                # false (4 is a gap)
8 in S                # true (8 = 3 + 5)

# Get elements up to a value
elements_up_to(S, 15) # [0, 3, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15]

# Compute Apéry set
apery_set(S, 3)       # [0, 5, 10] - smallest in each residue class mod 3

# Check minimal generators
is_minimal_generator(S, 3)  # true
is_minimal_generator(S, 6)  # false (6 = 3+3)

# Create from gaps
T = semigroup_from_gaps([1, 2, 4, 7])  # Same as ⟨3, 5⟩
S == T                # true
```

### Advanced Features

```julia
using NumericalSemigroupLab

S = NumericalSemigroup([3, 5])

# Symmetry detection
is_symmetric(S)           # true - ⟨3,5⟩ is symmetric

# Special gaps (pseudo-Frobenius numbers)
special_gaps(S)           # [7] - only the Frobenius number

# Tree navigation
parent_S = get_parent(S)  # ⟨3,5,7⟩ - add Frobenius back
children = get_children(S) # Descendants in genus tree

# Weight computations
effective_weight(S, 8)    # Number of pairs summing to 8
kunz_coordinates(S)       # Kunz coordinate vector
depth(S)                  # Depth of the semigroup

# Poset operations
P = gap_poset(S)          # Divisibility poset on gaps
maximal_elements(P)       # Maximal gaps in divisibility order

# Frobenius children
frobchildren = get_frobchildren(S)  # Children with same Frobenius
```

### Working with Partitions

```julia
# Create a partition
P = Partition([5, 4, 3, 1])

# Conjugate partition (transpose Ferrers diagram)
conj = conjugate(P)   # Partition([4, 3, 3, 2, 1])

# Hook lengths at each cell
hooks = hook_lengths(P)

# Profile (boundary walk)
prof = profile(P)

# Bijection: NumericalSet ↔ Partition
ns = NumericalSet([1, 2, 4, 5, 7])
p = partition(ns)     # Get corresponding partition
```

### Working with Numerical Sets

```julia
# Create a numerical set from gaps
ns = NumericalSet([1, 2, 4, 5, 7])

# Properties
frobenius_number(ns)  # 7
gaps(ns)              # BitSet with [1, 2, 4, 5, 7]
multiplicity(ns)      # 3

# Small elements (non-gaps up to Frobenius)
small_elements(ns)    # [0, 3, 6]

# Atom monoid gaps
atom_monoid_gaps(ns)
```

## API Reference

### Core Types

| Type | Description |
|------|-------------|
| `NumericalSemigroup` | A numerical semigroup with generators, gaps, and properties |
| `NumericalSet` | A numerical set defined by its gaps |
| `Partition` | An integer partition with hook length support |
| `Poset` | A partially ordered set with elements and relations |

### NumericalSemigroup Functions

| Function | Description |
|----------|-------------|
| `NumericalSemigroup(gens)` | Create from generators |
| `semigroup_from_generators(gens)` | Create from generators (explicit) |
| `semigroup_from_gaps(gaps)` | Create from gap set |
| `gaps(S)` | Get gaps as BitSet |
| `genus(S)` | Number of gaps |
| `frobenius_number(S)` | Largest gap (-1 if no gaps) |
| `multiplicity(S)` | Smallest positive element |
| `embedding_dimension(S)` | Number of minimal generators |
| `generators(S)` | Get minimal generating set |
| `minimal_generating_set(S)` | Alias for generators |
| `is_minimal_generator(S, n)` | Check if n is a minimal generator |
| `n in S` | Check membership |
| `elements_up_to(S, n)` | All elements ≤ n |
| `apery_set(S, n)` | Apéry set with respect to n |
| `apery_set(S)` | Apéry set with respect to multiplicity |
| `small_elements(S)` | Non-gaps up to Frobenius number |
| `partition(S)` | Convert to partition |
| `atom_monoid_gaps(S)` | Compute atom monoid gaps |
| `compute_gaps_from_generators(gens)` | Compute gaps from generators |

### Partition Functions

| Function | Description |
|----------|-------------|
| `Partition(parts)` | Create partition (auto-sorted) |
| `conjugate(P)` | Transpose the Ferrers diagram |
| `hook_lengths(P)` | Matrix of hook lengths |
| `profile(P)` | Boundary walk as direction tuples |
| `atom_partition(P)` | Atom partition |
| `is_semigroup(P)` | Check if partition corresponds to semigroup |

### NumericalSet Functions

| Function | Description |
|----------|-------------|
| `NumericalSet(gaps)` | Create from gap vector |
| `gaps(ns)` | Get gaps as BitSet |
| `frobenius_number(ns)` | Largest gap |
| `multiplicity(ns)` | Smallest positive non-gap |
| `small_elements(ns)` | Non-gaps up to Frobenius number |
| `partition(ns)` | Convert to partition |
| `atom_monoid_gaps(ns)` | Compute atom monoid gaps |

### Utility Functions

| Function | Description |
|----------|-------------|
| `clear_all_caches!()` | Clear all computation caches |
| `clear_apery_cache!()` | Clear Apéry set cache |

### Poset Functions

| Function | Description |
|----------|-------------|
| `Poset(elements, relations)` | Create a poset from elements and relations |
| `gap_poset(S)` | Divisibility poset on gaps of S |
| `void_poset(S)` | Poset restricted to pseudo-Frobenius numbers |
| `cover_relations(P)` | Get minimal (cover) relations |
| `is_below(P, a, b)` | Check if a ≤ b in the poset |
| `is_above(P, a, b)` | Check if a ≥ b in the poset |
| `upper_set(P, x)` | Elements ≥ x |
| `lower_set(P, x)` | Elements ≤ x |
| `maximal_elements(P)` | Get maximal elements |
| `minimal_elements(P)` | Get minimal elements |
| `is_chain(P)` | Check if poset is totally ordered |

### Weight Functions

| Function | Description |
|----------|-------------|
| `effective_weight(S, g)` | Number of pairs (s₁, s₂) in S with s₁ + s₂ = g |
| `apery_weight(S, n)` | Sum of ⌊w/n⌋ for w in Apéry set |
| `kunz_coordinates(S)` | Vector of Kunz coordinates |
| `depth(S)` | Largest Apéry element ÷ multiplicity |
| `delta_set(S)` | Set of factorization length differences |
| `catenary_degree(S)` | Maximum catenary degree |

### Tree Navigation Functions

| Function | Description |
|----------|-------------|
| `get_parent(S)` | Parent semigroup in genus tree (add Frobenius) |
| `get_children(S)` | Children semigroups (remove effective generators) |
| `effective_generators(S)` | Generators that can be removed |
| `remove_minimal_generator(S, g)` | Remove generator g from S |
| `genus_path(S)` | Path from ℕ₀ to S |
| `ancestors(S)` | All ancestors up to ℕ₀ |
| `descendants(S, depth)` | Descendants up to given depth |

### Special Gap Functions

| Function | Description |
|----------|-------------|
| `special_gaps(S)` | Pseudo-Frobenius numbers (void elements) |
| `is_symmetric(S)` | Check if semigroup is symmetric |
| `is_pseudo_symmetric(S)` | Check if semigroup is pseudo-symmetric |
| `fundamental_gaps(S)` | Minimal gaps generating all gaps |
| `forced_gaps(S, g)` | Gaps forced by adding g as special gap |
| `add_specialgap(S, g)` | Add g as a new special gap |
| `get_frobchildren(S)` | Children with same Frobenius number |

## Project Structure

```
numerical-semigroup-lab/
├── src/
│   ├── NumericalSemigroupLab.jl        # Main module
│   ├── core/                            # Core types and implementations
│   │   ├── types.jl                     # Type definitions
│   │   ├── numerical_set.jl             # NumericalSet implementation
│   │   ├── numerical_semigroup.jl       # NumericalSemigroup type
│   │   ├── semigroup_constructors.jl    # Factory functions
│   │   └── partition.jl                 # Partition implementation
│   ├── algorithms/                      # Algorithm implementations
│   │   ├── gaps.jl                      # Gap computation from generators
│   │   ├── apery.jl                     # Apéry set algorithms
│   │   ├── minimalgenerators.jl         # Minimal generator algorithms
│   │   └── partition_algorithms.jl      # Partition algorithms
│   ├── advanced/                        # Advanced features
│   │   ├── poset.jl
│   │   ├── weights.jl
│   │   ├── tree_navigation.jl
│   │   └── special_gaps.jl
│   └── utils/                           # Utilities
│       ├── helpers.jl
│       ├── cache.jl
│       └── validation.jl
├── test/                                # Test suite (295 tests)
│   ├── runtests.jl
│   ├── test_core.jl                     # Core data structure tests
│   ├── test_semigroups.jl               # Numerical semigroup tests
│   └── test_advanced.jl                 # Advanced features tests
├── docs/                                # Documentation
└── Project.toml                         # Package manifest
```

## Performance

Benchmarks show significant speedups over Python:

| Operation | Python (pocketpartition) | Julia (this package) | Speedup |
|-----------|-------------------------|---------------------|---------|
| Minimal generators (genus 50) | ~10ms | ~0.5ms | **20x** |
| Apéry set (n=10, genus 100) | ~5ms | ~0.2ms | **25x** |
| Partition hooks (size 100) | ~2ms | ~0.05ms | **40x** |
| Partition/NumericalSet ops | ~1ms | ~1μs | **1000x** |

## Documentation

Full documentation is available via Documenter.jl:

```julia
# Build documentation locally
cd docs
julia --project=. make.jl

# Open docs/build/index.html in browser
```

## Python Interoperability

This package can be called from Python via `juliacall`:

```python
from juliacall import Main as jl

# Load Julia package
jl.seval("using NumericalSemigroupLab")

# Use Julia functions from Python
S = jl.NumericalSemigroup([3, 5, 7])
print(f"Genus: {jl.genus(S)}")
print(f"Frobenius: {jl.frobenius_number(S)}")
print(f"Generators: {list(jl.generators(S))}")
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass (`Pkg.test()`)
5. Submit a pull request

## Testing

```julia
using Pkg
Pkg.test("NumericalSemigroupLab")
```

Current test coverage: **295 tests passing**

## References

This package builds upon the excellent work of the numerical semigroup research community:

### Software Inspirations
- [pocketpartition](https://github.com/blackgauss/pocketpartition) - Original Python implementation by the author
- [GAP numericalsgps](https://github.com/gap-packages/numericalsgps) - The definitive GAP package for numerical semigroups, by M. Delgado, P.A. García-Sánchez, and J. Morais
- [SageMath](https://github.com/sagemath/sage) - Numerical semigroup functionality in SageMath

### Mathematical Background
- Rosales, J.C. and García-Sánchez, P.A. (2009). *Numerical Semigroups*. Springer.
- Assi, A., García-Sánchez, P.A., and Ojeda, I. (2020). *Numerical Semigroups and Applications*. RSME Springer Series.

### Acknowledgments
Special thanks to the Julia community for creating an exceptional language for scientific computing, and to the developers of the packages this project depends on: DataStructures.jl, Memoize.jl, and Documenter.jl.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Citation

If you use this package in your research, please cite:

```bibtex
@software{numerical_semigroup_lab,
  author = {Imathiu-Jones, Erik},
  title = {NumericalSemigroupLab.jl: High-Performance Numerical Semigroup Computations},
  year = {2026},
  url = {https://github.com/blackgauss/numerical-semigroup-lab}
}
```

## Contact

- GitHub: [@blackgauss](https://github.com/blackgauss)
- Issues: [https://github.com/blackgauss/numerical-semigroup-lab/issues](https://github.com/blackgauss/numerical-semigroup-lab/issues)
