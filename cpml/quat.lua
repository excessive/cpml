-- quaternions
-- Author: Andrew Stacey
-- Website: http://www.math.ntnu.no/~stacey/HowDidIDoThat/iPad/Codea.html
-- Licence: CC0 http://wiki.creativecommons.org/CC0

--[[
This is a class for handling quaternion numbers.  It was originally
designed as a way of encoding rotations of 3 dimensional space.
--]]

local Class = require "libs.hump.class"
local quaternion = Class {}
local FLT_EPSILON = 1.19209290e-07

--[[
A quaternion can either be specified by giving the four coordinates as
real numbers or by giving the scalar part and the vector part.
--]]


function quaternion:init(...)
	-- copy
	local arg = {...}
	if #arg == 1 and type(arg[1]) == "table" then
		self.a = arg[1].a
		self.b = arg[1].b
		self.c = arg[1].c
		self.d = arg[1].d
	-- four numbers
	elseif #arg == 4 then
		self.a = arg[1]
		self.b = arg[2]
		self.c = arg[3]
		self.d = arg[4]
	-- real number plus vector
	elseif #arg == 2 then
		self.a = arg[1]
		self.b = arg[2].x
		self.c = arg[2].y
		self.d = arg[2].z
	else
		error("Incorrect number of arguments to quaternion")
	end
end


function quaternion:to_axis_angle()
	local tmp = self
	if tmp.a > 1 then
		tmp = tmp:normalize()
	end
	local angle = 2 * math.acos(tmp.a)
	local s = math.sqrt(1-tmp.a*tmp.a)
	local x, y, z
	if s < FLT_EPSILON then
		x = tmp.b
		y = tmp.c
		z = tmp.d
	else
		x = tmp.b / s -- normalize axis
		y = tmp.c / s
		z = tmp.d / s
	end
	return angle, { x, y, z }
end


--[[
Test if we are zero.
--]]

function quaternion:is_zero()
	-- are we the zero vector
	if self.a ~= 0 or self.b ~= 0 or self.c ~= 0 or self.d ~= 0 then
		return false
	end
	return true
end

--[[
Test if we are real.
--]]

function quaternion:is_real()
	-- are we the zero vector
	if self.b ~= 0 or self.c ~= 0 or self.d ~= 0 then
		return false
	end
	return true
end

--[[
Test if the real part is zero.
--]]

function quaternion:is_imaginary()
	-- are we the zero vector
	if self.a ~= 0 then
		return false
	end
	return true
end

--[[
Test for equality.
--]]

function quaternion:is_eq(q)
	if self.a ~= q.a or self.b ~= q.b or self.c ~= q.c or self.d ~= q.d then
		return false
	end
	return true
end

--[[
Defines the "==" shortcut.
--]]

function quaternion:__eq(q)
	return self:is_eq(q)
end

--[[
The inner product of two quaternions.
--]]

function quaternion:dot(q)
	return self.a * q.a + self.b * q.b + self.c * q.c + self.d * q.d
end

--[[
Makes "q .. p" return the inner product.

Probably a bad choice and likely to be removed in future versions.
--]]

function quaternion:__concat(q)
	return self:dot(q)
end

--[[
Length of a quaternion.
--]]

function quaternion:len()
	return math.sqrt(self:lensq())
end

--[[
Often enough to know the length squared, which is quicker.
--]]

function quaternion:lensq()
	return self.a * self.a + self.b * self.b + self.c * self.c + self.d * self.d
end

--[[
Normalize a quaternion to have length 1, if possible.
--]]

function quaternion:normalize()
	if self:is_zero() then
		error("Unable to normalize a zero-length quaternion")
		return false
	end
	local l = 1/self:len()
	return self:scale(l)
end

--[[
Scale the quaternion.
--]]

function quaternion:scale(l)
	return quaternion(self.a * l,self.b * l,self.c * l, self.d * l)
end

--[[
Add two quaternions.  Or add a real number to a quaternion.
--]]

function quaternion:add(q)
	if type(q) == "number" then
		return quaternion(self.a + q, self.b, self.c, self.d)
	else
		return quaternion(self.a + q.a, self.b + q.b, self.c + q.c, self.d + q.d)
	end
end

--[[
q + p
--]]

function quaternion:__add(q)
	return self:add(q)
end

--[[
Subtraction
--]]

function quaternion:subtract(q)
	return quaternion(self.a - q.a, self.b - q.b, self.c - q.c, self.d - q.d)
end

--[[
q - p
--]]

function quaternion:__sub(q)
	return self:subtract(q)
end

--[[
Negation (-q)
--]]

function quaternion:__unm()
	return self:scale(-1)
end

