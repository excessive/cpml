-- quaternions
-- @author: Andrew Stacey
-- Website: http://www.math.ntnu.no/~stacey/HowDidIDoThat/iPad/Codea.html
-- Licence: CC0 http://wiki.creativecommons.org/CC0

--[[
This is a class for handling quaternion numbers.  It was originally
designed as a way of encoding rotations of 3 dimensional space.
--]]

local current_folder = (...):gsub('%.[^%.]+$', '') .. "."
local constants      = require(current_folder .. "constants")
local vec3           = require(current_folder .. "vec3")
local quaternion     = {}
quaternion.__index   = quaternion
quaternion.x = 0
quaternion.y = 0
quaternion.z = 0
quaternion.w = 0

--[[
A quaternion can either be specified by giving the four coordinates as
real numbers or by giving the scalar part and the vector part.
--]]

function quaternion.new(x, y, z, w)

	if type(x) == "table" then
		local q = x
		local rn = y

		if not rn then
			if q.x then
				return setmetatable(q, quaternion)
			else
				return setmetatable({x = q[1], y = q[2], z = q[3], w = q[4]}, quaternion)
			end
		else
			return setmetatable({x = q.x or q[1], y = q.y or q[2], z = q.z or q[3], w = rn}, quaternion)
		end
	end

	return setmetatable({x = x, y = y, z = z, w = w}, quaternion)
end

