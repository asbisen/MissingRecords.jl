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


function plot( mb::Heatmap;
               width=1000, height=200,
               filterpct=0,
               title="Missing Data"
    )

    df = DataFrame( mb.data )
    # create a new column with increasing numbers
    #df[!, :row] = 1:nrow(df)

    # filter based on `filterpct`
    cols = []
    for (i,j) in zip(mb.colnames, mb.missing_pct)
        if j >= filterpct
            push!(cols, i)
        end
    end
    ndf = df[!, cols]
    ndf[!, :row] = 1:nrow(df)

    sdf = stack(ndf, cols)
    p = sdf |> @vlplot(:rect,
                x="variable:n",
                y="row:o",
                color={"value:q", scale ={scheme="greys"}},
                height=height,
                width=width,
                title=title
                )
    return p
end
