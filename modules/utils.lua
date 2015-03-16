local utils = {}

function utils.clamp(v, min, max)
	return math.max(math.min(v, max), min)
end

function utils.map(v, min_in, max_in, min_out, max_out)
	return ((v) - (min_in)) * ((max_out) - (min_out)) / ((max_in) - (min_in)) + (min_out)
end

function utils.lerp(v, l, h)
	return v * (h - l) + l
end

function utils.round(v)
	return v >= 0 and math.floor(v+0.5) or math.ceil(v-0.5)
end

function utils.wrap(v, n)
	if v < 0 then
		v = v + utils.round(((-v/n)+1))*n
	end
	return v % n
end

return utils
