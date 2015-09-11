
local assert = assert -- function() end
local sqrt, cos, sin, atan2, acos = math.sqrt, math.cos, math.sin, math.atan2, math.acos
local ffi = require "ffi"

ffi.cdef[[
typedef struct {
	float x, y, z;
} cpml_vec3;
]]

local vec3 = {}
local new_vec3 = ffi.typeof("cpml_vec3")
-- local new_vec3 = ffi.metatype("cpml_vec3", vec3) -- like setmetatable, but awesomer.

-- If new is called without specified n, we probably don't want an array.
function vec3.new(x, y, z)
	return new_vec3(x, y, z)
end

-- results in out
function vec3.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	out.z = a.z + b.z
end

-- results in out
function vec3.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	out.z = a.z - b.z
end

-- results in out
function vec3.mul(out, a, b)
	out.x = a.x * b.x
	out.y = a.y * b.y
	out.z = a.z * b.z
end

-- results in out
function vec3.div(out, a, b)
	out.x = a.x / b.x
	out.y = a.y / b.y
	out.z = a.z / b.z
end

-- results in out
function vec3.cross(out, a, b)
	out.x = a.y*b.z - a.z*b.y
	out.y = a.z*b.x - a.x*b.z
	out.z = a.x*b.y - a.y*b.x
end

-- returns float
function vec3.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

function vec3.clone(out, a)
	ffi.copy(out, a, ffi.sizeof(out))
end

function vec3.unpack(a)
	return a.x, a.y, a.z
end

function vec3.tostring(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z)
end

function vec3.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z
end

function vec3.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function vec3.normalize(out, a)
	local l = vec3.len(a)
	if l > 0 then
		out.x, out.y, out.z = a.x / l, a.y / l, a.z / l
	end
end

function vec3.rotate(out, a, phi, axis)
	local u = vec3.new(0, 0, 0)
	vec3.normalize(u, axis)
	local c, s = cos(phi), sin(phi)

	-- Calculate generalized rotation matrix
	local m1 = vec3.new((c + u.x * u.x * (1-c)), (u.x * u.y * (1-c) - u.z * s), (u.x * u.z * (1-c) + u.y * s))
	local m2 = vec3.new((u.y * u.x * (1-c) + u.z * s), (c + u.y * u.y * (1-c)), (u.y * u.z * (1-c) - u.x * s))
	local m3 = vec3.new((u.z * u.x * (1-c) - u.y * s), (u.z * u.y * (1-c) + u.x * s), (c + u.z * u.z * (1-c)))

	-- Return rotated vector
	out.x = vec3.dot(a, m1)
	out.y = vec3.dot(a, m2)
	out.z = vec3.dot(a, m3)
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
	return (dx * dx + dy * dy + dz * dz)
end

--[[
local function isvector(v)
	return type(v) == 'table' and type(v.x) == 'number' and type(v.y) == 'number' and type(v.z) == 'number'
end

function vector.__unm(a)
	return new(-a.x, -a.y, -a.z)
end

function vector.__eq(a,b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

function vector.__lt(a,b)
	-- This is a lexicographical order.
	return a.x < b.x or (a.x == b.x and a.y < b.y) or (a.x == b.x and a.y == b.y and a.z < b.z)
end

function vector.__le(a,b)
	-- This is a lexicographical order.
	return a.x <= b.x and a.y <= b.y and a.z <= b.z
end

function vector:project_on(v)
	assert(isvector(v), "invalid argument: cannot project vector on " .. type(v))
	-- (self * v) * v / v:len2()
	local s = (self.x * v.x + self.y * v.y + self.z * v.z) / (v.x * v.x + v.y * v.y + v.z * v.z)
	return new(s * v.x, s * v.y, s * v.z)
end

function vector:project_from(v)
	assert(isvector(v), "invalid argument: cannot project vector on " .. type(v))
	-- Does the reverse of projectOn.
	local s = (v.x * v.x + v.y * v.y + v.z * v.z) / (self.x * v.x + self.y * v.y + self.z * v.z)
	return new(s * v.x, s * v.y, s * v.z)
end

function vector:mirror_on(v)
	assert(isvector(v), "invalid argument: cannot mirror vector on " .. type(v))
	-- 2 * self:projectOn(v) - self
	local s = 2 * (self.x * v.x + self.y * v.y + self.z * v.z) / (v.x * v.x + v.y * v.y + v.z * v.z)
	return new(s * v.x - self.x, s * v.y - self.y, s * v.z - self.z)
end

-- ref.: http://blog.signalsondisplay.com/?p=336
function vector:trim_inplace(maxLen)
	local s = maxLen * maxLen / self:len2()
	s = (s > 1 and 1) or math.sqrt(s)
	self.x, self.y, self.z = self.x * s, self.y * s, self.z * s
	return self
end

function vector:angle_to(other)
	-- Only makes sense in 2D.
	if other then
		return atan2(self.y, self.x) - atan2(other.y, other.x)
	end
	return atan2(self.y, self.x)
end

function vector:angle_between(other)
	if other then
		return acos(self*other / (self:len() * other:len()))
	end
	return 0
end

function vector:orientation_to_direction(orientation)
	orientation = orientation or new(0, 1, 0)
	return orientation
		:rotated(self.z, new(0, 0, 1))
		:rotated(self.y, new(0, 1, 0))
		:rotated(self.x, new(1, 0, 0))
end

-- http://keithmaggio.wordpress.com/2011/02/15/math-magician-lerp-slerp-and-nlerp/
function vector.lerp(a, b, s)
	return a + s * (b - a)
end
--]]

if ... then
	return vec3
end

--------- bench/test
do
	local vec3t = vec3
	local vec3_slow = require "vec3"
	local sin = math.sin

	local result = 0
	local t = os.clock()

	for i = 1, 10000000 do
		result = vec3_slow(0, 1, 0):rotate(sin(i), vec3_slow(0, 0, 1))
	end

	-- print(result)
	print(vec3t.tostring(result))
	print(string.format("Vec3: %0.8f", os.clock() - t))

	result = 0
	local t = os.clock()

	for i = 1, 10000000 do
		result = vec3t.new(0, 1, 0)
		vec3t.rotate(result, result, sin(i), vec3t.new(0, 0, 1))
	end

	print(vec3t.tostring(result))
	print(string.format("Turbo: %0.8f", os.clock() - t))
end
