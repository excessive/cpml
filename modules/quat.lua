--- A quaternion and associated utilities.
-- @module quat

local current_folder = (...):gsub('%.[^%.]+$', '') .. "."

local constants      = require(current_folder .. "constants")
local vec3           = require(current_folder .. "vec3")

local ffi            = require "ffi"
local DOT_THRESHOLD  = constants.DOT_THRESHOLD
local FLT_EPSILON    = constants.FLT_EPSILON

local abs, acos, asin, atan2 = math.abs, math.acos, math.asin, math.atan2
local cos, sin, min, max, pi = math.cos, math.sin, math.min, math.max, math.pi
local sqrt = math.sqrt

local quat = {}

-- Private constructor.
local function new(x, y, z, w)
	local q = {}
	q.x, q.y, q.z, q.w = x, y, z, w
	return setmetatable(q, quat_mt)
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double x, y, z, w;} cpml_quat;"
		new = ffi.typeof("cpml_quat")
	end
end

--- The public constructor.
-- @param x Can be of two types: </br>
-- number x component
-- table {x, y, z, w} or {x = x, y = y, z = z, w = w}
-- @tparam number y y component
-- @tparam number z z component
-- @tparam number w w component
function quat.new(x, y, z, w)
	-- number, number, number, number
	if x and y and z and w then
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")
		assert(type(z) == "number", "new: Wrong argument type for z (<number> expected)")
		assert(type(w) == "number", "new: Wrong argument type for w (<number> expected)")

		return new(x, y. z, w)

	-- {x=x, y=y, z=z, w=w} or {x, y, z, w}
	elseif type(x) == "table" then
		local x, y, z, w = x.x or x[1], x.y or x[2], x.z or x[3], x.w or x[4]
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")
		assert(type(z) == "number", "new: Wrong argument type for z (<number> expected)")
		assert(type(w) == "number", "new: Wrong argument type for w (<number> expected)")

		return new(x, y, z, w)

	else
		return new(0, 0, 0, 1)
	end
end

--- Create a quaternion from an axis, angle pair.
-- @tparam vec3 axis
-- @tparam number angle
-- @treturn quat
function quat.from_axis_angle(axis, angle)
	local len = vec3.len(axis)

	local s = sin(angle * 0.5)
	local c = cos(angle * 0.5)

	return quat.new(axis.x*s, axis.y*s, axis.z*s, c)
end

--- Create a quaternion from a normalized, up vector pair.
-- @tparam vec3 normal
-- @tparam vec3 up
-- @treturn quat
function quat.from_direction(normal, up)
	local d = vec3.dot(up, normal)
	local a = vec3()
	vec3.cross(a, up, normal)
	return quat.new(a.x, a.y, a.z, d+1)
end

--- Clone a quaternion.
-- @tparam quat a
-- @treturn quat clone
function quat.clone(a)
	new(a.x, a.y, a.z, a.w)
end

--- Component-wise add a quaternion.
-- @tparam quat out
-- @tparam quat a
-- @tparam quat b
-- @treturn quat out
function quat.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	out.z = a.z + b.z
	out.w = a.w + b.w
	return out
end

--- Component-wise subtract a quaternion.
-- @tparam quat out
-- @tparam quat a
-- @tparam quat b
-- @treturn quat out
function quat.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	out.z = a.z - b.z
	out.w = a.w - b.w
	return out
end

--- Perform a quaternion multiplication.
-- @tparam quat out
-- @tparam quat a
-- @tparam quat b
-- @treturn quat out
function quat.mul(out, a, b)
	out.x = a.x * b.w + a.w * b.x + a.y * b.z - a.z * b.y
	out.y = a.y * b.w + a.w * b.y + a.z * b.x - a.x * b.z
	out.z = a.z * b.w + a.w * b.z + a.x * b.y - a.y * b.x
	out.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
	return out
end

--- Perform a quaternion and vec3 multiplication.
-- @tparam quat out
-- @tparam quat a
-- @tparam vec3 b
-- @treturn vec3 out
local uv, uuv = vec3(), vec3()
function quat.mul_vec3(out, a, b)
	vec3.cross(uv, a, b)
	vec3.cross(uuv, a, uv)
	vec3.mul(out, uv, a.w)
	vec3.add(out, out, uuv)
	vec3.mul(out, out, 2)
	vec3.add(out, b, out)
end

--- Pow a quaternion by an exponent
-- @tparam quat out
-- @tparam quat a
-- @tparam number n
-- @treturn quat out
function quat.pow(out, a, n)
	if n == 0 then
		out.x = 0
		out.y = 0
		out.z = 0
		out.w = 1
	elseif n > 0 then
		out.x = a.x^(n-1)
		out.y = a.y^(n-1)
		out.z = a.z^(n-1)
		out.w = a.w^(n-1)
		quat.mul(out, a, out)
	elseif n < 0 then
		quat.reciprocal(out, a)
		out.x = out.x^(-n)
		out.y = out.y^(-n)
		out.z = out.z^(-n)
		out.w = out.w^(-n)
	end

	return out
end

--- Component-wise scale a quaternion by a scalar.
-- @tparam quat out
-- @tparam quat a
-- @tparam number s
-- @treturn quat out
function quat.scale(out, a, s)
	out.x = a.x * s
	out.y = a.y * s
	out.z = a.z * s
	out.w = a.w * s
	return out
end

--- Return the conjugate of a quaternion.
-- @tparam quat out
-- @tparam quat a
-- @treturn quat out
function quat.conjugate(out, a)
	out.x = -a.x
	out.y = -a.y
	out.z = -a.z
	out.w = a.w
	return out
