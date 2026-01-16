using Documenter
using NumericalSemigroupLab

makedocs(;
    modules=[NumericalSemigroupLab],
    authors="Erik Imathiu-Jones",
    repo="https://github.com/blackgauss/numerical-semigroup-lab/blob/{commit}{path}#{line}",
    sitename="NumericalSemigroupLab.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://blackgauss.github.io/numerical-semigroup-lab",
        edit_link="main",
        assets=String[],
        repolink="https://github.com/blackgauss/numerical-semigroup-lab",
    ),
    warnonly=true,  # Don't fail on warnings - allow build to complete
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "Mathematical Background" => "math-background.md",
        "User Guide" => [
            "Partitions" => "guide/partitions.md",
            "Numerical Sets" => "guide/numerical-sets.md",
            "Numerical Semigroups" => "guide/semigroups.md",
        ],
        "Examples" => [
            "Basic Usage" => "examples/basic.md",
            "Advanced Computations" => "examples/advanced.md",
        ],
        "API Reference" => [
            "Core Types" => "api/types.md",
            "Partition Operations" => "api/partitions.md",
            "Numerical Set Operations" => "api/numerical-sets.md",
            "Numerical Semigroup Operations" => "api/numerical-semigroups.md",
            "Advanced Features" => "api/advanced.md",
            "Utilities" => "api/utilities.md",
        ],
        "Developer Guide" => "dev-guide.md",
    ],
)

deploydocs(;
    repo="github.com/blackgauss/numerical-semigroup-lab",
    devbranch="main",
)
