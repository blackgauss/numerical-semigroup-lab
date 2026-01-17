# Developer Guide

Information for contributors and developers.

## Setting Up the Environment

```bash
git clone https://github.com/blackgauss/numerical-semigroup-lab.git
cd numerical-semigroup-lab
```

In Julia:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
Pkg.test()
```

### Project Structure

```
numerical-semigroup-lab/
├── src/
│   ├── NumericalSemigroupLab.jl    # Main module
│   ├── core/                        # Core types and operations
│   │   ├── types.jl                 # Type definitions
│   │   ├── numerical_set.jl         # NumericalSet implementation
│   │   ├── numerical_semigroup.jl   # NumericalSemigroup type
│   │   └── partition.jl             # Partition implementation
│   ├── algorithms/                  # Algorithm implementations
│   │   ├── gaps.jl                  # Gap computation
│   │   ├── apery.jl                 # Apery set algorithms
│   │   ├── minimalgenerators.jl     # Minimal generators
│   │   └── partition_algorithms.jl  # Partition algorithms
│   ├── advanced/                    # Advanced features
│   │   ├── poset.jl                 # Poset operations
│   │   ├── weights.jl               # Weight computations
│   │   ├── tree_navigation.jl       # Genus tree navigation
│   │   └── special_gaps.jl          # Special gaps and symmetry
│   └── utils/                       # Utilities
│       ├── helpers.jl               # Helper functions
│       ├── cache.jl                 # Caching infrastructure
│       └── validation.jl            # Input validation
├── test/
│   └── runtests.jl                  # Test suite
├── docs/
│   ├── make.jl                      # Documentation builder
│   └── src/                         # Documentation source
├── Project.toml                     # Package manifest
└── README.md
```

## Running Tests

```julia
using Pkg
Pkg.test("NumericalSemigroupLab")
```

Or from the command line:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

### Adding New Features

1. **Create a new branch**
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Write tests first** (TDD approach)
   - Add tests to `test/runtests.jl`
   - Run tests to see them fail

3. **Implement the feature**
   - Add implementation to appropriate file in `src/`
   - Export public functions in main module

4. **Document your code**
   - Add docstrings with examples
   - Update relevant documentation pages

5. **Verify everything works**
   ```julia
   Pkg.test()
   ```

### Code Style

Follow Julia standard style:

```julia
# Use descriptive names
function compute_hook_lengths(partition::Partition)
    # Implementation
end

# Type stability is crucial for performance
function frobenius_number(ns::NumericalSet)::Int
    return ns.frobenius_number
end

# Use docstrings
"""
    conjugate(p::Partition) -> Partition

Compute the conjugate partition by transposing the Ferrers diagram.

# Examples
```jldoctest
julia> p = Partition([5, 4, 3, 1])
julia> conjugate(p).parts
[4, 3, 3, 2, 1]
```
"""
function conjugate(p::Partition)
    # Implementation
end
```

## Architecture Overview

### Core Data Structures

**Components:**
- `NumericalSet` type with gaps and Frobenius number
- `NumericalSemigroup` extending NumericalSet with generators
- `Partition` type with parts
- `Poset` type for partial orders
- Bijection between numerical sets and partitions
- Hook lengths, conjugation, profile
- Caching infrastructure

### Algorithms

**Gap Computation:**
- General algorithm for n generators
- Optimized 2-generator algorithm using Sylvester-Frobenius

**Apery Sets:**
- Fast Apery set computation with caching
- Apery set with respect to any element

**Minimal Generators:**
- Find minimal generators from gaps or semigroup
- Verify minimality

### Advanced Features

**Posets:**
- Poset type with elements and relations
- Cover relations for Hasse diagrams
- Gap posets and void posets

**Weights:**
- Effective weight computation
- Apery weight and Kunz coordinates
- Depth and delta set

**Tree Navigation:**
- Parent/children in genus tree
- Effective generators
- Ancestors and descendants

**Special Gaps:**
- Pseudo-Frobenius numbers
- Symmetry detection
- Frobenius children

## Performance Guidelines

### Type Stability

```julia
# ✓ Good: Type-stable
function good_function(x::Int)::Int
    return x + 1
