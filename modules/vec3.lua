--- A 3 component vector.
-- @module vec3

local modules = (...):gsub('%.[^%.]+$', '') .. "."
local precond = require(modules .. "_private_precond")
local private = require(modules .. "_private_utils")
local sqrt    = math.sqrt
local cos     = math.cos
local sin     = math.sin
local vec3    = {}
local vec3_mt = {}

-- Private constructor.
local function new(x, y, z)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		z = z or 0
	}, vec3_mt)
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double x, y, z;} cpml_vec3;"
		new = ffi.typeof("cpml_vec3")
	end
end

--- Constants
-- @table vec3
-- @field unit_x X axis of rotation
-- @field unit_y Y axis of rotation
-- @field unit_z Z axis of rotation
-- @field zero Empty vector
vec3.unit_x = new(1, 0, 0)
vec3.unit_y = new(0, 1, 0)
vec3.unit_z = new(0, 0, 1)
vec3.zero   = new(0, 0, 0)

--- The public constructor.
-- @param x Can be of three types: </br>
-- number X component
-- table {x, y, z} or {x=x, y=y, z=z}
-- scalar To fill the vector eg. {x, x, x}
-- @tparam number y Y component
-- @tparam number z Z component
-- @treturn vec3 out
function vec3.new(x, y, z)
	-- number, number, number
	if x and y and z then
		precond.typeof(x, "number", "new: Wrong argument type for x")
		precond.typeof(y, "number", "new: Wrong argument type for y")
		precond.typeof(z, "number", "new: Wrong argument type for z")

		return new(x, y, z)

	-- {x, y, z} or {x=x, y=y, z=z}
	elseif type(x) == "table" or type(x) == "cdata" then -- table in vanilla lua, cdata in luajit
		local xx, yy, zz = x.x or x[1], x.y or x[2], x.z or x[3]
		precond.typeof(xx, "number", "new: Wrong argument type for x")
		precond.typeof(yy, "number", "new: Wrong argument type for y")
		precond.typeof(zz, "number", "new: Wrong argument type for z")

		return new(xx, yy, zz)

	-- number
	elseif type(x) == "number" then
		return new(x, x, x)
	else
		return new()
	end
end

--- Clone a vector.
-- @tparam vec3 a Vector to be cloned
-- @treturn vec3 out
function vec3.clone(a)
	return new(a.x, a.y, a.z)
end

--- Add two vectors.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn vec3 out
function vec3.add(a, b)
	return new(
		a.x + b.x,
		a.y + b.y,
		a.z + b.z
	)
end

--- Subtract one vector from another.
-- Order: If a and b are positions, computes the direction and distance from b
-- to a.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn vec3 out
function vec3.sub(a, b)
	return new(
		a.x - b.x,
		a.y - b.y,
		a.z - b.z
	)
end

--- Multiply a vector by another vector.
-- Component-wise multiplication not matrix multiplication.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn vec3 out
function vec3.mul(a, b)
	return new(
		a.x * b.x,
		a.y * b.y,
		a.z * b.z
	)
end

--- Divide a vector by another.
-- Component-wise inv multiplication. Like a non-uniform scale().
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn vec3 out
function vec3.div(a, b)
	return new(
		a.x / b.x,
		a.y / b.y,
		a.z / b.z
	)
end

--- Scale a vector to unit length (1).
-- @tparam vec3 a vector to normalize
-- @treturn vec3 out
function vec3.normalize(a)
	if a:is_zero() then
		return new()
	end
	return a:scale(1 / a:len())
end

--- Scale a vector to unit length (1), and return the input length.
-- @tparam vec3 a vector to normalize
-- @treturn vec3 out
-- @treturn number input vector length
function vec3.normalize_len(a)
	if a:is_zero() then
		return new(), 0
	end
	local len = a:len()
	return a:scale(1 / len), len
end

--- Trim a vector to a given length
-- @tparam vec3 a vector to be trimmed
-- @tparam number len Length to trim the vector to
-- @treturn vec3 out
function vec3.trim(a, len)
	return a:normalize():scale(math.min(a:len(), len))
