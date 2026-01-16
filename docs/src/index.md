# NumericalSemigroupLab.jl

*A high-performance Julia package for computational algebra with numerical semigroups, numerical sets, and integer partitions.*

## Author

**Erik Imathiu-Jones** ([@blackgauss](https://github.com/blackgauss))

This package was developed with extensive use of [Claude](https://claude.ai) (Anthropic) as an AI programming assistant. While Claude assisted with code generation, documentation, and testing, all mathematical concepts, architectural decisions, and final implementations were carefully reviewed and directed by the author.

## What is this package?

NumericalSemigroupLab.jl provides efficient tools for working with:

- **Numerical Semigroups**: Additive submonoids of the non-negative integers
- **Numerical Sets**: Sets of non-negative integers with finitely many gaps
- **Integer Partitions**: Representations of integers as sums of positive integers
- **Partition-Semigroup Correspondence**: The bijection between numerical sets and integer partitions

This package is designed for researchers in combinatorics, algebraic geometry, coding theory, and related fields who need fast, reliable computations with these mathematical objects.

## Key Features

- **Performance-Oriented**: 10-100x faster than Python implementations  
- **Type-Safe**: Leverages Julia's powerful type system for correctness  
- **Comprehensive**: Full implementation of key algorithms from the literature  
- **Math-Friendly**: API designed for mathematical intuition  
- **Well-Tested**: Extensive test suite with 295 tests  
- **Well-Documented**: Clear documentation with mathematical explanations

## Quick Example

```julia
using NumericalSemigroupLab

# Create a numerical set from its gaps
ns = NumericalSet([1, 2, 4, 5, 7])

# Access fundamental properties
frobenius_number(ns)  # 7 (largest gap)
multiplicity(ns)      # 3 (smallest non-gap > 0)

# Convert to partition representation
p = Partition(partition(ns))  # [3, 3, 2, 2, 1, 1]

# Work with partitions
conjugate(p)          # Transpose of Ferrers diagram
hook_lengths(p)       # Hook lengths of all cells
```

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/blackgauss/numerical-semigroup-lab")
```

## Package Features

This package provides:

- **Core Data Structures**: Partition, NumericalSet with bijection
- **Numerical Semigroups**: Constructors from generators, Apery sets, minimal generators
- **Advanced Features**: Posets, weight computations, tree navigation, special gaps

**Test Coverage**: 295 tests passing

## Mathematical Background

### Numerical Semigroups

A **numerical semigroup** is a subset $S \subseteq \mathbb{N}_0$ that is:
1. Closed under addition: $a, b \in S \Rightarrow a + b \in S$
2. Contains zero: $0 \in S$
3. Has finite complement in $\mathbb{N}_0$ (finitely many gaps)

Key invariants:
- **Frobenius number** $g(S)$: The largest integer not in $S$
- **Genus** $g$: The number of gaps (elements not in $S$)
- **Multiplicity** $m$: The smallest positive integer in $S$

### Integer Partitions

An **integer partition** of $n$ is a way of writing $n$ as a sum of positive integers, where order doesn't matter. We represent partitions as non-increasing sequences.

Example: The partition $(5, 4, 3, 1)$ represents $13 = 5 + 4 + 3 + 1$

Key concepts:
- **Ferrers diagram**: Visual representation as rows of boxes
- **Conjugate partition**: Transpose of the Ferrers diagram
- **Hook length**: For each box, the number of boxes directly to the right, below, and including itself

### The Bijection

There is a remarkable bijection between:
- Numerical sets (sets with finitely many gaps)
- Integer partitions

This correspondence allows us to translate problems between these domains, using whichever representation makes the computation easier.

## Related Work

This package is a Julia port of [pocketpartition](https://github.com/blackgauss/pocketpartition), with significant performance improvements and extended functionality.

### Acknowledgments

This project builds upon the excellent work of the numerical semigroup research community:

- [GAP numericalsgps](https://github.com/gap-packages/numericalsgps) - The definitive GAP package for numerical semigroups, by M. Delgado, P.A. García-Sánchez, and J. Morais
- [SageMath](https://github.com/sagemath/sage) - Numerical semigroup functionality in SageMath
- The Julia community for creating an exceptional language for scientific computing

**Mathematical References**:
- Rosales, J.C. and García-Sánchez, P.A. (2009). *Numerical Semigroups*. Springer.
- Assi, A., García-Sánchez, P.A., and Ojeda, I. (2020). *Numerical Semigroups and Applications*. RSME Springer Series.

## Citation

If you use this package in your research, please cite:

```bibtex
@software{numericalsemigrouplab,
  title = {NumericalSemigroupLab.jl: High-Performance Computational Tools for Numerical Semigroups},
  author = {Imathiu-Jones, Erik},
  year = {2026},
  url = {https://github.com/blackgauss/numerical-semigroup-lab}
}
```

## Getting Help

- 📖 Read the [User Guide](@ref)
- 💻 Check the [Examples](@ref)
- 📚 Browse the [API Reference](@ref)
- 🐛 Report issues on [GitHub](https://github.com/blackgauss/numerical-semigroup-lab/issues)

## Contents

```@contents
Pages = [
    "getting-started.md",
    "math-background.md",
    "guide/partitions.md",
    "guide/numerical-sets.md",
]
Depth = 2
```
