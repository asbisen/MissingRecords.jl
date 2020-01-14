struct Heatmap
    colnames::Vector
    missing_num::Vector
    missing_pct::Vector
    numrows::Int
    data::Dict
end


function Heatmap(df::DataFrame; nbins=256)
    colnames = names(df)
    numrows = nrow(df)

    missing_num = [sum(ismissing.(df[!,i])) for i in colnames]
    missing_pct = round.( (missing_num ./ numrows) .* 100, digits=2)

    # Create a bitmap of missing data
    bitmap = Dict()
    for n in colnames
        bitmap[n] = ismissing.(df[!, n])
    end

    # calculate partition size to get bins = `nbins`
    # TODO: handle situation where nbins > nrows
    partition_size = round(Int, numrows/nbins)
    data = Dict()
    for k in keys(bitmap)
        p = Iterators.partition(bitmap[k], partition_size)
        data[k] = [sum(i)/length(i) for i in p] # calculate percent missing
    end

    Heatmap(colnames, missing_num, missing_pct, numrows, data)
end

"""
    plot( mb::Heatmap [, width, height, filterpct, title, color_scheme])

Plot barchart using VegaLite showing percentage of missing values in each of
the columns of a DataFrame parsed by `Heatmap`

# Arguments
- `mb`: MissingBar
- `width::Integer=1000`: Width of the plot
- `height::Integer=200`: Height of the plot
- `filterpct::Float=0`: Filter out columns with missing values < `filterpct`
- `title::String`: Default title of the plot
- `color_schemes::String=greys`: Use any vega sequential schemes

# Vega Color Schemes

https://vega.github.io/vega/docs/schemes/

## Single Hue Sequential
- blues, tealblues, teals, greens, browns, oranges, reds, purples, warmgreys, greys

## Multi-Hue Sequential
- viridis, magma, inferno, plasma, bluegreen, bluepurple, goldgreen, goldorange
- goldred, greenblue, orangered, purplebluegreen, purpleblue, purplered, redpurple
- yellowgreenblue, yellowgreen, yelloworangebrown, yelloworangered

## For Dark Background
- darkblue, darkgold, darkgreen, darkmulti, darkred

## For Light Background
- lightgreyred, lightgreyteal, lightmulti, lightorange, lighttealblue

## Diverging
- blueorange, brownbluegreen, purplegreen, pinkyellowgreen, purpleorange
- redblue, redgrey, redyellowblue, redyellowgreen, spectral

## Cyclical
- rainbow, sinebow

"""
function plot( mb::Heatmap;
               width=1000, height=200,
               filterpct=0,
               title="Heatmap Missing Data",
               color_scheme="greys"
    )

    df = DataFrame( mb.data )
    # create a new column with increasing numbers


    # filter based on `filterpct`
    cols = []
    for (i,j) in zip(mb.colnames, mb.missing_pct)
        if j >= filterpct
            push!(cols, i)
        end
    end

    ndf = df[!, cols]
    ndf[!, :row] = 1:nrow(df) # create column for y-axis

    sdf = stack(ndf, cols)
    p = sdf |> @vlplot(:rect,
                x={"variable:n", axis={title="Column Names"}},
                y={"row:o", axis={title="Bins"}},
                color={"value:q", scale ={scheme=color_scheme}},
                height=height,
                width=width,
                title=title
                )
    return p
end
