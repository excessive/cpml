local utils = {}

-- reimplementation of math.frexp, due to its removal from Lua 5.3 :(
-- courtesy of airstruck
local log2 = math.log(2)

local frexp = math.frexp or function(x)
    if x == 0 then return 0, 0 end
    local e = math.floor(math.log(math.abs(x)) / log2 + 1)
    return x / 2 ^ e, e
end

function utils.clamp(v, min, max)
	return math.max(math.min(v, max), min)
end

function utils.deadzone(value, size)
	return math.abs(value) >= size and value or 0
end

-- I know, it barely saves any typing at all.
function utils.threshold(value, threshold)
	return math.abs(value) >= threshold
end

function utils.map(v, min_in, max_in, min_out, max_out)
	return ((v) - (min_in)) * ((max_out) - (min_out)) / ((max_in) - (min_in)) + (min_out)
end

function utils.lerp(v, l, h)
	return v * (h - l) + l
end

function utils.smoothstep(v, l, h)
	local t = utils.clamp((v - l) / (h - l), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
end

function utils.round(v, precision)
	if precision then return utils.round(v / precision) * precision end
	return v >= 0 and math.floor(v+0.5) or math.ceil(v-0.5)
end

function utils.wrap(v, n)
	if v < 0 then
		v = v + utils.round(((-v/n)+1))*n
	end
	return v % n
end

-- from undef: https://love2d.org/forums/viewtopic.php?p=182219#p182219
-- check if a number is a power-of-two
function utils.is_pot(n)
  return 0.5 == (frexp(n))
end

return utils