end

# ✗ Bad: Type-unstable
function bad_function(x)
    if x > 0
        return x + 1      # Int
    else
        return "negative" # String
    end
end
```

### Memory Allocation

```julia
# ✓ Good: Pre-allocate
function compute_efficiently(n::Int)
    result = Vector{Int}(undef, n)
    for i in 1:n
        result[i] = i^2
    end
    return result
end

# ✗ Bad: Growing array
function compute_inefficiently(n::Int)
    result = Int[]
    for i in 1:n
        push!(result, i^2)  # Reallocates
    end
    return result
end
```

### Caching Strategy

```julia
# Use global Dict-based caches
const MY_CACHE = Dict{KeyType, ValueType}()

function cached_operation(key)
    if haskey(MY_CACHE, key)
        return MY_CACHE[key]
    end
    
    result = expensive_computation(key)
    MY_CACHE[key] = result
    return result
end
```

## Testing Guidelines

### Write Comprehensive Tests

```julia
using Test

@testset "NumericalSet" begin
    # Basic construction
    @testset "Construction" begin
        ns = NumericalSet([1, 2, 4])
        @test frobenius_number(ns) == 4
        @test 1 in gaps(ns)
        @test !(3 in gaps(ns))
    end
    
    # Edge cases
    @testset "Edge Cases" begin
        # Empty gaps
        ns_empty = NumericalSet(Int[])
        @test frobenius_number(ns_empty) == -1
        
        # Single gap
        ns_single = NumericalSet([1])
        @test frobenius_number(ns_single) == 1
    end
    
    # Properties
    @testset "Properties" begin
        ns = NumericalSet([1, 2, 4, 5])
        @test multiplicity(ns) == 3
        @test length(small_elements(ns)) > 0
    end
end
```

### Benchmark Critical Paths

```julia
using BenchmarkTools

function benchmark_suite()
    # Setup
    p = Partition([20, 19, 18, 17, 16])
    
    # Benchmark
    @benchmark hook_lengths($p)
    @benchmark conjugate($p)
end
```

## Documentation

### Writing Docstrings

```julia
"""
    function_name(arg1::Type1, arg2::Type2) -> ReturnType

Brief one-line description.

Longer description explaining what the function does, its algorithm,
and any important details.

# Arguments
- `arg1::Type1`: Description of first argument
- `arg2::Type2`: Description of second argument

# Returns
- `ReturnType`: Description of return value

# Examples
```jldoctest
julia> function_name(value1, value2)
expected_output
```

# Algorithm
Describe the algorithm and complexity.

# See Also
- [`related_function`](@ref)
"""
function function_name(arg1::Type1, arg2::Type2)::ReturnType
    # Implementation
end
```

### Building Documentation

```bash
julia --project=docs docs/make.jl
```

View locally:
```bash
cd docs/build
python3 -m http.server 8000
# Open http://localhost:8000
```

## Contributing

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run the test suite
5. Update documentation
6. Submit a pull request

### Code Review Checklist

- [ ] Tests pass
- [ ] Code is type-stable
- [ ] Performance is acceptable
- [ ] Documentation is complete
- [ ] Examples are provided
- [ ] Code follows style guidelines

## Contact

- **GitHub Issues**: https://github.com/blackgauss/numerical-semigroup-lab/issues
- **Discussions**: https://github.com/blackgauss/numerical-semigroup-lab/discussions

## Resources

### Julia Resources
- [Julia Documentation](https://docs.julialang.org/)
- [Julia Style Guide](https://docs.julialang.org/en/v1/manual/style-guide/)
- [Performance Tips](https://docs.julialang.org/en/v1/manual/performance-tips/)

### Mathematical Resources
- Rosales & García-Sánchez (2009). *Numerical Semigroups*
- Stanley (2011). *Enumerative Combinatorics*
- [OEIS](https://oeis.org/) - Integer sequences

### Related Packages
- [pocketpartition](https://github.com/blackgauss/pocketpartition) - Python original
- [numericalsgps](https://www.gap-system.org/Packages/numericalsgps.html) - GAP package
