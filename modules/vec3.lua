local sqrt= math.sqrt
local ffi = require "ffi"

ffi.cdef[[
typedef struct {
	double x, y, z;
} cpml_vec3;
]]

local vec3 = {}
local cpml_vec3 = ffi.typeof("cpml_vec3")
vec3.new = cpml_vec3

function vec3.clone(a)
	ffi.copy(vec3.new(), a, ffi.sizeof(out))
end

function vec3.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	out.z = a.z + b.z
end

function vec3.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	out.z = a.z - b.z
end

function vec3.mul(out, a, b)
	out.x = a.x * b
	out.y = a.y * b
	out.z = a.z * b
end

function vec3.div(out, a, b)
	out.x = a.x / b
	out.y = a.y / b
	out.z = a.z / b
end

function vec3.cross(out, a, b)
	out.x = a.y * b.z - a.z * b.y
	out.y = a.z * b.x - a.x * b.z
	out.z = a.x * b.y - a.y * b.x
end

function vec3.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

function vec3.normalize(out, a)
	local l = vec3.len(a)
	out.x = a.x / l
	out.y = a.y / l
	out.z = a.z / l
end

function vec3.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function vec3.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z
end

function vec3.dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt(dx * dx + dy * dy + dz * dz)
end

function vec3.dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return dx * dx + dy * dy + dz * dz
end

function vec3.lerp(a, b, s)
	return a + s * (b - a)
end

function vec3.unpack(a)
	return a.x, a.y, a.z
end

function vec3.tostring(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z)
end

local vec3_mt = {}

vec3_mt.__index = vec3
vec3_mt.__call = vec3.new
vec3_mt.__tostring = vec3.tostring

function vec3_mt.__unm(a)
	return vec3.new(-a.x, -a.y, -a.z)
end

function vec3_mt.__eq(a,b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

function vec3_mt.__add(a, b)
	local temp = vec3.new()
	vec3.add(temp, a, b)
	return temp
end

function vec3_mt.__mul(a, b)
	local temp = vec3.new()
	vec3.mul(temp, a, b)
	return temp
end

function vec3_mt.__div(a, b)
	local temp = vec3.new()
	vec3.div(temp, a, b)
	return temp
end

ffi.metatype(cpml_vec3, vec3_mt)
return setmetatable({}, vec3_mt)
