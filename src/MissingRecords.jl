module MissingRecords

using DataFrames
using VegaLite

export Bar,
       Heatmap,
       DataFrame,
       plot

include("bar.jl")
include("heatmap.jl")


end # module
