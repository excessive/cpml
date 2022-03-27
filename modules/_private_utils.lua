-- Functions exported by utils.lua but needed by vec2 or vec3 (which utils.lua requires)

local private = {}
local floor   = math.floor
local ceil    = math.ceil

function private.round(value, precision)
	if precision then return private.round(value / precision) * precision end
	return value >= 0 and floor(value+0.5) or ceil(value-0.5)
end

function private.is_nan(a)
	return a ~= a
end

return private
