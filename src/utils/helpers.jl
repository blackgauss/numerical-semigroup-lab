"""
Helper utility functions used throughout the package.

These are low-level functions that don't depend on the main types.
Optimized for performance with minimal allocations.
"""

"""
    flatten(nested_vec::AbstractVector{<:AbstractVector{T}}) where T

Flatten a vector of vectors into a single vector.

# Examples
```julia
flatten([[1, 2], [3, 4, 5]])  # [1, 2, 3, 4, 5]
```
"""
function flatten(nested_vec::AbstractVector{<:AbstractVector{T}}) where T
    result = T[]
    for subvec in nested_vec
        append!(result, subvec)
    end
    return result
end

"""
    remove_sum_of_two_elements(A::AbstractSet{Int})

Remove elements from set A that are sums of two other elements in A.

This is used in computing minimal generating sets.

# Examples
```julia
remove_sum_of_two_elements(Set([2, 3, 4, 5, 6]))  # Set([2, 3])
# Because 4=2+2, 5=2+3, 6=2+4=3+3
```

# Performance
- Time complexity: O(n²) where n = length(A)
- Optimized to avoid unnecessary checks
"""
function remove_sum_of_two_elements(A::AbstractSet{Int})
    to_remove = Set{Int}()
    
    # Find all elements that are sums
    for x in A
        for y in A
            sum_xy = x + y
            if sum_xy in A
                push!(to_remove, sum_xy)
            end
        end
    end
    
    # Return set difference
    return setdiff(A, to_remove)
end

"""
    compute_conjugate_partition(parts::Vector{Int})

Compute the conjugate (transpose) of a partition.

The conjugate partition is obtained by transposing the Ferrers diagram.

# Examples
```julia
compute_conjugate_partition([4, 3, 1])  # [3, 2, 2, 1]
```

# Performance
- Time complexity: O(n + m) where n = length, m = maximum
- Uses efficient counting algorithm
"""
function compute_conjugate_partition(parts::Vector{Int})
    isempty(parts) && return Int[]
    
    max_part = maximum(parts)
    conjugate = zeros(Int, max_part)
    
    @inbounds for i in 1:max_part
        for part in parts
            if part >= i
                conjugate[i] += 1
            end
        end
    end
    
    return conjugate
end

"""
    compute_hook_lengths_matrix(parts::Vector{Int}, conjugate::Vector{Int})

Compute the hook lengths for each cell in a partition.

Hook length h(i,j) = parts[i] - j + conjugate[j] - i + 1

# Returns
Matrix{Int} where result[i][j] is the hook length at position (i,j)

# Performance
- Time complexity: O(n²) where n = sum(parts)
- Returns a vector of vectors for irregular shape
"""
function compute_hook_lengths_matrix(parts::Vector{Int}, conjugate::Vector{Int})
    n_rows = length(parts)
    result = Vector{Vector{Int}}(undef, n_rows)
    
    @inbounds for i in 1:n_rows
        row_length = parts[i]
        row_hooks = Vector{Int}(undef, row_length)
        
        for j in 1:row_length
            row_hooks[j] = parts[i] - j + conjugate[j] - i + 1
        end
        
        result[i] = row_hooks
    end
    
    return result
end

"""
    boxes_above(gaps::BitSet, s::Int)

Count how many gaps are strictly greater than s.

Used in weight computations.

# Performance
- Time complexity: O(g) where g = number of gaps
- Could be optimized with sorted gap vector
"""
@inline function boxes_above(gaps::BitSet, s::Int)
    count = 0
    for gap in gaps
        if gap > s
            count += 1
        end
    end
    return count
end

"""
    is_sorted_descending(vec::AbstractVector)

Check if vector is sorted in descending (non-increasing) order.

# Examples
```julia
is_sorted_descending([5, 4, 3, 1])  # true
is_sorted_descending([5, 4, 6, 1])  # false
```
"""
function is_sorted_descending(vec::AbstractVector)
    for i in 1:(length(vec)-1)
        if vec[i] < vec[i+1]
            return false
        end
    end
    return true
end

"""
    ensure_sorted_descending!(vec::Vector)

Sort vector in descending order in-place if not already sorted.

# Returns
The sorted vector (same object)
"""
function ensure_sorted_descending!(vec::Vector)
    if !is_sorted_descending(vec)
        sort!(vec, rev=true)
    end
    return vec
end