end

--- Return the inverse of a quaternion.
-- @tparam quat out
-- @tparam quat a
-- @treturn quat out
function quat.inverse(out, a)
	quat.conjugate(out, a)
	quat.normalize(out, out)
	return out
end

--- Return the reciprocal of a quaternion.
-- @tparam quat out
-- @tparam quat a
-- @treturn quat out
function quat.reciprocal(out, a)
	local l = quat.len2(a)
	quat.conjugate(out, a)
	quat.scale(out, out, 1 / l)
	return out
end

--- Linearly interpolate from one quaternion to the next.
-- @tparam quat out
-- @tparam quat a
-- @tparam quat b
-- @tparam number s 0-1 range number; 0 = a 1 = b
-- @treturn quat out
function quat.lerp(out, a, b, s)
	quat.sub(out, b, a)
	quat.mul(out, out, s)
	quat.add(out, a, out)
	quat.normalize(out, out)
	return out
end

--- Slerp from one quaternion to the next.
-- @tparam quat out
-- @tparam quat a
-- @tparam quat b
-- @tparam number s 0-1 range number; 0 = a 1 = b
-- @treturn quat out
function quat.slerp(out, a, b, s)
	local dot = quat.dot(a, b)

	if dot < 0 then
		quat.scale(a, a, -1)
		dot = -dot
	end

	if dot > DOT_THRESHOLD then
		quat.lerp(out, a, b, s)
		return
	end

	dot = min(max(dot, -1), 1)
	local temp  = quat.new()
	local theta = acos(dot) * s

	quat.scale(out, a, dot)
	quat.sub(out, b, out)
	quat.normalize(out, out)
	quat.scale(out, out, sin(theta))
	quat.scale(temp, a, cos(theta))
	quat.add(out, temp, out)
	return out
end

--- Normalize a quaternion.
-- @tparam quat out
-- @tparam quat a
-- @treturn quat out
function quat.normalize(out, a)
	local l = 1 / quat.len(a)
	quat.scale(out, a, l)
	return out
end

--- Return the imaginary part of the quaternion as a vec3.
-- @tparam vec3 out
-- @tparam quat a
-- @treturn quat out
function quat.imaginary(out, a)
	out.x = a.x
	out.y = a.y
	out.z = a.z
	return out
end

--- Return the real part of a quaternion.
-- @tparam quat a
-- @treturn number real
function quat.real(a)
	return a.w
end

--- Return the inner angle between two quaternions.
-- @tparam quat a
-- @tparam quat b
-- @treturn number angle
function quat.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

--- Return the length of a quaternion.
-- @tparam quat a
-- @treturn number len
function quat.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
end

--- Return the squared length of a quaternion.
-- @tparam quat a
-- @treturn number len
function quat.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w
end

--- Unpack a quaternion into form x,y,z,w.
-- @tparam quat a
-- @treturn number x
-- @treturn number y
-- @treturn number z
-- @treturn number w
function quat.unpack(a)
	return a.x, a.y, a.z, a.w
end

--- Return a string formatted "{x, y, z, w}"
-- @tparam quat a
-- @treturn string
function quat.tostring(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z, a.w)
end

--- Return a boolean showing if a table is or is not a quat
-- @param q object to be tested
-- @treturn boolean
function quat.isquat(q)
	return
		type(v)   == "table"  and
		type(v.x) == "number" and
		type(v.y) == "number" and
		type(v.z) == "number" and
		type(v.w) == "number"
end

local quat_mt = {}

quat_mt.__index = quat
quat_mt.__tostring = quat.tostring

function quat_mt.__call(self, x, y, z)
	return quat.new(x, y, z, w)
end

function quat_mt.__unm(a)
	local temp = quat.new()
	quat.scale(temp, a, -1)
	return temp
end

function quat_mt.__eq(a,b)
	assert(quat.isquat(a), "__eq: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(quat.isquat(b), "__eq: Wrong argument type for right hand operant. (<cpml.quat> expected)")
	return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

function quat_mt.__add(a, b)
	assert(quat.isquat(a), "__add: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(quat.isquat(b), "__add: Wrong argument type for right hand operant. (<cpml.quat> expected)")

	local temp = quat.new()
	quat.add(temp, a, b)
	return temp
end

function quat_mt.__sub(a, b)
	assert(quat.isquat(a), "__sub: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(quat.isquat(b), "__sub: Wrong argument type for right hand operant. (<cpml.quat> expected)")

	local temp = quat.new()
	quat.sub(temp, a, b)
	return temp
end

function quat_mt.__mul(a, b)
	assert(quat.isquat(a), "__mul: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(quat.isquat(b) or vec3.isvec3(b), "__mul: Wrong argument type for right hand operant. (<cpml.quat> or <cpml.vec3> expected)")

	if quat.isquat(b) then
		local temp = quat.new()
		quat.mul(temp, a, b)
		return temp
	elseif vec3.isvec3(b) then
		local temp = vec3()
		quat.mul_vec3(temp, a, b)
		return temp
	end
end

function quat_mt.__pow(a, n)
	assert(quat.isquat(a), "__pow: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(type(b) == "number", "__pow: Wrong argument type for right hand operant. (<number> expected)")

	local temp = quat.new()
	quat.pow(temp, a, n)
	return temp
end

if status then
	ffi.metatype(new, quat_mt)
end

return setmetatable({}, quat_mt)
