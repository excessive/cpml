--- A 3 component vector.
-- @module vec3

local sqrt = math.sqrt
local cos  = math.cos
local sin  = math.sin
local vec3 = {}

-- Private constructor.
local function new(x, y, z)
	local v       = {}
	v.x, v.y, v.z = x, y, z
	return setmetatable(v, vec3_mt)
end

vec3.unit_x = new(1, 0, 0)
vec3.unit_y = new(0, 1, 0)
vec3.unit_z = new(0, 0, 1)
vec3.zero   = new(0, 0, 0)

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double x, y, z;} cpml_vec3;"
		new = ffi.typeof("cpml_vec3")
	end
end

-- Statically allocate a temporary variable used in some of our functions.
local tmp = new(0, 0, 0)

--- The public constructor.
-- @param x Can be of three types: </br>
-- number x component
-- table {x, y, z} or {x = x, y = y, z = z}
-- scalar to fill the vector eg. {x, x, x}
-- @tparam number y y component
-- @tparam number z z component
function vec3.new(x, y, z)
	-- number, number, number
	if x and y and z then
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")
		assert(type(z) == "number", "new: Wrong argument type for z (<number> expected)")

		return new(x, y, z)

	-- {x=x, y=y, z=z} or {x, y, z}
	elseif type(x) == "table" then
		local x, y, z = x.x or x[1], x.y or x[2], x.z or x[3]
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")
		assert(type(z) == "number", "new: Wrong argument type for z (<number> expected)")

		return new(x, y, z)

	-- {x, x, x} eh. {0, 0, 0}, {3, 3, 3}
	elseif type(x) == "number" then
		return new(x, x, x)
	else
		return new(0, 0, 0)
	end
end

--- Clone a vector.
-- @tparam vec3 a vector to be cloned
-- @treturn vec3
function vec3.clone(a)
	return new(a.x, a.y, a.z)
end

--- Add two vectors.
-- @tparam vec3 out vector to store the result
-- @tparam vec3 a Left hand operant
-- @tparam vec3 b Right hand operant
function vec3.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	out.z = a.z + b.z
	return out
end

--- Subtract one vector from another.
-- @tparam vec3 out vector to store the result
-- @tparam vec3 a Left hand operant
-- @tparam vec3 b Right hand operant
function vec3.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	out.z = a.z - b.z
	return out
end

--- Multiply a vector by a scalar.
-- @tparam vec3 out vector to store the result
-- @tparam vec3 a Left hand operant
-- @tparam number b Right hand operant
function vec3.mul(out, a, b)
	out.x = a.x * b
	out.y = a.y * b
	out.z = a.z * b
	return out
end

--- Divide a vector by a scakar.
-- @tparam vec3 out vector to store the result
-- @tparam vec3 a Left hand operant
-- @tparam number b Right hand operant
function vec3.div(out, a, b)
	out.x = a.x / b
	out.y = a.y / b
	out.z = a.z / b
	return out
end

--- Get the normal of a vector.
-- @tparam vec3 out vector to store the result
-- @tparam vec3 a vector to normalize
function vec3.normalize(out, a)
	local l = vec3.len(a)
	out.x = a.x / l
	out.y = a.y / l
	out.z = a.z / l
	return out
end

--- Trim a vector to a given length
-- @tparam vec3 out vector to store the result
-- @tparam vec3 a vector to be trimmed
-- @tparam number len the length to trim the vector to
function vec3.trim(out, a, len)
	return out
		:normalize(a)
		:mul(out, math.min(vec3.len(a), len))
end

--- Get the cross product of two vectors.
-- @tparam vec3 out vector to store the result
-- @tparam vec3 a Left hand operant
-- @tparam vec3 b Right hand operant
function vec3.cross(out, a, b)
	out.x = a.y * b.z - a.z * b.y
	out.y = a.z * b.x - a.x * b.z
	out.z = a.x * b.y - a.y * b.x
	return out
end

--- Get the dot product of two vectors.
-- @tparam vec3 a Left hand operant
-- @tparam vec3 b Right hand operant
-- @treturn number
function vec3.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

--- Get the length of a vector.
-- @tparam vec3 a vector to get the length of
-- @treturn number
function vec3.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

--- Get the squared length of a vector.
-- @tparam vec3 a vector to get the squared length of
-- @treturn number
function vec3.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z
end

