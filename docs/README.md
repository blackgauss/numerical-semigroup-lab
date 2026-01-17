# Documentation

This directory contains the documentation for NumericalSemigroupLab.jl.

## Viewing the Documentation

### Locally

After building, serve the documentation locally:

```bash
cd build
python3 -m http.server 8000
```

Then open http://localhost:8000 in your browser.

### Building

To build or rebuild the documentation:

```bash
julia --project=docs docs/make.jl
```

## Documentation Structure

- **`src/`**: Markdown source files
  - `index.md`: Home page
  - `getting-started.md`: Installation and first steps
  - `math-background.md`: Mathematical theory
  - `guide/`: User guides for different components
  - `examples/`: Working examples and tutorials
  - `api/`: Complete API reference
  - `dev-guide.md`: Developer and contributor guide

- **`build/`**: Generated HTML (gitignored)
  - Created by `Documenter.jl`
  - Should not be committed to git

- **`make.jl`**: Documenter.jl build script
- **`Project.toml`**: Documentation dependencies

## For Contributors

### Adding New Pages

1. Create a new `.md` file in `src/` or appropriate subdirectory
2. Add it to the `pages` array in `make.jl`
3. Rebuild documentation

### Adding Examples

Add code examples in triple backticks with `julia` language:

````markdown
```julia
using NumericalSemigroupLab

ns = NumericalSet([1, 2, 4, 5, 7])
frobenius_number(ns)  # 7
```
````

### Adding Math

Use LaTeX notation inline with `$` or in blocks with `$$`:

```markdown
The Frobenius number $g(S)$ satisfies:

$$g(S) = \max(\mathbb{N}_0 \setminus S)$$
```

### Cross-References

Link to other pages using `@ref`:

```markdown
See the [User Guide](@ref) for more details.
```

Link to functions:

```markdown
Use [`frobenius_number`](@ref) to get the largest gap.
```

## Current Status

Documentation is complete for all package functionality:
- Core types documented
- All functions with examples
- Mathematical background
- User guides and examples

## Troubleshooting

### Build Warnings

Some cross-reference warnings are expected and can be ignored. The documentation still builds successfully.

### Missing Dependencies

If you get errors about missing packages:

```bash
julia --project=docs -e 'using Pkg; Pkg.instantiate()'
```

### Doctests Failing

If code examples don't match output:

```bash
# Update doctests
julia --project=docs -e 'using Documenter, NumericalSemigroupLab; doctest(NumericalSemigroupLab)'
```

## Deployment

The documentation is configured for deployment to GitHub Pages. See `.github/workflows/` for CI/CD setup (to be added).
