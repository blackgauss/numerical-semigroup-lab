# NumericalSemigroupLab.jl

A high-performance Julia package for computing with numerical semigroups, numerical sets, and integer partitions.

[![Build Status](https://github.com/blackgauss/numerical-semigroup-lab/workflows/CI/badge.svg)](https://github.com/blackgauss/numerical-semigroup-lab/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/blackgauss/numerical-semigroup-lab")
```

## Quick Start

```julia
using NumericalSemigroupLab

# Create a numerical semigroup from generators
S = NumericalSemigroup([3, 5])

# Core invariants
genus(S)              # 4 - number of gaps
frobenius_number(S)   # 7 - largest gap
multiplicity(S)       # 3 - smallest positive element
generators(S)         # [3, 5] - minimal generating set

# Membership and elements
8 in S                # true (8 = 3 + 5)
elements_up_to(S, 10) # [0, 3, 5, 6, 8, 9, 10]

# Apery set and Kunz coordinates
apery_set(S)          # [0, 10, 5]
kunz_coordinates(S)   # [3, 1]

# Type and symmetry
void(S)               # [7] - pseudo-Frobenius numbers
type_semigroup(S)     # 1
is_symmetric(S)       # true

# Tree navigation
get_parent(S)         # Parent in genus tree
get_children(S)       # Children in genus tree

# Create from gaps
T = semigroup_from_gaps([1, 2, 4, 7])
S == T                # true
```

## Documentation

Full API reference and examples: **[Documentation](https://blackgauss.github.io/numerical-semigroup-lab/)**

## Features

- **Numerical Semigroups**: Constructors, Apery sets, minimal generators, Kunz coordinates
- **Tree Navigation**: Parent/children in genus tree, ancestors, descendants  
- **Type & Symmetry**: Pseudo-Frobenius numbers, symmetric/pseudo-symmetric detection
- **Partitions**: Conjugate, hook lengths, profile, bijection to numerical sets
- **Posets**: Gap posets, void posets, cover relations

## References

- Rosales, J.C. and García-Sánchez, P.A. (2009). *Numerical Semigroups*. Springer.
- [GAP numericalsgps](https://github.com/gap-packages/numericalsgps) - The definitive GAP package
- [pocketpartition](https://github.com/blackgauss/pocketpartition) - Original Python implementation

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Erik Imathiu-Jones** ([@blackgauss](https://github.com/blackgauss))