--- Get the distance between two vectors.
-- @tparam vec3 a first vector
-- @tparam vec3 b second vector
-- @treturn number
function vec3.dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt(dx * dx + dy * dy + dz * dz)
end

--- Get the squared distance between two vectors.
-- @tparam vec3 a first vector
-- @tparam vec3 b second vector
-- @treturn number
function vec3.dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return dx * dx + dy * dy + dz * dz
end

--- Rotate vector about an axis.
-- @param phi Amount to rotate, in radians
-- @param axis Axis to rotate by
-- @return vec3
function vec3.rotate(out, a, phi, axis)
	if not vec3.is_vec3(axis) then
		return a
	end

	local u = new():normalize(axis)
	local c = cos(phi)
	local s = sin(phi)

	-- Calculate generalized rotation matrix
	local m1 = new((c + u.x * u.x * (1 - c)),       (u.x * u.y * (1 - c) - u.z * s), (u.x * u.z * (1 - c) + u.y * s))
	local m2 = new((u.y * u.x * (1 - c) + u.z * s), (c + u.y * u.y * (1 - c)),       (u.y * u.z * (1 - c) - u.x * s))
	local m3 = new((u.z * u.x * (1 - c) - u.y * s), (u.z * u.y * (1 - c) + u.x * s), (c + u.z * u.z * (1 - c))      )

	out.x = a:dot(m1)
	out.y = a:dot(m2)
	out.z = a:dot(m3)
	return out
end

function vec3.perpendicular(out, a)
	out.x = -a.y
	out.y =  a.x
	out.z =  0
	return out
end

--- Lerp between two vectors.
-- @tparam vec3 out vector for result to be stored in
-- @tparam vec3 a first vector
-- @tparam vec3 b second vector
-- @tparam number s step value
-- @treturn vec3
function vec3.lerp(out, a, b, s)
	return out
		:sub(b, a)
		:mul(out, s)
		:add(out, a)
end

--- Unpack a vector into form x,y,z
-- @tparam vec3 a first vector
-- @treturn number x component
-- @treturn number y component
-- @treturn number z component
function vec3.unpack(a)
	return a.x, a.y, a.z
end

--- Return a boolean showing if a table is or is not a vec3
-- @param v the object to be tested
-- @treturn boolean
function vec3.is_vec3(a)
	return
		(
			type(a) == "table" or
			type(a) == "cdata"

		) and
		type(a.x) == "number" and
		type(a.y) == "number" and
		type(a.z) == "number"
end

function vec3.is_zero(a)
	return
		a.x == 0 and
		a.y == 0 and
		a.z == 0
end

--- Return a string formatted "{x, y, z}"
-- @tparam vec3 a the vector to be turned into a string
-- @treturn string
function vec3.to_string(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z)
end

local vec3_mt      = {}
vec3_mt.__index    = vec3
vec3_mt.__tostring = vec3.to_string

function vec3_mt.__call(_, x, y, z)
	return vec3.new(x, y, z)
end

function vec3_mt.__unm(a)
	return new(-a.x, -a.y, -a.z)
end

function vec3_mt.__eq(a, b)
	assert(vec3.is_vec3(a), "__eq: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(vec3.is_vec3(b), "__eq: Wrong argument type for right hand operant. (<cpml.vec3> expected)")
	return a.x == b.x and a.y == b.y and a.z == b.z
end

function vec3_mt.__add(a, b)
	assert(vec3.is_vec3(a), "__add: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(vec3.is_vec3(b), "__add: Wrong argument type for right hand operant. (<cpml.vec3> expected)")
	return new():add(a, b)
end

function vec3_mt.__sub(a, b)
	assert(vec3.is_vec3(a), "__sub: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(vec3.is_vec3(b), "__sub: Wrong argument type for right hand operant. (<cpml.vec3> expected)")
	return new():sub(a, b)
end

function vec3_mt.__mul(a, b)
	assert(vec3.is_vec3(a), "__mul: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(type(b) == "number", "__mul: Wrong argument type for right hand operant. (<number> expected)")
	return new():mul(a, b)
end

function vec3_mt.__div(a, b)
	assert(vec3.is_vec3(a), "__div: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(type(b) == "number", "__div: Wrong argument type for right hand operant. (<number> expected)")
	return new():div(a, b)
end

if status then
	ffi.metatype(new, vec3_mt)
end

return setmetatable({}, vec3_mt)
