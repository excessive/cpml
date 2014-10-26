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

local assert = assert
local sqrt, cos, sin, atan2, acos = math.sqrt, math.cos, math.sin, math.atan2, math.acos

local vector = {}
vector.__index = vector

local function new(x,y,z)
	return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vector)
end
local zero = new(0,0,0)

local function isvector(v)
	return type(v) == 'table' and type(v.x) == 'number' and type(v.y) == 'number' and type(v.z) == 'number'
end

function vector:clone()
	return new(self.x, self.y, self.z)
end

function vector:unpack()
	return self.x, self.y, self.z
end

function vector:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..","..tonumber(self.z)..")"
end

function vector.__unm(a)
	return new(-a.x, -a.y, -a.z)
end

function vector.__add(a,b)
	assert(isvector(a) and isvector(b), "Add: wrong argument types (<vector> expected)")
	return new(a.x+b.x, a.y+b.y, a.z+b.z)
end

function vector.__sub(a,b)
	assert(isvector(a) and isvector(b), "Sub: wrong argument types (<vector> expected)")
	return new(a.x-b.x, a.y-b.y, a.z-b.z)
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
	assert(isvector(a) and type(b) == "number", "wrong argument types (expected <vector> / <number>)")
	return new(a.x / b, a.y / b, a.z / b)
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

function vector.dot(a,b)
	assert(isvector(a) and isvector(b), "dot: wrong argument types (<vector> expected)")
	return a.x*b.x + a.y*b.y + a.z*b.z
end

function vector:tuple()
	return self.x, self.y, self.z
end

function vector:len2()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

function vector:len()
	return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function vector.dist(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt(dx * dx + dy * dy + dz * dz)
end

function vector.dist2(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return (dx * dx + dy * dy + dz * dz)
end

function vector:normalize_inplace()
	local l = self:len()
	if l > 0 then
		self.x, self.y, self.z = self.x / l, self.y / l, self.z / l
	end
	return self
end

function vector:normalize()
	return self:clone():normalize_inplace()
end

function vector:rotated(phi, axis)
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

function vector:projectOn(v)
	assert(isvector(v), "invalid argument: cannot project vector on " .. type(v))
	-- (self * v) * v / v:len2()
	local s = (self.x * v.x + self.y * v.y + self.z * v.z) / (v.x * v.x + v.y * v.y + v.z * v.z)
	return new(s * v.x, s * v.y, s * v.z)
end

function vector:projectFrom(v)
	assert(isvector(v), "invalid argument: cannot project vector on " .. type(v))
	-- Does the reverse of projectOn.
	local s = (v.x * v.x + v.y * v.y + v.z * v.z) / (self.x * v.x + self.y * v.y + self.z * v.z)
	return new(s * v.x, s * v.y, s * v.z)
end

function vector:mirrorOn(v)
	assert(isvector(v), "invalid argument: cannot mirror vector on " .. type(v))
	-- 2 * self:projectOn(v) - self
	local s = 2 * (self.x * v.x + self.y * v.y + self.z * v.z) / (v.x * v.x + v.y * v.y + v.z * v.z)
	return new(s * v.x - self.x, s * v.y - self.y, s * v.z - self.z)
end

function vector:cross(v)
	-- Cross product.
	assert(isvector(v), "cross: wrong argument types (<vector> expected)")
	return new(self.y*v.z - self.z*v.y, self.z*v.x - self.x*v.z, self.x*v.y - self.y*v.x)
	--return self.x * v.y - self.y * v.x
end

-- ref.: http://blog.signalsondisplay.com/?p=336
function vector:trim_inplace(maxLen)
	local s = maxLen * maxLen / self:len2()
	s = (s > 1 and 1) or math.sqrt(s)
	self.x, self.y, self.z = self.x * s, self.y * s, self.z * s
	return self
end

function vector:angleTo(other)
	-- Only makes sense in 2D.
	if other then
		return atan2(self.y, self.x) - atan2(other.y, other.x)
	end
	return atan2(self.y, self.x)
end

function vector:angleBetween(other)
	if other then
		return acos(self*other / (self:len() * other:len()))
	end
	return 0
end

function vector:trimmed(maxLen)
	return self:clone():trim_inplace(maxLen)
end


-- the module
return setmetatable({new = new, isvector = isvector, zero = zero},
{__call = function(_, ...) return new(...) end})
