function readHmetisBenchmark(fname::String)
    i = 0
    j = 0
    thr = 3
    hE = 0
    n = 0
    l = 1
    eptr = Int[]
    hedges = Int[]
    vwts = Int[]
    f = open(fname)

    for ln in eachline(f)
        i += 1

        if i > 1 && i <= thr
            matchline = match(r"([0-9\s]+)", ln)

            if matchline != nothing
                hdge = [parse(Int, vtxstr) for vtxstr in split(matchline.captures[1])]
                append!(hedges, hdge)
                l += length(hdge)
                eptr[i] = l
            end

        elseif i > thr
            j += 1
            vwts[j] = parse(Int, ln)
        else
            #match_first_line = match(r"(\d+)\s+(\d+)\s+(\d+)", ln)
            match_first_line = match(r"(\d+)\s+(\d+)", ln)
            hE = parse(Int, match_first_line.captures[1])
            n = parse(Int, match_first_line.captures[2])
            resize!(eptr, hE + 1)
            resize!(vwts, n)
            eptr[1] = 1
            thr = hE+1
        end
    end

    close(f)

    return (hedges, eptr, vwts, n, hE, length(hedges))
end