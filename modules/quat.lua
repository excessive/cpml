--- A quaternion and associated utilities.
-- @module quat

local modules       = (...):gsub('%.[^%.]+$', '') .. "."
local constants     = require(modules .. "constants")
local vec3          = require(modules .. "vec3")
local DOT_THRESHOLD = constants.DOT_THRESHOLD
local DBL_EPSILON   = constants.DBL_EPSILON
local abs           = math.abs
local acos          = math.acos
local asin          = math.asin
local atan2         = math.atan2
local cos           = math.cos
local sin           = math.sin
local min           = math.min
local max           = math.max
local sqrt          = math.sqrt
local quat          = {}
local quat_mt       = {}

-- Private constructor.
local function new(x, y, z, w)
	local q = {}
	q.x, q.y, q.z, q.w = x, y, z, w
	return setmetatable(q, quat_mt)
end

-- Statically allocate a temporary variable used in some of our functions.
local tmp = new(0, 0, 0, 0)
local uv, uuv = vec3(), vec3()

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double x, y, z, w;} cpml_quat;"
		new = ffi.typeof("cpml_quat")
	end
end

--- Constants
-- @table quat
-- @field unit Unit quaternion
-- @field zero Empty quaternion
quat.unit = new(0, 0, 0, 1)
quat.zero = new(0, 0, 0, 0)

--- The public constructor.
-- @param x Can be of two types: </br>
-- number x X component
-- table {x, y, z, w} or {x=x, y=y, z=z, w=w}
-- @tparam number y Y component
-- @tparam number z Z component
-- @tparam number w W component
-- @treturn quat out
function quat.new(x, y, z, w)
	-- number, number, number, number
	if x and y and z and w then
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")
		assert(type(z) == "number", "new: Wrong argument type for z (<number> expected)")
		assert(type(w) == "number", "new: Wrong argument type for w (<number> expected)")

		return new(x, y, z, w)

	-- {x, y, z, w} or {x=x, y=y, z=z, w=w}
	elseif type(x) == "table" then
		local x, y, z, w = x.x or x[1], x.y or x[2], x.z or x[3], x.w or x[4]
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")
		assert(type(z) == "number", "new: Wrong argument type for z (<number> expected)")
		assert(type(w) == "number", "new: Wrong argument type for w (<number> expected)")

		return new(x, y, z, w)
	end

	return new(0, 0, 0, 1)
end

--- Create a quaternion from an angle/axis pair.
-- @tparam number angle Angle (in radians)
-- @tparam vec3 axis
-- @treturn quat out
function quat.from_angle_axis(angle, axis)
	local len = axis:len()
	local s   = sin(angle * 0.5)
	local c   = cos(angle * 0.5)
	return new(axis.x * s, axis.y * s, axis.z * s, c)
end

--- Create a quaternion from a normal/up vector pair.
-- @tparam vec3 normal
-- @tparam vec3 up (optional)
-- @treturn quat out
function quat.from_direction(normal, up)
	local u = up or vec3.unit_z
	local n = vec3()
	n:normalize(normal)

	local a = vec3():cross(u, n)
	local d = u:dot(n)
	return new(a.x, a.y, a.z, d + 1)
end

--- Clone a quaternion.
-- @tparam quat a Quaternion to clone
-- @treturn quat out
function quat.clone(a)
	return new(a.x, a.y, a.z, a.w)
end

--- Add two quaternions.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Left hand operant
-- @tparam quat b Right hand operant
-- @treturn quat out
function quat.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	out.z = a.z + b.z
	out.w = a.w + b.w
	return out
end

--- Subtract a quaternion from another.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Left hand operant
-- @tparam quat b Right hand operant
-- @treturn quat out
function quat.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	out.z = a.z - b.z
	out.w = a.w - b.w
	return out
end

--- Multiply two quaternions.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Left hand operant
-- @tparam quat b Right hand operant
-- @treturn quat out
function quat.mul(out, a, b)
	out.x = a.x * b.w + a.w * b.x + a.y * b.z - a.z * b.y
	out.y = a.y * b.w + a.w * b.y + a.z * b.x - a.x * b.z
	out.z = a.z * b.w + a.w * b.z + a.x * b.y - a.y * b.x
	out.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
	return out