--[[
Length (#q)
--]]

function quaternion:__len()
	return self:len()
end

--[[
Multiply the current quaternion on the right.

Corresponds to composition of rotations.
--]]

function quaternion:multiplyRight(q)
	local a,b,c,d
	a = self.a * q.a - self.b * q.b - self.c * q.c - self.d * q.d
	b = self.a * q.b + self.b * q.a + self.c * q.d - self.d * q.c
	c = self.a * q.c - self.b * q.d + self.c * q.a + self.d * q.b
	d = self.a * q.d + self.b * q.c - self.c * q.b + self.d * q.a
	return quaternion(a,b,c,d)
end

--[[
q * p
--]]

function quaternion:__mul(q)
	if type(q) == "number" then
		return self:scale(q)
	elseif type(q) == "table" then
		return self:multiplyRight(q)
	end
end

--[[
Multiply the current quaternion on the left.

Corresponds to composition of rotations.
--]]

function quaternion:multiplyLeft(q)
	return q:multiplyRight(self)
end

--[[
Conjugation (corresponds to inverting a rotation).
--]]

function quaternion:conjugate()
	return quaternion(self.a, - self.b, - self.c, - self.d)
end

function quaternion:co()
	return self:conjugate()
end

--[[
Reciprocal: 1/q
--]]

function quaternion:reciprocal()
	if self.is_zero() then
		error("Cannot reciprocate a zero quaternion")
		return false
	end
	local q = self:conjugate()
	local l = self:lensq()
	q = q:scale(1/l)
	return q
end

--[[
Integral powers.
--]]

function quaternion:power(n)
	if n ~= math.floor(n) then
		error("Only able to do integer powers")
		return false
	end
	if n == 0 then
		return quaternion(1,0,0,0)
	elseif n > 0 then
		return self:multiplyRight(self:power(n-1))
	elseif n < 0 then
		return self:reciprocal():power(-n)
	end
end

--[[
q^n

This is overloaded so that a non-number exponent returns the
conjugate.  This means that one can write things like q^* or q^"" to
get the conjugate of a quaternion.
--]]

function quaternion:__pow(n)
	if type(n) == "number" then
		return self:power(n)
	else
		return self:conjugate()
	end
end

--[[
Division: q/p
--]]

function quaternion:__div(q)
	if type(q) == "number" then
		return self:scale(1/q)
	elseif type(q) == "table" then
		return self:multiplyRight(q:reciprocal())
	end
end

--[[
Returns the real part.
--]]

function quaternion:real()
	return self.a
end

--[[
Returns the vector (imaginary) part as a Vec3 object.
--]]

function quaternion:vector()
	return Vec3(self.b, self.c, self.d)
end

--[[
Represents a quaternion as a string.
--]]

function quaternion:__tostring()
	local s
	local im ={{self.b,"i"},{self.c,"j"},{self.d,"k"}}
	if self.a ~= 0 then
		s = self.a
	end
	for k,v in pairs(im) do
	if v[1] ~= 0 then
		if s then 
			if v[1] > 0 then
				if v[1] == 1 then
					s = s .. " + " .. v[2]
				else
					s = s .. " + " .. v[1] .. v[2]
				end
			else
				if v[1] == -1 then
					s = s .. " - " .. v[2]
				else
					s = s .. " - " .. (-v[1]) .. v[2]
				end
				end
		else
			if v[1] == 1 then
				s = v[2]
			elseif v[1] == - 1 then
				s = "-" .. v[2]
			else
				s = v[1] .. v[2]
			end
		end
	end
	end
	if s then
		return s
	else
		return "0"
	end
end

--[[
(Not a class function)

Returns a quaternion corresponding to the current gravitational vector
so that after applying the corresponding rotation, the y-axis points
in the gravitational direction and the x-axis is in the plane of the
iPad screen.

When we have access to the compass, the x-axis behaviour might change.
--]]

--[[
function quaternion.gravity()
	local gxy, gy, gygxy, a, b, c, d
	if Gravity.x == 0 and Gravity.y == 0 then
		return quaternion(1,0,0,0)
	else
		gy = - Gravity.y
		gxy = math.sqrt(math.pow(Gravity.x,2) + math.pow(Gravity.y,2))
		gygxy = gy/gxy
		a = math.sqrt(1 + gxy - gygxy - gy)/2
		b = math.sqrt(1 - gxy - gygxy + gy)/2
		c = math.sqrt(1 - gxy + gygxy - gy)/2
		d = math.sqrt(1 + gxy + gygxy + gy)/2
		if Gravity.y > 0 then
			a = a
			b = b
		end
		if Gravity.z < 0 then
			b = - b
			c = - c
		end
		if Gravity.x > 0 then
			c = - c
			d = - d
		end
		return quaternion(a,b,c,d)
	end
end
--]]

--[[
Converts a rotation to a quaternion.  The first argument is the angle
to rotate, the rest must specify an axis, either as a Vec3 object or
as three numbers.
--]]

function quaternion.rotation(a,...)
	local q,c,s
	q = quaternion(0,...)
	q = q:normalize()
	c = math.cos(a/2)
	s = math.sin(a/2)
	q = q:scale(s)
	q = q:add(c)
	return q
end

function quaternion:to_euler()
	local sqw = self.a*self.a
	local sqx = self.b*self.b
	local sqy = self.c*self.c
	local sqz = self.d*self.d

	 -- if normalised is one, otherwise is correction factor
	local unit = sqx + sqy + sqz + sqw
	local test = self.b*self.c + self.d*self.a

	local pitch, yaw, roll

	 -- singularity at north pole
	if test > 0.499*unit then
		yaw = 2 * math.atan2(self.b,self.a)
		pitch = math.pi/2
		roll = 0
		return pitch, yaw, roll
	end

	 -- singularity at south pole
	if test < -0.499*unit then
		yaw = -2 * math.atan2(self.b,self.a)
		pitch = -math.pi/2
		roll = 0
		return pitch, yaw, roll
	end
	yaw = math.atan2(2*self.c*self.a-2*self.b*self.d , sqx - sqy - sqz + sqw)
	pitch = math.asin(2*test/unit)
	roll = math.atan2(2*self.b*self.a-2*self.c*self.d , -sqx + sqy - sqz + sqw)

	return pitch, roll, yaw
end

--[[
The unit quaternion.
--]]

function quaternion.unit()
	return quaternion(1,0,0,0)
end

return quaternion
