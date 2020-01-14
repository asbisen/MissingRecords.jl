module MissingRecords

using DataFrames
using VegaLite

export Bar,
       Heatmap,
       DataFrame,
       plot

include("bar.jl")
include("heatmap.jl")

# struct Bar
#     colnames::Vector
#     missing_num::Vector
#     missing_pct::Vector
#     numrows::Int
# end
#
# function Bar(df::DataFrame)
#     colnames = names(df)
#     numrows = nrow(df)
#     missing_num = [sum(ismissing.(df[!,i])) for i in colnames]
#     missing_pct = round.( (missing_num ./ numrows) .* 100, digits=2)
#     Bar(colnames, missing_num, missing_pct, numrows)
# end
#
#
# function DataFrame(mb::Bar)
#     DataFrame( colnames = mb.colnames,
#                missing_num = mb.missing_num,
#                missing_pct = mb.missing_pct,
#                numrows=[mb.numrows for i in 1:length(mb.colnames)]
#                )
# end
#
# Base.convert(::Type{DataFrame}, mb::Bar) = DataFrame(mb)
# Base.show(io::IO, mime::MIME"text/plain", mb::Bar) = display(sort!(DataFrame(mb), :missing_num, rev=true))
#
# """
#     plot( mb[, width, height, fontSize, filterpct, printvals, title])
#
# Plot barchart using VegaLite showing percentage of missing values in each of
# the columns of a DataFrame parsed by `MissingBar`
#
# # Arguments
# - `mb`: MissingBar
# - `width::Integer=1000`: Width of the plot
# - `height::Integer=200`: Height of the plot
# - `fontSize::Integer=10`: Font size used to plot values (`printvals==true`)
# - `filterpct::Float=0`: Filter out columns with missing values < `filterpct`
# - `printvals::Bool=false`: Print individual values for each bar
# - `title::String`: Default title of the plot
# """
# function plot( mb::Bar;
#                width=1000, height=200,
#                fontSize=10,
#                filterpct=0,
#                printvals=false,
#                title="Missing Data"
#     )
#
#     df = DataFrame(mb)
#
#     df = filter(x -> x[:missing_pct] >= filterpct, df) # filter rows with missing < filterpct
#     # TODO: handle if the above line filters all columns
#
#     plt = df |>
#       @vlplot(
#               x={"colnames:o", axis={title="Column Names"}},
#               y={"missing_pct:q", axis={title="Pct. Missing"}, scale={domain=[0, 101]}},
#               tooltip=[
#                        {field="colnames", type="ordinal"},
#                        {field="missing_num", type="quantitative"},
#                        {field="missing_pct", type="quantitative"}
#                       ],
#               width=width, height=height,
#               title=title) +
#       @vlplot(:bar)
#
#     # only print values over bars if `printvals==true`
#     if printvals==true
#       plt = plt +
#             @vlplot( mark={:text, align=:center, baseline=:bottom, dy=-2, fontSize=fontSize, dx=0, angle=0},
#                      text="missing_pct:o",
#                      color={value="black"}
#                    )
#     end
#
#     plt
# end
#
#
#
# struct Heatmap
#     colnames::Vector
#     missing_num::Vector
#     missing_pct::Vector
#     numrows::Int
#     data::Dict
# end
#
#
# function Heatmap(df::DataFrame; nbins=256)
#     colnames = names(df)
#     numrows = nrow(df)
#
#     missing_num = [sum(ismissing.(df[!,i])) for i in colnames]
#     missing_pct = round.( (missing_num ./ numrows) .* 100, digits=2)
#
#     # Create a bitmap of missing data
#     bitmap = Dict()
#     for n in colnames
#         bitmap[n] = ismissing.(df[!, n])
#     end
#
#     # calculate partition size to get bins = `nbins`
#     # TODO: handle situation where nbins > nrows
#     partition_size = round(Int, numrows/nbins)
#     data = Dict()
#     for k in keys(bitmap)
#         p = Iterators.partition(bitmap[k], partition_size)
#         data[k] = [sum(i)/length(i) for i in p] # calculate percent missing
#     end
#
#     Heatmap(colnames, missing_num, missing_pct, numrows, data)
# end
#
#
# function plot( mb::Heatmap;
#                width=1000, height=200,
#                filterpct=0,
#                title="Missing Data"
#     )
#
#     df = DataFrame( mb.data )
#     # create a new column with increasing numbers
#     #df[!, :row] = 1:nrow(df)
#
#     # filter based on `filterpct`
#     cols = []
#     for (i,j) in zip(mb.colnames, mb.missing_pct)
#         if j >= filterpct
#             push!(cols, i)
#         end
#     end
#     ndf = df[!, cols]
#     ndf[!, :row] = 1:nrow(df)
#
#     sdf = stack(ndf, cols)
#     p = sdf |> @vlplot(:rect,
#                 x="variable:n",
#                 y="row:o",
#                 color={"value:q", scale ={scheme="greys"}},
#                 height=height,
#                 width=width,
#                 title=title
#                 )
#     return p
# end

end # module