end

--- Multiply a quaternion and a vec3.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Left hand operant
-- @tparam vec3 b Right hand operant
-- @treturn quat out
function quat.mul_vec3(out, a, b)
	uv:cross(a, b)
	uuv:cross(a, uv)

	return out
		:scale(uv, a.w)
		:add(out, uuv)
		:scale(out, 2)
		:add(b, out)
end

--- Multiply a quaternion by an exponent.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Left hand operant
-- @tparam number n Right hand operant
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
		out:mul(a, out)
	elseif n < 0 then
		out:reciprocal(a)
		out.x = out.x^(-n)
		out.y = out.y^(-n)
		out.z = out.z^(-n)
		out.w = out.w^(-n)
	end

	return out
end

--- Normalize a quaternion.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Quaternion to normalize
-- @treturn quat out
function quat.normalize(out, a)
	return out:scale(a, 1 / a:len())
end

--- Get the dot product of two quaternions.
-- @tparam quat a Left hand operant
-- @tparam quat b Right hand operant
-- @treturn number dot
function quat.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

--- Return the length of a quaternion.
-- @tparam quat a Quaternion to get length of
-- @treturn number len
function quat.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
end

--- Return the squared length of a quaternion.
-- @tparam quat a Quaternion to get length of
-- @treturn number len
function quat.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w
end

--- Multiply a quaternion by a scalar.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Left hand operant
-- @tparam number s Right hand operant
-- @treturn quat out
function quat.scale(out, a, s)
	out.x = a.x * s
	out.y = a.y * s
	out.z = a.z * s
	out.w = a.w * s
	return out
end

--- Alias of from_angle_axis.
-- @tparam number angle Angle (in radians)
-- @tparam vec3 axis
-- @treturn quat out
function quat.rotate(angle, axis)
	return quat.from_angle_axis(angle, axis)
end

--- Return the conjugate of a quaternion.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Quaternion to conjugate
-- @treturn quat out
function quat.conjugate(out, a)
	out.x = -a.x
	out.y = -a.y
	out.z = -a.z
	out.w =  a.w
	return out
end

--- Return the inverse of a quaternion.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Quaternion to invert
-- @treturn quat out
function quat.inverse(out, a)
	return out
		:conjugate(a)
		:normalize(out)
end

--- Return the reciprocal of a quaternion.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Quaternion to reciprocate
-- @treturn quat out
function quat.reciprocal(out, a)
	assert(not a:is_zero(), "Cannot reciprocate a zero quaternion")
	return out
		:conjugate(a)
		:scale(out, 1 / a:len2())
end

--- Lerp between two quaternions.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Left hand operant
-- @tparam quat b Right hand operant
-- @tparam number s Step value
-- @treturn quat out
function quat.lerp(out, a, b, s)
	tmp:sub(b, a)
	tmp:scale(tmp, s)
	tmp:add(tmp, a)
	return out:normalize(tmp)
end

--- Slerp between two quaternions.
-- @tparam quat out Quaternion to store the result
-- @tparam quat a Left hand operant
-- @tparam quat b Right hand operant
-- @tparam number s Step value
-- @treturn quat out
function quat.slerp(out, a, b, s)
	local dot = a:dot(b)

	if dot < 0 then
		a:scale(a, -1)
		dot = -dot
	end

	if dot > DOT_THRESHOLD then
		return out:lerp(a, b, s)
	end

	dot = min(max(dot, -1), 1)
	local theta = acos(dot) * s

	tmp:scale(a, cos(theta))

	return out
		:scale(a, dot)
		:sub(b, out)
		:normalize(out)
		:scale(out, sin(theta))
		:add(tmp, out)
end

--- Unpack a quaternion into individual components.
-- @tparam quat a Quaternion to unpack
-- @treturn number x
-- @treturn number y
-- @treturn number z
-- @treturn number w
function quat.unpack(a)
	return a.x, a.y, a.z, a.w
