"""
Partition implementation with conjugation, hook lengths, and gap/partition correspondence.

This file implements the Partition type and all its methods including:
- Conjugate partitions (transpose of Ferrers diagram)
- Hook lengths computation
- Profile and gaps (partition ↔ gaps bijection)
- Atom partition and semigroup detection
"""

# Property accessors
"""
    gaps(p::Partition) -> Vector{Int}

Compute the gaps corresponding to the partition using the lattice path bijection.

This is the inverse of the `partition(ns)` function. Given a partition,
reconstruct the gap set of the numerical set.

The bijection works as follows:
- Each part represents the x-coordinate (number of non-gaps seen) when a gap was encountered
- Parts sorted in ascending order give gaps in order of occurrence
- Gap position = part value + (number of gaps already placed)

# Examples
```julia
p = Partition([3, 1, 1])
gaps(p)  # [1, 2, 5] - the gaps of ⟨3, 4⟩
```
"""
function gaps(p::Partition)
    parts = p.parts
    isempty(parts) && return Int[]
    
    # Sort parts in ascending order to process gaps in order of occurrence
    parts_asc = sort(parts)
    
    gap_list = Int[]
    for (i, x) in enumerate(parts_asc)
        # Gap position = x-value + number of gaps already found
        gap_pos = x + (i - 1)
        push!(gap_list, gap_pos)
    end
    
    return gap_list
end

"""
    conjugate(p::Partition) -> Partition

Compute the conjugate (transpose) of a partition.

The conjugate is obtained by transposing the Ferrers diagram.

# Examples
```julia
p = Partition([4, 3, 1])
conj = conjugate(p)  # Partition([3, 2, 2, 1])
```

# Performance
Uses caching for previously computed conjugates.
"""
function conjugate(p::Partition)
    parts = p.parts
    
    # Check cache
    if haskey(CONJUGATE_CACHE, parts)
        return Partition(CONJUGATE_CACHE[parts])
    end
    
    # Compute conjugate
    conj_parts = compute_conjugate_partition(parts)
    
    # Cache result
    CONJUGATE_CACHE[parts] = conj_parts
    
    return Partition(conj_parts)
end

"""
    hook_lengths(p::Partition) -> Vector{Vector{Int}}

Compute the hook lengths for each cell in the partition.

Hook length h(i,j) = parts[i] - j + conjugate[j] - i + 1

Returns a vector of vectors representing the hook length at each cell.

# Examples
```julia
p = Partition([3, 2, 1])
hooks = hook_lengths(p)
# Returns [[5, 3, 1], [3, 1], [1]]
```

# Performance  
Uses caching for previously computed hook lengths.
"""
function hook_lengths(p::Partition)
    parts = p.parts
    
    # Check cache
    if haskey(HOOKS_CACHE, parts)
        return HOOKS_CACHE[parts]
    end
    
    # Compute conjugate first
    conj_parts = compute_conjugate_partition(parts)
    
    # Compute hook lengths
    hooks = compute_hook_lengths_matrix(parts, conj_parts)
    
    # Cache result
    HOOKS_CACHE[parts] = hooks
    
    return hooks
end

"""
    profile(p::Partition) -> Vector{Tuple{Int,Int}}

Compute the profile of the partition as a series of moves.

Returns a vector of (dx, dy) tuples where:
- (1, 0) represents a Right move
- (0, 1) represents an Up move

# Examples
```julia
p = Partition([3, 2, 1])
prof = profile(p)
# Returns sequence of (1,0) and (0,1) moves
```
"""
function profile(p::Partition)
    parts = p.parts
    isempty(parts) && return Tuple{Int,Int}[]
    
    moves = Tuple{Int,Int}[]
    n = length(parts)
    max_width = parts[1]
    
    # Start at bottom-left, move to top-right
    current_row = n
    current_col = 0
    
    while current_row >= 1 || current_col < max_width
        # Move right until end of current row
        while current_row >= 1 && current_col < parts[current_row]
            push!(moves, (1, 0))
            current_col += 1
        end
        
        # Move up until we find a row that extends to current column
        while current_row >= 1 && current_col >= parts[current_row]
            push!(moves, (0, 1))
            current_row -= 1
        end
    end
    
    return moves
end

"""
    atom_partition(p::Partition) -> Vector{Int}

Compute the atom partition of the given partition.

The atom partition is derived from the hook lengths and represents
the partition whose gaps are the hook set.

# Examples
```julia
p = Partition([5, 4, 3, 1])
atom = atom_partition(p)
```
"""
function atom_partition(p::Partition)
    hooks = hook_lengths(p)
    hookset = flatten(hooks)
    
    isempty(hookset) && return Int[]
    
    # Sort hooks
    sort!(hookset)
    max_hook = maximum(hookset)
    
    # Build partition from gaps
    partition = Int[]
    current_step = 0
    current_row = 0
    
    while current_step <= max_hook
        for i in current_step:max_hook
            if i in hookset
                push!(partition, current_row)
                current_step = i + 1
                break
            end
            current_row += 1
        end
    end
    
    # Sort in descending order
    sort!(partition, rev=true)
    
    return partition
end

"""
    atom_monoid_gaps(p::Partition) -> Vector{Int}

Return the gaps of the atom monoid (flattened hook lengths).

# Examples
```julia
p = Partition([3, 2, 1])
gaps = atom_monoid_gaps(p)
```
"""
function atom_monoid_gaps(p::Partition)
    hooks = hook_lengths(p)
    return flatten(hooks)
end

"""
    is_semigroup(p::Partition) -> Bool

Check if the partition is its own atom partition (i.e., if it represents a numerical semigroup).

# Examples
```julia
p = Partition([5, 4, 3, 1])
is_semigroup(p)  # Returns true or false
```
"""
function is_semigroup(p::Partition)
    return atom_partition(p) == p.parts
end
