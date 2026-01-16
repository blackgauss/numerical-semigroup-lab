# Advanced Computations

This page shows advanced examples using NumericalSemigroupLab.jl.

## Advanced Partition Analysis

### Computing Partition Statistics

```julia
using NumericalSemigroupLab

function partition_statistics(p::Partition)
    hooks = hook_lengths(p)
    conj = conjugate(p)
    
    # Basic stats
    n = sum(p.parts)
    num_parts = length(p.parts)
    largest_part = p.parts[1]
    
    # Hook statistics
    all_hooks = vcat(hooks...)
    min_hook = minimum(all_hooks)
    max_hook = maximum(all_hooks)
    avg_hook = sum(all_hooks) / length(all_hooks)
    
    # Standard Young tableaux count
    syt_count = factorial(n) ÷ prod(all_hooks)
    
    return (
        size = n,
        parts = num_parts,
        largest = largest_part,
        conjugate_parts = length(conj.parts),
        min_hook = min_hook,
        max_hook = max_hook,
        avg_hook = avg_hook,
        syt_count = syt_count,
        is_self_conjugate = (p.parts == conj.parts)
    )
end

# Analyze several partitions
examples = [
    [5, 4, 3, 2, 1],
    [10, 10, 10],
    [15],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]

println("Partition Analysis:")
println("="^80)
for parts in examples
    p = Partition(parts)
    stats = partition_statistics(p)
    
    println("\nPartition: $parts")
    println("  Size: $(stats.size), Parts: $(stats.parts), Largest: $(stats.largest)")
    println("  Conjugate has $(stats.conjugate_parts) parts")
    println("  Hook lengths: min=$(stats.min_hook), max=$(stats.max_hook), avg=$(round(stats.avg_hook, digits=2))")
    println("  Standard Young tableaux: $(stats.syt_count)")
    println("  Self-conjugate: $(stats.is_self_conjugate)")
end
```

## Current: Numerical Set Patterns

### Studying Frobenius Numbers

```julia
# For two-generator semigroups, explore the Frobenius formula
function explore_frobenius_formula(max_val=20)
    results = []
    
    for a in 2:max_val
        for b in a+1:max_val
            if gcd(a, b) == 1
                # Compute actual gaps
                frob_formula = a * b - a - b
                gaps = Int[]
                
                for n in 1:frob_formula
                    can_make = false
                    for i in 0:n÷a
                        if (n - i*a) % b == 0
                            can_make = true
                            break
                        end
                    end
                    if !can_make
                        push!(gaps, n)
                    end
                end
                
                ns = NumericalSet(gaps)
                frob_computed = frobenius_number(ns)
                genus = length(gaps)
                genus_formula = (a-1)*(b-1)÷2
                
                push!(results, (
                    a = a, b = b,
                    frobenius = frob_computed,
                    genus = genus,
                    formula_correct = (frob_computed == frob_formula && genus == genus_formula)
                ))
            end
        end
    end
    
    return results
end

# Verify formulas
results = explore_frobenius_formula(10)
println("Two-Generator Formula Verification:")
println("="^70)

incorrect = filter(r -> !r.formula_correct, results)
if isempty(incorrect)
    println("✓ All $(length(results)) cases verified!")
    println("\nSample results:")
    for r in results[1:min(5, length(results))]
        println("  <$(r.a), $(r.b)>: Frobenius=$(r.frobenius), Genus=$(r.genus)")
    end
else
    println("✗ Found $(length(incorrect)) incorrect cases:")
    for r in incorrect
        println("  <$(r.a), $(r.b)>: MISMATCH")
    end
end
```

## Current: Bijection Deep Dive

### Exploring the Partition-Semigroup Correspondence

```julia
function detailed_bijection_trace(gaps_list)
    ns = NumericalSet(gaps_list)
    F = frobenius_number(ns)
    g = gaps(ns)
    
    println("Numerical Set Analysis:")
    println("  Gaps: ", sort(collect(g)))
    println("  Frobenius: $F")
    println("  Multiplicity: ", multiplicity(ns))
    println()
    
    # Trace the walk algorithm
    println("Walk Algorithm Trace:")
    println("  Starting at (0, $F), walking to ($F, 0)")
    
    partition_parts = Int[]
    current_height = F
    
    for x in 0:F-1
        if (x + 1) in g  # Next position is a gap
            println("  x=$x: $(x+1) is a gap → move down")
        else  # Next position is NOT a gap
            println("  x=$x: $(x+1) NOT a gap → move right, record height=$current_height")
            push!(partition_parts, current_height)
            current_height -= 1
        end
    end
    
    # Record final height
    if current_height > 0
        push!(partition_parts, current_height)
    end
    
    println("\nResulting partition: ", partition_parts)
    
    # Verify
    p = Partition(partition_parts)
    gaps_back = gaps(p)
    match = sort(gaps_back) == sort(collect(g))
    
    println("Round-trip verification: ", match ? "✓ PASS" : "✗ FAIL")
    if !match
        println("  Original: ", sort(collect(g)))
        println("  Got back: ", sort(gaps_back))
    end
    
    return partition_parts
end

# Trace several examples
examples = [
    [1, 2, 3],
    [1, 2, 4, 5],
    [1, 3, 5, 7, 9],
]

for (i, gaps) in enumerate(examples)
    println("\n" * "="^70)
    println("Example $i:")
    println("="^70)
    detailed_bijection_trace(gaps)
end
```

