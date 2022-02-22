function hypergraph2incidence(H::Hypergraph)
	n = H.n
	e = H.e

	hedges = H.hedges
	eptr = H.eptr

	d = zeros(Int, n)
	e_ = zeros(length(hedges))
	e_[eptr[1:end-1]] .= 1
	e_ = cumsum(e_)
	e_ = e_[1:end]

	prm = sortperm(hedges)
	v_ = hedges[prm]
	e_ = e_[prm]

	loc = zeros(Int, n+1)
	loc[2:end-1] = findall(v_[1:end-1] .!= v_[2:end]) .+ 1
	loc[1] = 1
	loc[end] = eptr[end]

	if H.weighted == true
		w_ = H.w_
		v_ = H.hedges
		for j in 1:e
			nodes = v_[eptr[j]:eptr[j+1]-1]
			d[nodes] .+= w_[j]
		end
	else
		d = loc[2:end] - loc[1:end-1]
	end

	return Incidence(n, e, e_, loc, d)
end	