-- quaternions
-- Author: Andrew Stacey
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

--[[
A quaternion can either be specified by giving the four coordinates as
real numbers or by giving the scalar part and the vector part.
--]]

local function new(...)
	local x, y, z, w
	-- copy
	local arg = {...}
	if #arg == 1 and type(arg[1]) == "table" then
		x = arg[1].x
		y = arg[1].y
		z = arg[1].z
		w = arg[1].w
	-- four numbers
	elseif #arg == 4 then
		x = arg[1]
		y = arg[2]
		z = arg[3]
		w = arg[4]
	-- real number plus vector
	elseif #arg == 2 then
		x = arg[1].x or arg[1][1]
		y = arg[1].y or arg[1][2]
		z = arg[1].z or arg[1][3]
		w = arg[2]
	else
		error("Incorrect number of arguments to quaternion")
	end

	return setmetatable({ x = x or 0, y = y or 0, z = z or 0, w = w or 0 }, quaternion)
end

function quaternion:__add(q)
	if type(q) == "number" then
		return new(self.x, self.y, self.z, self.w + q)
	else
		return new(self.x + q.x, self.y + q.y, self.z + q.z, self.w + q.w)
	end
end

function quaternion:__sub(q)
	return new(self.x - q.x, self.y - q.y, self.z - q.z, self.w - q.w)
end

function quaternion:__unm()
	return self:scale(-1)
end

function quaternion:__mul(q)
	if type(q) == "number" then
		return self:scale(q)
	elseif type(q) == "table" then
		local x,y,z,w
		x = self.w * q.x + self.x * q.w + self.y * q.z - self.z * q.y
		y = self.w * q.y - self.x * q.z + self.y * q.w + self.z * q.x
		z = self.w * q.z + self.x * q.y - self.y * q.x + self.z * q.w
		w = self.w * q.w - self.x * q.x - self.y * q.y - self.z * q.z
		return new(x,y,z,w)
	end
end

function quaternion:__div(q)
	if type(q) == "number" then
		return self:scale(1/q)
	elseif type(q) == "table" then
		return self * q:reciprocal()
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

function quaternion:__eq(q)
	if self.x ~= q.x or self.y ~= q.y or self.z ~= q.z or self.w ~= q.w then
		return false
	end
	return true
end

function quaternion:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..","..tonumber(self.z)..","..tonumber(self.w)..")"
end

function quaternion.unit()
	return new(0,0,0,1)
end

function quaternion:to_axis_angle()
	local tmp = self
	if tmp.w > 1 then
		tmp = tmp:normalize()
	end
	local angle = 2 * math.acos(tmp.w)
	local s = math.sqrt(1-tmp.w*tmp.w)
	local x, y, z
	if s < constants.FLT_EPSILON then
		x = tmp.x
		y = tmp.y
		z = tmp.z
	else
		x = tmp.x / s -- normalize axis
		y = tmp.y / s
		z = tmp.z / s
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

-- Length of a quaternion
function quaternion:len()
	return math.sqrt(self:len2())
end

-- Length squared of a quaternion
function quaternion:len2()
	return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

-- Normalize a quaternion to have length 1
function quaternion:normalize()
	if self:is_zero() then
		error("Unable to normalize a zero-length quaternion")
		return false
	end
	local l = 1/self:len()
	return self:scale(l)
end

-- Scale the quaternion
function quaternion:scale(l)
	return new(self.x * l,self.y * l,self.z * l, self.w * l)
end

-- Conjugation (corresponds to inverting a rotation)
function quaternion:conjugate()
	return new(-self.x, -self.y, -self.z, self.w)
end

-- Reciprocal: 1/q
function quaternion:reciprocal()
	if self.is_zero() then
		error("Cannot reciprocate a zero quaternion")
		return false
	end
	local q = self:conjugate()
	local l = self:len2()
	q = q:scale(1/l)
	return q
end

-- Returns the real part
function quaternion:real()
	return self.w
end

function quaternion:clone()
	return new(self.x, self.y, self.z, self.w)
end

-- Returns the vector (imaginary) part as a Vec3 object
function quaternion:to_vec3()
	return vec3(self.x, self.y, self.z)
end

--[[
Converts a rotation to a quaternion. The first argument is the angle
to rotate, the second must specify an axis as a Vec3 object.
--]]

function quaternion:rotate(a,axis)
	local q,c,s
	q = new(axis, 0)
	q = q:normalize()
	c = math.cos(a)
	s = math.sin(a)
	q = q:scale(s)
	q = q + c
	return q
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
	yaw = math.atan2(2*self.y*self.w-2*self.x*self.z , sqx - sqy - sqz + sqw)
	pitch = math.asin(2*test/unit)
	roll = math.atan2(2*self.x*self.w-2*self.y*self.z , -sqx + sqy - sqz + sqw)

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
return setmetatable({ new = new },
{ __call = function(_, ...) return new(...) end })
