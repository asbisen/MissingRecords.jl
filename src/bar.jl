struct Bar
    colnames::Vector
    missing_num::Vector
    missing_pct::Vector
    numrows::Int
end

function Bar(df::DataFrame)
    colnames = names(df)
    numrows = nrow(df)
    missing_num = [sum(ismissing.(df[!,i])) for i in colnames]
    missing_pct = round.( (missing_num ./ numrows) .* 100, digits=2)
    Bar(colnames, missing_num, missing_pct, numrows)
end


function DataFrame(mb::Bar)
    DataFrame( colnames = mb.colnames,
               missing_num = mb.missing_num,
               missing_pct = mb.missing_pct,
               numrows=[mb.numrows for i in 1:length(mb.colnames)]
               )
end

Base.convert(::Type{DataFrame}, mb::Bar) = DataFrame(mb)
Base.show(io::IO, mime::MIME"text/plain", mb::Bar) = display(sort!(DataFrame(mb), :missing_num, rev=true))

"""
    plot( mb::Bar [, width, height, fontSize, filterpct, printvals, title])

Plot barchart using VegaLite showing percentage of missing values in each of
the columns of a DataFrame parsed by `Bar`

# Arguments
- `mb`: Bar
- `width::Integer=1000`: Width of the plot
- `height::Integer=200`: Height of the plot
- `fontSize::Integer=10`: Font size used to plot values (`printvals==true`)
- `filterpct::Float=0`: Filter out columns with missing values < `filterpct`
- `printvals::Bool=false`: Print individual values for each bar
- `title::String`: Default title of the plot
"""
function plot( mb::Bar;
               width=1000, height=200,
               fontSize=10,
               filterpct=0,
               printvals=false,
               title="Missing Data"
    )

    df = DataFrame(mb)

    df = filter(x -> x[:missing_pct] >= filterpct, df) # filter rows with missing < filterpct
    # TODO: handle if the above line filters all columns

    plt = df |>
      @vlplot(
              x={"colnames:o", axis={title="Column Names"}},
              y={"missing_pct:q", axis={title="Pct. Missing"}, scale={domain=[0, 101]}},
              tooltip=[
                       {field="colnames", type="ordinal"},
                       {field="missing_num", type="quantitative"},
                       {field="missing_pct", type="quantitative"}
                      ],
              width=width, height=height,
              title=title) +
      @vlplot(:bar)

    # only print values over bars if `printvals==true`
    if printvals==true
      plt = plt +
            @vlplot( mark={:text, align=:center, baseline=:bottom, dy=-2, fontSize=fontSize, dx=0, angle=0},
                     text="missing_pct:o",
                     color={value="black"}
                   )
    end

    plt
end