## Apery Set Computations

```julia
using NumericalSemigroupLab

S = NumericalSemigroup([7, 11, 13])
ap = apery_set(S, 7)

println("Apery set with respect to 7:")
println(sort(collect(ap)))
```

## Minimal Generating Sets

```julia
using NumericalSemigroupLab

# Create from gaps
S = semigroup_from_gaps([1, 2, 4, 5, 7, 8, 10, 11, 13])

# Find minimal generators
mingens = generators(S)
println("Minimal generators: ", mingens)

# Check embedding dimension
println("Embedding dimension: ", embedding_dimension(S))
```

## Genus Tree Navigation

```julia
using NumericalSemigroupLab

S = NumericalSemigroup([4, 6, 7])

# Navigate the genus tree
parent = get_parent(S)
println("Parent semigroup genus: ", genus(parent))

children = get_children(S)
println("Number of children: ", length(children))

# Get full ancestry
path = genus_path(S)
println("Path from N_0 to S: ", length(path), " steps")
```

## Weight Computations

```julia
using NumericalSemigroupLab

S = NumericalSemigroup([5, 7, 11])

# Compute effective weights
for g in gaps(S)
    ew = effective_weight(S, g)
    println("Effective weight of gap $g: $ew")
end

# Kunz coordinates
kc = kunz_coordinates(S)
println("Kunz coordinates: ", kc)

# Depth
d = depth(S)
println("Depth: ", d)
```

## Symmetry and Special Gaps

```julia
using NumericalSemigroupLab

# Symmetric semigroup
S1 = NumericalSemigroup([3, 5])
println("S1 = <3, 5>")
println("  Symmetric: ", is_symmetric(S1))
println("  Special gaps (PF numbers): ", special_gaps(S1))

# Non-symmetric semigroup
S2 = NumericalSemigroup([4, 6, 9])
println("\nS2 = <4, 6, 9>")
println("  Symmetric: ", is_symmetric(S2))
println("  Special gaps: ", special_gaps(S2))
println("  Type: ", length(special_gaps(S2)))
```

## Poset Operations

```julia
using NumericalSemigroupLab

S = NumericalSemigroup([3, 5, 7])

# Create the gap poset (divisibility order)
P = gap_poset(S)
println("Gap poset elements: ", P.elements)

# Cover relations (Hasse diagram)
covers = cover_relations(P)
println("Cover relations: ", covers)

# Maximal and minimal elements
println("Maximal elements: ", maximal_elements(P))
println("Minimal elements: ", minimal_elements(P))
```

## Performance: Large-Scale Computations

### Benchmark Suite

```julia
using BenchmarkTools

# Benchmark partition operations
function benchmark_partitions()
    sizes = [10, 20, 50, 100]
    
    println("Partition Benchmarks:")
    println("="^70)
    
    for n in sizes
        parts = collect(n:-1:1)  # Staircase partition
        p = Partition(parts)
        
        println("\nSize $n (staircase):")
        
        # Conjugate
        print("  Conjugate: ")
        clear_all_caches!()
        @btime conjugate($p)
        
        # Hook lengths
        print("  Hook lengths: ")
        clear_all_caches!()
        @btime hook_lengths($p)
        
        # Gaps
        print("  Gaps: ")
        @btime gaps($p)
    end
end

# Benchmark numerical set operations
function benchmark_numerical_sets()
    println("\n\nNumerical Set Benchmarks:")
    println("="^70)
    
    gap_counts = [10, 20, 50, 100]
    
    for g_count in gap_counts
        # Generate gaps
        gaps_list = [2i-1 for i in 1:g_count]  # Odd numbers
        ns = NumericalSet(gaps_list)
        
        println("\n$g_count gaps:")
        
        # Partition conversion
        print("  To partition: ")
        @btime partition($ns)
        
        # Multiplicity
        print("  Multiplicity: ")
        @btime multiplicity($ns)
        
        # Small elements
        print("  Small elements: ")
        @btime small_elements($ns)
    end
end

# Run benchmarks (requires BenchmarkTools.jl)
# benchmark_partitions()
# benchmark_numerical_sets()
```

## Next Steps

- Review [Basic Examples](@ref) for introductory usage
- Check [API Reference](@ref) for complete function documentation
- Read [Mathematical Background](@ref) for theoretical foundations