end

--- Get the cross product of two vectors.
-- Resulting direction is right-hand rule normal of plane defined by a and b.
-- Magnitude is the area spanned by the parallelograms that a and b span.
-- Order: Direction determined by right-hand rule.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn vec3 out
function vec3.cross(a, b)
	return new(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
	)
end

--- Get the dot product of two vectors.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn number dot
function vec3.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

--- Get the length of a vector.
-- @tparam vec3 a Vector to get the length of
-- @treturn number len
function vec3.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

--- Get the squared length of a vector.
-- @tparam vec3 a Vector to get the squared length of
-- @treturn number len
function vec3.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z
end

--- Get the distance between two vectors.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn number dist
function vec3.dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt(dx * dx + dy * dy + dz * dz)
end

--- Get the squared distance between two vectors.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn number dist
function vec3.dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return dx * dx + dy * dy + dz * dz
end

--- Scale a vector by a scalar.
-- @tparam vec3 a Left hand operand
-- @tparam number b Right hand operand
-- @treturn vec3 out
function vec3.scale(a, b)
	return new(
		a.x * b,
		a.y * b,
		a.z * b
	)
end

--- Rotate vector about an axis.
-- @tparam vec3 a Vector to rotate
-- @tparam number phi Angle to rotate vector by (in radians)
-- @tparam vec3 axis Axis to rotate by
-- @treturn vec3 out
function vec3.rotate(a, phi, axis)
	if not vec3.is_vec3(axis) then
		return a
	end

	local u = axis:normalize()
	local c = cos(phi)
	local s = sin(phi)

	-- Calculate generalized rotation matrix
	local m1 = new((c + u.x * u.x * (1 - c)),       (u.x * u.y * (1 - c) - u.z * s), (u.x * u.z * (1 - c) + u.y * s))
	local m2 = new((u.y * u.x * (1 - c) + u.z * s), (c + u.y * u.y * (1 - c)),       (u.y * u.z * (1 - c) - u.x * s))
	local m3 = new((u.z * u.x * (1 - c) - u.y * s), (u.z * u.y * (1 - c) + u.x * s), (c + u.z * u.z * (1 - c))      )

	return new(
		a:dot(m1),
		a:dot(m2),
		a:dot(m3)
	)
end

--- Get the perpendicular vector of a vector.
-- @tparam vec3 a Vector to get perpendicular axes from
-- @treturn vec3 out
function vec3.perpendicular(a)
	return new(-a.y, a.x, 0)
end

--- Lerp between two vectors.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @tparam number s Step value
-- @treturn vec3 out
function vec3.lerp(a, b, s)
	return a + (b - a) * s
end

-- Round all components to nearest int (or other precision).
-- @tparam vec3 a Vector to round.
-- @tparam precision Digits after the decimal (round numebr if unspecified)
-- @treturn vec3 Rounded vector
function vec3.round(a, precision)
	return vec3.new(private.round(a.x, precision), private.round(a.y, precision), private.round(a.z, precision))
end

--- Unpack a vector into individual components.
-- @tparam vec3 a Vector to unpack
-- @treturn number x
-- @treturn number y
-- @treturn number z
function vec3.unpack(a)
	return a.x, a.y, a.z
end

--- Return the component-wise minimum of two vectors.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn vec3 A vector where each component is the lesser value for that component between the two given vectors.
function vec3.component_min(a, b)
	return new(math.min(a.x, b.x), math.min(a.y, b.y), math.min(a.z, b.z))
end

--- Return the component-wise maximum of two vectors.
-- @tparam vec3 a Left hand operand
-- @tparam vec3 b Right hand operand
-- @treturn vec3 A vector where each component is the lesser value for that component between the two given vectors.
function vec3.component_max(a, b)
	return new(math.max(a.x, b.x), math.max(a.y, b.y), math.max(a.z, b.z))
end

-- Negate x axis only of vector.
-- @tparam vec3 a Vector to x-flip.
-- @treturn vec3 x-flipped vector
function vec3.flip_x(a)
	return vec3.new(-a.x, a.y, a.z)
end

