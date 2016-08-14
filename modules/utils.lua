--- Various utility functions
-- @module utils

local modules = (...): gsub('%.[^%.]+$', '') .. "."
local vec2    = require(modules .. "vec2")
local vec3    = require(modules .. "vec3")
local atan2   = math.atan2
local acos    = math.acos
local sqrt    = math.sqrt
local abs     = math.abs
local ceil    = math.ceil
local floor   = math.floor
local log     = math.log
local utils   = {}

-- reimplementation of math.frexp, due to its removal from Lua 5.3 :(
-- courtesy of airstruck
local log2 = log(2)

local frexp = math.frexp or function(x)
	if x == 0 then return 0, 0 end
	local e = floor(log(abs(x)) / log2 + 1)
	return x / 2 ^ e, e
end

--- Clamps a value within the specified range.
-- @param value Input value
-- @param min Minimum output value
-- @param max Maximum output value
-- @return number
function utils.clamp(value, min, max)
	return math.max(math.min(value, max), min)
end

--- Returns `value` if it is equal or greater than |`size`|, or 0.
-- @param value
-- @param size
-- @return number
function utils.deadzone(value, size)
	return abs(value) >= size and value or 0
end

--- Check if value is equal or greater than threshold.
-- @param value
-- @param threshold
-- @return boolean
function utils.threshold(value, threshold)
	-- I know, it barely saves any typing at all.
	return abs(value) >= threshold
end

--- Check if value is equal or less than threshold.
-- @param value
-- @param threshold
-- @return boolean
function utils.tolerance(value, threshold)
	-- I know, it barely saves any typing at all.
	return abs(value) <= threshold
end

--- Scales a value from one range to another.
-- @param value Input value
-- @param min_in Minimum input value
-- @param max_in Maximum input value
-- @param min_out Minimum output value
-- @param max_out Maximum output value
-- @return number
function utils.map(value, min_in, max_in, min_out, max_out)
	return ((value) - (min_in)) * ((max_out) - (min_out)) / ((max_in) - (min_in)) + (min_out)
end

--- Linear interpolation.
-- Performs linear interpolation between 0 and 1 when `low` < `progress` < `high`.
-- @param progress (0-1)
-- @param low value to return when `progress` is 0
-- @param high value to return when `progress` is 1
-- @return number
function utils.lerp(progress, low, high)
	return progress * (high - low) + low
end

--- Hermite interpolation.
-- Performs smooth Hermite interpolation between 0 and 1 when `low` < `progress` < `high`.
-- @param progress (0-1)
-- @param low value to return when `progress` is 0
-- @param high value to return when `progress` is 1
-- @return number
function utils.smoothstep(progress, low, high)
	local t = utils.clamp((progress - low) / (high - low), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
end

--- Round number at a given precision.
-- Truncates `value` at `precision` points after the decimal (whole number if
-- left unspecified).
-- @param value
-- @param precision
-- @return number
function utils.round(value, precision)
	if precision then return utils.round(value / precision) * precision end
	return value >= 0 and floor(value+0.5) or ceil(value-0.5)
end

--- Wrap `value` around if it exceeds `limit`.
-- @param value
-- @param limit
-- @return number
function utils.wrap(value, limit)
	if value < 0 then
		value = value + utils.round(((-value/limit)+1))*limit
	end
	return value % limit
end

--- Check if a value is a power-of-two.
-- Returns true if a number is a valid power-of-two, otherwise false.
-- @author undef
-- @param value
-- @return boolean
function utils.is_pot(value)
	-- found here: https://love2d.org/forums/viewtopic.php?p=182219#p182219
	-- check if a number is a power-of-two
	return (frexp(value)) == 0.5
end

-- Originally from vec3
function utils.project_on(out, a, b)
	local isvec3 = vec3.is_vec3(out)
	local s =
		(a.x * b.x + a.y * b.y + isvec3 and a.z * b.z or 0) /
		(b.x * b.x + b.y * b.y + isvec3 and b.z * b.z or 0)

	out.x = b.x * s
	out.y = b.y * s
	out.z = isvec3 and b.z * s or nil

	return out
end

-- Originally from vec3
function utils.project_from(out, a, b)
	local isvec3 = vec3.is_vec3(out)
	local s =
		(b.x * b.x + b.y * b.y + isvec3 and b.z * b.z or 0) /
		(a.x * b.x + a.y * b.y + isvec3 and a.z * b.z or 0)

	out.x = b.x * s
	out.y = b.y * s
	out.z = isvec3 and b.z * s or nil

	return out
end

-- Originally from vec3
function utils.mirror_on(out, a, b)
	local isvec3 = vec3.is_vec3(out)
	local s =
		(a.x * b.x + a.y * b.y + isvec3 and a.z * b.z or 0) /
		(b.x * b.x + b.y * b.y + isvec3 and b.z * b.z or 0) * 2

	out.x = b.x * s - a.x
	out.y = b.y * s - a.y
	out.z = isvec3 and b.z * s - a.z or nil

	return out
end

-- Originally from vec3
function utils.reflect(out, i, n)
	return out
		:mul(n, n:dot(i) * 2)
		:sub(i, out)
end

-- Originally from vec3
local tmp = vec3()
function utils.refract(out, i, n, ior)
	local d = n:dot(i)
	local k = 1 - ior * ior * (1 - d * d)

	if k >= 0 then
		tmp:mul(n, ior * d + sqrt(k))
		out:mul(i, ior)
		out:sub(out, tmp)
	end

	return out
end

return utils