function quaternion.__add(a, b)
	if type(b) == "number" then
		return quaternion.new(a.x, a.y, a.z, a.w + b)
	end

	return quaternion.new(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
end

function quaternion.__sub(a, b)
	return quaternion.new(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
end

function quaternion:__unm()
	return self:scale(-1)
end

function quaternion.__mul(a, b)
	-- quat * number
	if type(b) == "number" then
		return a:scale(b)
	-- quat * quat
	elseif type(b) == "table" and b.w then
		local x, y, z, w

		x = a.x * b.w + a.w * b.x + a.y * b.z - a.z * b.y
		y = a.y * b.w + a.w * b.y + a.z * b.x - a.x * b.z
		z = a.z * b.w + a.w * b.z + a.x * b.y - a.y * b.x
		w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z

		return quaternion.new(x, y, z, w)
	else
		local qv  = vec3(a.x, a.y, a.z)
		local uv  = qv:cross(b)
		local uuv = qv:cross(uv)

		return b + ((uv * a.w) + uuv) * 2
	end
end

function quaternion.__div(a, b)
	if type(b) == "number" then
		return a:scale(1 / b)
	elseif type(b) == "table" then
		return a * b:reciprocal()
	end
end

function quaternion:__pow(n)
	if n == 0 then
		return self.unit()
	elseif n > 0 then
		return self * self^(n-1)
	elseif n < 0 then
		return self:reciprocal()^(-n)
	end
end

function quaternion.__eq(a, b)
	if a.x ~= b.x or a.y ~= b.y or a.z ~= b.z or a.w ~= b.w then
		return false
	end

	return true
end

function quaternion:__tostring()
	return string.format("(%0.3f,%0.3f,%0.3f,%0.3f)", self.x, self.y, self.z, self.x)
end

function quaternion:unpack()
	return self.x, self.y, self.z, self.w
end

function quaternion.unit()
	return quaternion.new(0, 0, 0, 1)
end

function quaternion:to_axis_angle()
	if self.w > 1 or self.w < -1 then
		self = self:normalize()
	end

	local angle = 2 * math.acos(self.w)
	local s     = math.sqrt(1-self.w*self.w)
	local x, y, z

	if s < constants.FLT_EPSILON then
		x = self.x
		y = self.y
		z = self.z
	else
		x = self.x / s -- normalize axis
		y = self.y / s
		z = self.z / s
	end

	return angle, { x, y, z }
end

-- Test if we are zero
function quaternion:is_zero()
	-- are we the zero vector
	if self.x ~= 0 or self.y ~= 0 or self.z ~= 0 or self.w ~= 0 then
		return false
	end

	return true
end

-- Test if we are real
function quaternion:is_real()
	-- are we the zero vector
	if self.x ~= 0 or self.y ~= 0 or self.z ~= 0 then
		return false
	end

	return true
end

-- Test if the real part is zero
function quaternion:is_imaginary()
	-- are we the zero vector
	if self.w ~= 0 then
		return false
	end

	return true
end

-- The dot product of two quaternions
function quaternion.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

function quaternion.cross(a, b)
	return quaternion.new(
		a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
		a.w * b.y + a.y * b.w + a.z * b.x - a.x * b.z,
		a.w * b.z + a.z * b.w + a.x * b.y - a.y * b.x,
		a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
	)
end

-- Length of a quaternion
function quaternion:len()
	return math.sqrt(self:len2())
end

-- Length squared of a quaternion
function quaternion:len2()
	return self:dot(self)
end

-- Normalize a quaternion to have length 1
function quaternion:normalize()
	if self:is_zero() then
		error("Unable to normalize a zero-length quaternion")
		return false
	end

	local l = 1 / self:len()
	return self:scale(l)
end

-- Scale the quaternion
function quaternion:scale(l)
	return quaternion.new(self.x * l, self.y * l, self.z * l, self.w * l)
end

-- Conjugation (corresponds to inverting a rotation)
function quaternion:conjugate()
	return quaternion.new(-self.x, -self.y, -self.z, self.w)
end

function quaternion:inverse()
	return self:conjugate():normalize()
end

-- Reciprocal: 1/q
function quaternion:reciprocal()
	if self.is_zero() then
		error("Cannot reciprocate a zero quaternion")
		return false
	end

	local q = self:conjugate()
	local l = self:len2()
	q = q:scale(1 / l)

	return q
end

-- Returns the real part
function quaternion:real()
	return self.w
end

function quaternion:clone()
	return quaternion.new(self.x, self.y, self.z, self.w)
end

-- Returns the vector (imaginary) part as a Vec3 object
function quaternion:to_vec3()
	return vec3(self.x, self.y, self.z)
end

--[[
Converts a rotation to a quaternion. The first argument is the angle
to rotate, the second must specify an axis as a Vec3 object.
--]]

function quaternion.rotate(angle, axis)
	local len = axis:len()

	if math.abs(len - 1) > 0.001 then
		axis.x = axis.x / len
		axis.y = axis.y / len
		axis.z = axis.z / len
	end

	local sin = math.sin(angle * 0.5)
	local cos = math.cos(angle * 0.5)

	return quaternion.new(axis.x * sin, axis.y * sin, axis.z * sin, cos)
end

function quaternion:to_euler()
	local sqx = self.x*self.x
	local sqy = self.y*self.y
	local sqz = self.z*self.z
	local sqw = self.w*self.w

	 -- if normalised is one, otherwise is correction factor
	local unit = sqx + sqy + sqz + sqw
	local test = self.x*self.y + self.z*self.w

	local pitch, yaw, roll

	 -- singularity at north pole
	if test > 0.499*unit then
		yaw = 2 * math.atan2(self.x,self.w)
		pitch = math.pi/2
		roll = 0
		return pitch, yaw, roll
	end

	 -- singularity at south pole
	if test < -0.499*unit then
		yaw = -2 * math.atan2(self.x,self.w)
		pitch = -math.pi/2
		roll = 0
		return pitch, yaw, roll
	end

	yaw   = math.atan2(2*self.y*self.w-2*self.x*self.z , sqx - sqy - sqz + sqw)
	pitch = math.asin(2*test/unit)
	roll  = math.atan2(2*self.x*self.w-2*self.y*self.z , -sqx + sqy - sqz + sqw)

	return pitch, roll, yaw
end

-- http://keithmaggio.wordpress.com/2011/02/15/math-magician-lerp-slerp-and-nlerp/
-- non-normalized rotations do not work out for quats!
function quaternion.lerp(a, b, s)
	local v = a + (b - a) * s
	return v:normalize()
end

-- http://number-none.com/product/Understanding%20Slerp,%20Then%20Not%20Using%20It/
function quaternion.slerp(a, b, s)
	local function clamp(n, low, high) return math.min(math.max(n, low), high) end
	local dot = a:dot(b)

	-- http://www.gamedev.net/topic/312067-shortest-slerp-path/#entry2995591
	if dot < 0 then
		a = -a
		dot = -dot
	end

	if dot > constants.DOT_THRESHOLD then
		return quaternion.lerp(a, b, s)
	end

	clamp(dot, -1, 1)
	local theta = math.acos(dot) * s
	local c = (b - a * dot):normalize()

	return a * math.cos(theta) + c * math.sin(theta)
end

-- return quaternion
-- the module
return setmetatable({}, {
	__call = function(_, ...) return quaternion.new(...) end,
	__index = quaternion
})
