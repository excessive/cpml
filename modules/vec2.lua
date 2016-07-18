--- A 2 component vector.
-- @module vec2

local atan2 = math.atan2
local sqrt  = math.sqrt
local cos   = math.cos
local sin   = math.sin
local pi    = math.pi
local vec2  = {}

-- Private constructor.
local function new(x, y)
	local v  = {}
	v.x, v.y = x, y
	return setmetatable(v, vec2_mt)
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double x, y;} cpml_vec2;"
		new = ffi.typeof("cpml_vec2")
	end
end

--- The public constructor.
-- @param x Can be of three types: </br>
-- number x component
-- table {x, y} or {x = x, y = y}
-- scalar to fill the vector eg. {x, x}
-- @tparam number y y component
function vec2.new(x, y)
	-- number, number
	if x and y then
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")

		return new(x, y)

	-- {x=x, y=y} or {x, y}
	elseif type(x) == "table" then
		local x, y = x.x or x[1], x.y or x[2]
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")

		return new(x, y)

	-- {x, x} eh. {0, 0}, {3, 3}
	elseif type(x) == "number" then
		return new(x, x)
	else
		return new(0, 0)
	end
end

--- Clone a vector.
-- @tparam vec2 a vector to be cloned
-- @treturn vec2
function vec2.clone(a)
	return new(a.x, a.y)
end

--- Add two vectors.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a Left hand operant
-- @tparam vec2 b Right hand operant
function vec2.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	return out
end

--- Subtract one vector from another.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a Left hand operant
-- @tparam vec2 b Right hand operant
function vec2.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	return out
end

--- Multiply a vector by a scalar.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a Left hand operant
-- @tparam number b Right hand operant
function vec2.mul(out, a, b)
	out.x = a.x * b
	out.y = a.y * b
	return out
end

--- Divide one vector by a scalar.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a Left hand operant
-- @tparam number b Right hand operant
function vec2.div(out, a, b)
	out.x = a.x / b
	out.y = a.y / b
	return out
end

--- Get the normal of a vector.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a vector to normalize
function vec2.normalize(out, a)
	local l = vec2.len(a)
	out.x = a.x / l
	out.y = a.y / l
	return out
end

--- Trim a vector to a given length
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a vector to be trimmed
-- @tparam number len the length to trim the vector to
function vec2.trim(out, a, len)
	len = math.min(vec2.len(a), len)
	vec2.normalize(out, a)
	vec2.mul(out, out, len)
	return out
end

--- Get the cross product of two vectors.
-- @tparam vec2 a Left hand operant
-- @tparam vec2 b Right hand operant
-- @treturn number magnitude of cross product in 3d
function vec2.cross(a, b)
	return a.x * b.y - a.y * b.x
end

--- Get the dot product of two vectors.
-- @tparam vec2 a Left hand operant
-- @tparam vec2 b Right hand operant
-- @treturn number
function vec2.dot(a, b)
	return a.x * b.x + a.y * b.y
end

--- Get the length of a vector.
-- @tparam vec2 a vector to get the length of
-- @treturn number
function vec2.len(a)
	return sqrt(a.x * a.x + a.y * a.y)
end

--- Get the squared length of a vector.
-- @tparam vec2 a vector to get the squared length of
-- @treturn number
function vec2.len2(a)
	return a.x * a.x + a.y * a.y
end

--- Get the distance between two vectors.
-- @tparam vec2 a first vector
-- @tparam vec2 b second vector
-- @treturn number
function vec2.dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return sqrt(dx * dx + dy * dy)
end

--- Get the squared distance between two vectors.
-- @tparam vec2 a first vector
-- @tparam vec2 b second vector
-- @treturn number
function vec2.dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return dx * dx + dy * dy
end

--- Lerp between two vectors.
-- @tparam vec2 out vector for result to be stored in
-- @tparam vec2 a first vector
-- @tparam vec2 b second vector
-- @tparam number s step value
-- @treturn vec2
function vec2.lerp(out, a, b, s)
	vec2.sub(out, b, a)
	vec2.mul(out, out, s)
	vec2.add(out, out, a)
	return out
end

--- Unpack a vector into form x,y
-- @tparam vec2 a first vector
-- @treturn number x component
-- @treturn number y component
function vec2.unpack(a)
	return a.x, a.y
end

--- Return a string formatted "{x, y}"
-- @tparam vec2 a the vector to be turned into a string
-- @treturn string
function vec2.tostring(a)
	return string.format("(%+0.3f,%+0.3f)", a.x, a.y)
end

--- Return a boolean showing if a table is or is not a vec2
-- @param v the object to be tested
-- @treturn boolean
function vec2.isvec2(v)
	return
		(
			type(v) == "table" or
			type(v) == "cdata"
		)  and
		type(v.x) == "number" and
		type(v.y) == "number"
end

--- Convert point from polar to cartesian.
-- @tparam vec2 out vector for result to be stored in
-- @tparam number radius radius of the point
-- @tparam number theta angle of the point (in radians)
-- @treturn vec2
function vec2.to_cartesian(out, radius, theta)
	out.x = radius * cos(theta)
	out.y = radius * sin(theta)
	return out
end

--- Convert point from cartesian to polar.
-- @tparam vec2 a vector to convert
-- @treturn number radius
-- @treturn number theta
function vec2.to_polar(a)
	local radius = sqrt(a.x^2 + a.y^2)
	local theta  = atan2(a.y, a.x)
	theta = theta > 0 and theta or theta + 2 * pi
	return radius, theta
end

local vec2_mt = {}

vec2_mt.__index = vec2
vec2_mt.__tostring = vec2.tostring

function vec2_mt.__call(self, x, y)
	return vec2.new(x, y)
end

function vec2_mt.__tostring(a)
	return vec2.tostring(a)
end

function vec2_mt.__unm(a)
	return vec2.new(-a.x, -a.y)
end

function vec2_mt.__eq(a,b)
	assert(vec2.isvec2(a), "__eq: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(vec2.isvec2(b), "__eq: Wrong argument type for right hand operant. (<cpml.vec2> expected)")

	return a.x == b.x and a.y == b.y
end

function vec2_mt.__add(a, b)
	assert(vec2.isvec2(a), "__add: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(vec2.isvec2(b), "__add: Wrong argument type for right hand operant. (<cpml.vec2> expected)")

	return vec2.add(new(), a, b)
end

function vec2_mt.__sub(a, b)
	assert(vec2.isvec2(a), "__add: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(vec2.isvec2(b), "__add: Wrong argument type for right hand operant. (<cpml.vec2> expected)")

	return vec2.sub(new(), a, b)
end

function vec2_mt.__mul(a, b)
	local isvecb = vec2.isvec2(b)
	a, b = isvecb and b or a, isvecb and a or b

	assert(vec2.isvec2(a), "__mul: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(type(b) == "number", "__mul: Wrong argument type for right hand operant. (<number> expected)")

	return vec2.mul(new(), a, b)
end

function vec2_mt.__div(a, b)
	local isvecb = vec2.isvec2(b)
	a, b = isvecb and b or a, isvecb and a or b

	assert(vec2.isvec2(a), "__div: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(type(b) == "number", "__div: Wrong argument type for right hand operant. (<number> expected)")

	return vec2.div(new(), a, b)
end

vec2.unit_x = new(1, 0)
vec2.unit_y = new(0, 1)

if status then
	ffi.metatype(new, vec2_mt)
end

return setmetatable({}, vec2_mt)
