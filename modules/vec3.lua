--[[
Copyright (c) 2010-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

-- Modified to include 3D capabilities by Bill Shillito, April 2014
-- Various bug fixes by Colby Klein, October 2014

--- 3 dimensional vectors.
-- @module vec3
-- @alias vector

local assert = assert
local sqrt, cos, sin, atan2, acos = math.sqrt, math.cos, math.sin, math.atan2, math.acos

local vector = {}
vector.__index = vector

--- Instance a new vec3.
-- @param x X value, table containing 3 elements, or another vector.
-- @param y Y value
-- @param z Z value
-- @return vec3
local function new(x,y,z)
	-- allow construction via vec3(a, b, c), vec3 { a, b, c } or vec3 { x = a, y = b, z = c }
	if type(x) == "table" then
		return setmetatable({x=x.x or x[1] or 0, y=x.y or x[2] or 0, z=x.z or x[3] or 0}, vector)
	end
	return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vector)
end

local function isvector(v)
	return getmetatable(v) == vector or type(v.x and v.y and v.z) == "number"
end

local zero = new(0,0,0)
local unit_x = new(1,0,0)
local unit_y = new(0,1,0)
local unit_z = new(0,0,1)

--- Create a new vector containing the same data.
-- @return vec3
function vector:clone()
	return new(self.x, self.y, self.z)
end

--- Unpack the vector into its components.
-- @return number
-- @return number
-- @return number
function vector:unpack()
	return self.x, self.y, self.z
end

function vector:__tostring()
	return string.format("(%+0.3f,%+0.3f,%+0.3f)", self.x, self.y, self.z)
end

function vector.__unm(a)
	return new(-a.x, -a.y, -a.z)
end

function vector.__add(a,b)
	if type(a) == "number" then
		return new(a+b.x, a+b.y, a+b.z)
	elseif type(b) == "number" then
		return new(a.x+b, a.y+b, a.z+b)
	else
		assert(isvector(a) and isvector(b), "Add: wrong argument types (<vector> expected)")
		return new(a.x+b.x, a.y+b.y, a.z+b.z)
	end
end

function vector.__sub(a,b)
	if type(a) == "number" then
		return new(a-b.x, a-b.y, a-b.z)
	elseif type(b) == "number" then
		return new(a.x-b, a.y-b, a.z-b)
	else
		assert(isvector(a) and isvector(b), "Sub: wrong argument types (<vector> expected)")
		return new(a.x-b.x, a.y-b.y, a.z-b.z)
	end
end

function vector.__mul(a,b)
	if type(a) == "number" then
		return new(a*b.x, a*b.y, a*b.z)
	elseif type(b) == "number" then
		return new(b*a.x, b*a.y, b*a.z)
	else
		assert(isvector(a) and isvector(b), "Mul: wrong argument types (<vector> or <number> expected)")
		return new(a.x*b.x, a.y*b.y, a.z*b.z)
	end
end

function vector.__div(a,b)
	if type(a) == "number" then
		return new(a / b.x, a / b.y, a / b.z)
	elseif type(b) == "number" then
		return new(a.x / b, a.y / b, a.z / b)
	else
		assert(isvector(a) and isvector(b), "Div: wrong argument types (<vector> or <number> expected)")
		return new(a.x/b.x, a.y/b.y, a.z/b.z)
	end
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

--- Dot product.
-- @param a first vec3 to dot with
-- @param b second vec3 to dot with
-- @return number
function vector.dot(a,b)
	assert(isvector(a) and isvector(b), "dot: wrong argument types (<vector> expected)")
	return a.x*b.x + a.y*b.y + a.z*b.z
end

function vector:len2()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

--- Vector length/magnitude.
-- @return number
function vector:len()
	return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

--- Distance between two points.
-- @param a first point
-- @param b second point
-- @return number
function vector.dist(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt(dx * dx + dy * dy + dz * dz)
end

--- Squared distance between two points.
-- @param a first point
-- @param b second point
-- @return number
function vector.dist2(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return (dx * dx + dy * dy + dz * dz)
end

--- Normalize vector.
-- Scales the vector in place such that its length is 1.
-- @return vec3
function vector:normalize_inplace()
	local l = self:len()
	if l > 0 then
		self.x, self.y, self.z = self.x / l, self.y / l, self.z / l
	end
	return self
end

--- Normalize vector.
-- Returns a copy of the vector scaled such that its length is 1.
-- @return vec3
function vector:normalize()
	return self:clone():normalize_inplace()
end

--- Rotate vector about an axis.
-- @param phi Amount to rotate, in radians
-- @param axis Axis to rotate by
-- @return vec3
function vector:rotate(phi, axis)
	if axis == nil then return self end

	local u = axis:normalize() or Vector(0,0,1) -- default is to rotate in the xy plane
	local c, s = cos(phi), sin(phi)

	-- Calculate generalized rotation matrix
	local m1 = new((c + u.x * u.x * (1-c)),       (u.x * u.y * (1-c) - u.z * s), (u.x * u.z * (1-c) + u.y * s))
	local m2 = new((u.y * u.x * (1-c) + u.z * s), (c + u.y * u.y * (1-c)),       (u.y * u.z * (1-c) - u.x * s))
	local m3 = new((u.z * u.x * (1-c) - u.y * s), (u.z * u.y * (1-c) + u.x * s), (c + u.z * u.z * (1-c))      )

	-- Return rotated vector
	return new( m1:dot(self), m2:dot(self), m3:dot(self) )
end

function vector:rotate_inplace(phi, axis)
	self = self:rotated(phi, axis)
end

function vector:perpendicular()
	return new(-self.y, self.x, 0)
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
	local s = 2 * (self.x * v.x + self.y * v.y + self.z * v.z) / (v.x * v.x + v.y * v.y + v.z * v.z)
	return new(s * v.x - self.x, s * v.y - self.y, s * v.z - self.z)
end

--- Cross product.
-- @param v vec3 to cross with
-- @return vec3
function vector:cross(v)
	assert(isvector(v), "cross: wrong argument types (<vector> expected)")
	return new(self.y*v.z - self.z*v.y, self.z*v.x - self.x*v.z, self.x*v.y - self.y*v.x)
end

-- @return vec3
function vector:trim_inplace(maxLen)
	-- ref.: http://blog.signalsondisplay.com/?p=336
	local s = maxLen * maxLen / self:len2()
	s = (s > 1 and 1) or math.sqrt(s)
	self.x, self.y, self.z = self.x * s, self.y * s, self.z * s
	return self
end

-- @return vec3
function vector:trim(maxLen)
	return self:clone():trim_inplace(maxLen)
end

-- @return number
function vector:angle_to(other)
	-- Only makes sense in 2D.
	if other then
		return atan2(self.y-other.y, self.x-other.x)
	end
	return atan2(self.y, self.x)
end

-- @return number
function vector:angle_between(other)
	if other then
		return acos(self:dot(other) / (self:len() * other:len()))
	end
	return 0
end

-- @return vec3
function vector:orientation_to_direction(orientation)
	orientation = orientation or new(0, 1, 0)
	return orientation
		:rotated(self.z, unit_z)
		:rotated(self.y, unit_y)
		:rotated(self.x, unit_x)
end

-- http://keithmaggio.wordpress.com/2011/02/15/math-magician-lerp-slerp-and-nlerp/
function vector.lerp(a, b, s)
	return a + s * (b - a)
end

-- the module
return setmetatable(
	{
		new      = new,
		lerp     = lerp,
		isvector = isvector,
		zero     = zero,
		unit_x   = unit_x,
		unit_y   = unit_y,
		unit_z   = unit_z
	}, {
		__call = function(_, ...) return new(...) end
	}
)
