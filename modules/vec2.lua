local sqrt= math.sqrt
local ffi = require "ffi"

ffi.cdef[[
typedef struct {
	double x, y;
} cpml_vec2;
]]

local vec2 = {}
local cpml_vec2 = ffi.typeof("cpml_vec2")
vec2.new = cpml_vec2

function vec2.clone(a)
	ffi.copy(vec2.new(), a, ffi.sizeof(out))
end

function vec2.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
end

function vec2.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
end

function vec2.mul(out, a, b)
	out.x = a.x * b
	out.y = a.y * b
end

function vec2.div(out, a, b)
	out.x = a.x / b
	out.y = a.y / b
end

function vec2.cross(a, b)
	return a.x * b.y - a.y * b.x
end

function vec2.dot(a, b)
	return a.x * b.x + a.y * b.y
end

function vec2.normalize(out, a)
	local l = vec2.len(a)
	out.x = a.x / l
	out.y = a.y / l
end

function vec2.len(a)
	return sqrt(a.x * a.x + a.y * a.y)
end

function vec2.len2(a)
	return a.x * a.x + a.y * a.y
end

function vec2.dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return sqrt(dx * dx + dy * dy)
end

function vec2.dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return dx * dx + dy * dy
end

function vec2.lerp(a, b, s)
	return a + s * (b - a)
end

function vec2.unpack(a)
	return a.x, a.y
end

function vec2.tostring(a)
	return string.format("(%+0.3f,%+0.3f)", a.x, a.y)
end

local vec2_mt = {}

vec2_mt.__index = vec2
vec2_mt.__call = vec2.new
vec2_mt.__tostring = vec2.tostring

function vec2_mt.__unm(a)
	return vec2.new(-a.x, -a.y)
end

function vec2_mt.__eq(a,b)
	return a.x == b.x and a.y == b.y
end

function vec2_mt.__add(a, b)
	local temp = vec2.new()
	vec2.add(temp, a, b)
	return temp
end

function vec2_mt.__mul(a, b)
	local temp = vec2.new()
	vec2.mul(temp, a, b)
	return temp
end

function vec2_mt.__div(a, b)
	local temp = vec2.new()
	vec2.div(temp, a, b)
	return temp
end

ffi.metatype(cpml_vec2, vec2_mt)
return setmetatable({}, vec2_mt)