-- Negate y axis only of vector.
-- @tparam vec3 a Vector to y-flip.
-- @treturn vec3 y-flipped vector
function vec3.flip_y(a)
	return vec3.new(a.x, -a.y, a.z)
end

-- Negate z axis only of vector.
-- @tparam vec3 a Vector to z-flip.
-- @treturn vec3 z-flipped vector
function vec3.flip_z(a)
	return vec3.new(a.x, a.y, -a.z)
end

function vec3.angle_to(a, b)
	local v = a:normalize():dot(b:normalize())
	return math.acos(v)
end

--- Return a boolean showing if a table is or is not a vec3.
-- @tparam vec3 a Vector to be tested
-- @treturn boolean is_vec3
function vec3.is_vec3(a)
	if type(a) == "cdata" then
		return ffi.istype("cpml_vec3", a)
	end

	return
		type(a)   == "table"  and
		type(a.x) == "number" and
		type(a.y) == "number" and
		type(a.z) == "number"
end

--- Return a boolean showing if a table is or is not a zero vec3.
-- @tparam vec3 a Vector to be tested
-- @treturn boolean is_zero
function vec3.is_zero(a)
	return a.x == 0 and a.y == 0 and a.z == 0
end

--- Return whether any component is NaN
-- @tparam vec3 a Vector to be tested
-- @treturn boolean if x,y, or z are nan
function vec3.has_nan(a)
	return private.is_nan(a.x) or
		private.is_nan(a.y) or
		private.is_nan(a.z)
end

--- Return a formatted string.
-- @tparam vec3 a Vector to be turned into a string
-- @treturn string formatted
function vec3.to_string(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z)
end

vec3_mt.__index    = vec3
vec3_mt.__tostring = vec3.to_string

function vec3_mt.__call(_, x, y, z)
	return vec3.new(x, y, z)
end

function vec3_mt.__unm(a)
	return new(-a.x, -a.y, -a.z)
end

function vec3_mt.__eq(a, b)
	if not vec3.is_vec3(a) or not vec3.is_vec3(b) then
		return false
	end
	return a.x == b.x and a.y == b.y and a.z == b.z
end

function vec3_mt.__add(a, b)
	precond.assert(vec3.is_vec3(a), "__add: Wrong argument type '%s' for left hand operand. (<cpml.vec3> expected)", type(a))
	precond.assert(vec3.is_vec3(b), "__add: Wrong argument type '%s' for right hand operand. (<cpml.vec3> expected)", type(b))
	return a:add(b)
end

function vec3_mt.__sub(a, b)
	precond.assert(vec3.is_vec3(a), "__sub: Wrong argument type '%s' for left hand operand. (<cpml.vec3> expected)", type(a))
	precond.assert(vec3.is_vec3(b), "__sub: Wrong argument type '%s' for right hand operand. (<cpml.vec3> expected)", type(b))
	return a:sub(b)
end

function vec3_mt.__mul(a, b)
	precond.assert(vec3.is_vec3(a), "__mul: Wrong argument type '%s' for left hand operand. (<cpml.vec3> expected)", type(a))
	precond.assert(vec3.is_vec3(b) or type(b) == "number", "__mul: Wrong argument type '%s' for right hand operand. (<cpml.vec3> or <number> expected)", type(b))

	if vec3.is_vec3(b) then
		return a:mul(b)
	end

	return a:scale(b)
end

function vec3_mt.__div(a, b)
	precond.assert(vec3.is_vec3(a), "__div: Wrong argument type '%s' for left hand operand. (<cpml.vec3> expected)", type(a))
	precond.assert(vec3.is_vec3(b) or type(b) == "number", "__div: Wrong argument type '%s' for right hand operand. (<cpml.vec3> or <number> expected)", type(b))

	if vec3.is_vec3(b) then
		return a:div(b)
	end

	return a:scale(1 / b)
end

if status then
	xpcall(function() -- Allow this to silently fail; assume failure means someone messed with package.loaded
		ffi.metatype(new, vec3_mt)
	end, function() end)
end

return setmetatable({}, vec3_mt)