end

--- Return a boolean showing if a table is or is not a quat.
-- @tparam quat a Quaternion to be tested
-- @treturn boolean is_quat
function quat.is_quat(a)
	if type(a) == "cdata" then
		return ffi.istype("cpml_quat", a)
	end

	return
		type(a)   == "table"  and
		type(a.x) == "number" and
		type(a.y) == "number" and
		type(a.z) == "number" and
		type(a.w) == "number"
end

--- Return a boolean showing if a table is or is not a zero quat.
-- @tparam quat a Quaternion to be tested
-- @treturn boolean is_zero
function quat.is_zero(a)
	return
		a.x == 0 and
		a.y == 0 and
		a.z == 0 and
		a.w == 0
end

--- Return a boolean showing if a table is or is not a real quat.
-- @tparam quat a Quaternion to be tested
-- @treturn boolean is_real
function quat.is_real(a)
	return
		a.x == 0 and
		a.y == 0 and
		a.z == 0
end

--- Return a boolean showing if a table is or is not an imaginary quat.
-- @tparam quat a Quaternion to be tested
-- @treturn boolean is_imaginary
function quat.is_imaginary(a)
	return a.w == 0
end

--- Convert a quaternion into an angle/axis pair.
-- @tparam quat a Quaternion to convert
-- @treturn number angle
-- @treturn vec3 axis
function quat.to_angle_axis(a)
	if a.w > 1 or a.w < -1 then
		a:normalize(a)
	end

	local angle = 2 * acos(a.w)
	local s     = sqrt(1 - a.w * a.w)
	local x, y, z

	if s < constants.DBL_EPSILON then
		x = a.x
		y = a.y
		z = a.z
	else
		x = a.x / s -- normalize axis
		y = a.y / s
		z = a.z / s
	end

	return angle, vec3(x, y, z)
end

--- Convert a quaternion into a vec3.
-- @tparam quat a Quaternion to convert
-- @treturn vec3 out
function quat.to_vec3(a)
	local out = vec3()
	out.x = a.x
	out.y = a.y
	out.z = a.z
	return out
end

--- Return a formatted string.
-- @tparam quat a Quaternion to be turned into a string
-- @treturn string formatted
function quat.to_string(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z, a.w)
end

quat_mt.__index    = quat
quat_mt.__tostring = quat.to_string

function quat_mt.__call(_, x, y, z, w)
	return quat.new(x, y, z, w)
end

function quat_mt.__unm(a)
	return new():scale(a, -1)
end

function quat_mt.__eq(a,b)
	if not quat.is_quat(a) or not quat.is_quat(b) then
		return false
	end
	return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

function quat_mt.__add(a, b)
	assert(quat.is_quat(a), "__add: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(quat.is_quat(b), "__add: Wrong argument type for right hand operant. (<cpml.quat> expected)")
	return new():add(a, b)
end

function quat_mt.__sub(a, b)
	assert(quat.is_quat(a), "__sub: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(quat.is_quat(b), "__sub: Wrong argument type for right hand operant. (<cpml.quat> expected)")
	return new():sub(a, b)
end

function quat_mt.__mul(a, b)
	assert(quat.is_quat(a), "__mul: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(quat.is_quat(b) or vec3.is_vec3(b) or type(b) == "number", "__mul: Wrong argument type for right hand operant. (<cpml.quat> or <cpml.vec3> or <number> expected)")

	if quat.is_quat(b) then
		return new():mul(a, b)
	end

	if type(b) == "number" then
		return new():scale(a, b)
	end

	return quat.mul_vec3(vec3(), a, b)
end

function quat_mt.__pow(a, n)
	assert(quat.is_quat(a), "__pow: Wrong argument type for left hand operant. (<cpml.quat> expected)")
	assert(type(n) == "number", "__pow: Wrong argument type for right hand operant. (<number> expected)")
	return new():pow(a, n)
end

if status then
	ffi.metatype(new, quat_mt)
end

return setmetatable({}, quat_mt)
