local quat  = require "modules.quat"
local vec3  = require "modules.vec3"
local utils = require "modules.utils"
local constants = require "modules.constants"

describe("quat:", function()
	it("creates an identity quaternion", function()
		local a = quat()
		assert.is.equal(0, a.x)
		assert.is.equal(0, a.y)
		assert.is.equal(0, a.z)
		assert.is.equal(1, a.w)
		assert.is_true(a:is_quat())
		assert.is_true(a:is_real())
	end)

	it("creates a quaternion from numbers", function()
		local a = quat(0, 0, 0, 0)
		assert.is.equal(0, a.x)
		assert.is.equal(0, a.y)
		assert.is.equal(0, a.z)
		assert.is.equal(0, a.w)
		assert.is_true(a:is_zero())
		assert.is_true(a:is_imaginary())
	end)

	it("creates a quaternion from a list", function()
		local a = quat { 2, 3, 4, 1 }
		assert.is.equal(2, a.x)
		assert.is.equal(3, a.y)
		assert.is.equal(4, a.z)
		assert.is.equal(1, a.w)
	end)

	it("creates a quaternion from a record", function()
		local a = quat { x=2, y=3, z=4, w=1 }
		assert.is.equal(2, a.x)
		assert.is.equal(3, a.y)
		assert.is.equal(4, a.z)
		assert.is.equal(1, a.w)
	end)

	it("creates a quaternion from a quaternion", function()
		local a = quat (quat(2, 3, 4, 1))
		assert.is.equal(2, a.x)
		assert.is.equal(3, a.y)
		assert.is.equal(4, a.z)
		assert.is.equal(1, a.w)
	end)

	it("creates a quaternion from a direction", function()
		local v = vec3(-80, 80, -80):normalize()
		local a = quat.from_direction(v, vec3.unit_z)
		assert.is_true(utils.tolerance(-0.577-a.x, 0.001))
		assert.is_true(utils.tolerance(-0.577-a.y, 0.001))
		assert.is_true(utils.tolerance( 0    -a.z, 0.001))
		assert.is_true(utils.tolerance( 0.423-a.w, 0.001))
	end)

	it("clones a quaternion", function()
		local a = quat()
		local b = a:clone()
		assert.is.equal(a.x, b.x)
		assert.is.equal(a.y, b.y)
		assert.is.equal(a.z, b.z)
		assert.is.equal(a.w, b.w)
	end)

	it("adds a quaternion to another", function()
		local a = quat(2, 3, 4, 1)
		local b = quat(3, 6, 9, 1)
		local c = a:add(b)
		local d = a + b
		assert.is.equal(5,  c.x)
		assert.is.equal(9,  c.y)
		assert.is.equal(13, c.z)
		assert.is.equal(2,  c.w)
		assert.is.equal(c,  d)
	end)

	it("subtracts a quaternion from another", function()
		local a = quat(2, 3, 4, 1)
		local b = quat(3, 6, 9, 1)
		local c = a:sub(b)
		local d = a - b
		assert.is.equal(-1, c.x)
		assert.is.equal(-3, c.y)
		assert.is.equal(-5, c.z)
		assert.is.equal( 0, c.w)
		assert.is.equal(c,  d)
	end)

	it("multiplies a quaternion by another", function()
		local a = quat(2, 3, 4, 1)
		local b = quat(3, 6, 9, 1)
		local c = a:mul(b)
		local d = a * b
		assert.is.equal( 8,  c.x)
		assert.is.equal( 3,  c.y)
		assert.is.equal( 16, c.z)
		assert.is.equal(-59, c.w)
		assert.is.equal(c,   d)
	end)

	it("multiplies a quaternion by a scale factor", function()
		local a = quat(2, 3, 4, 1)
		local s = 3
		local b = a:scale(s)
		local c = a * s
		assert.is.equal(6,  b.x)
		assert.is.equal(9,  b.y)
		assert.is.equal(12, b.z)
		assert.is.equal(3,  b.w)
		assert.is.equal(b,  c)
	end)

	it("inverts a quaternion", function()
		local a = quat(2, 3, 4, 1)
		local b = -a
		assert.is.equal(-a.x, b.x)
		assert.is.equal(-a.y, b.y)
		assert.is.equal(-a.z, b.z)
		assert.is.equal(-a.w, b.w)
	end)

	it("multiplies a quaternion by a vec3", function()
		local a = quat(2, 3, 4, 1)
		local v = vec3(3, 4, 5)
		local b = a:mul_vec3(v)
		local c = a * v
		assert.is.equal(-21, c.x)
		assert.is.equal( 4,  c.y)
		assert.is.equal( 17, c.z)
		assert.is.equal(b, c)
	end)

	it("verifies quat composition order", function()
		local a = quat(2, 3, 4, 1):normalize() -- Only the normal quaternions represent rotations
		local b = quat(3, 6, 9, 1):normalize()
		local c = a * b

		local v = vec3(3, 4, 5)

		local cv = c * v
		local abv = a * (b * v)

		assert.is_true((abv - cv):len() < 1e-07) -- Verify (a*b)*v == a*(b*v) within an epsilon
	end)

	it("multiplies a quaternion by an exponent of 0", function()
		local a = quat(2, 3, 4, 1):normalize()
		local e = 0
		local b = a:pow(e)
		local c = a^e

		assert.is.equal(0, b.x)
		assert.is.equal(0, b.y)
		assert.is.equal(0, b.z)
		assert.is.equal(1, b.w)
		assert.is.equal(b, c)
	end)

	it("multiplies a quaternion by a positive exponent", function()
		local a = quat(2, 3, 4, 1):normalize()
		local e = 0.75
		local b = a:pow(e)
		local c = a^e

		assert.is_true(utils.tolerance(-0.3204+b.x, 0.0001))
		assert.is_true(utils.tolerance(-0.4805+b.y, 0.0001))
		assert.is_true(utils.tolerance(-0.6407+b.z, 0.0001))
		assert.is_true(utils.tolerance(-0.5059+b.w, 0.0001))
		assert.is.equal( b,  c)
	end)

	it("multiplies a quaternion by a negative exponent", function()
		local a = quat(2, 3, 4, 1):normalize()
		local e = -1
		local b = a:pow(e)
		local c = a^e

		assert.is_true(utils.tolerance( 0.3651+b.x, 0.0001))
		assert.is_true(utils.tolerance( 0.5477+b.y, 0.0001))
		assert.is_true(utils.tolerance( 0.7303+b.z, 0.0001))
		assert.is_true(utils.tolerance(-0.1826+b.w, 0.0001))
		assert.is.equal(b, c)
	end)

	it("inverts a quaternion", function()
		local a = quat(1, 1, 1, 1):inverse()
		assert.is.equal(-0.5, a.x)
		assert.is.equal(-0.5, a.y)
		assert.is.equal(-0.5, a.z)
		assert.is.equal( 0.5, a.w)
	end)

	it("normalizes a quaternion", function()
		local a = quat(1, 1, 1, 1):normalize()
		assert.is.equal(0.5, a.x)
		assert.is.equal(0.5, a.y)
		assert.is.equal(0.5, a.z)
		assert.is.equal(0.5, a.w)
	end)

	it("dots two quaternions", function()
		local a = quat(1, 1, 1, 1)
		local b = quat(4, 4, 4, 4)
		local c = a:dot(b)
		assert.is.equal(16, c)
	end)

	it("dots two quaternions (negative)", function()
		local a = quat(-1, 1, 1, 1)
		local b = quat(4, 4, 4, 4)
		local c = a:dot(b)
		assert.is.equal(8, c)
	end)

	it("dots two quaternions (tiny)", function()
		local a = quat(0.1, 0.1, 0.1, 0.1)
		local b = quat(0.4, 0.4, 0.4, 0.4)
		local c = a:dot(b)
		assert.is_true(utils.tolerance(0.16-c, 0.001))
	end)

	it("gets the length of a quaternion", function()
		local a = quat(2, 3, 4, 5):len()
		assert.is.equal(math.sqrt(54), a)
	end)

	it("gets the square length of a quaternion", function()
		local a = quat(2, 3, 4, 5):len2()
		assert.is.equal(54, a)
	end)

	it("interpolates between two quaternions", function()
		local a = quat(3, 3, 3, 3)
		local b = quat(6, 6, 6, 6)
		local s = 0.1
		local c = a:lerp(b, s)
		assert.is.equal(0.5, c.x)
		assert.is.equal(0.5, c.y)
		assert.is.equal(0.5, c.z)
		assert.is.equal(0.5, c.w)
	end)

	it("interpolates between two quaternions (spherical)", function()
		local a = quat(3, 3, 3, 3)
		local b = quat(6, 6, 6, 6)
		local s = 0.1
		local c = a:slerp(b, s)
		assert.is.equal(0.5, c.x)
		assert.is.equal(0.5, c.y)
		assert.is.equal(0.5, c.z)
		assert.is.equal(0.5, c.w)
	end)

	it("unpacks a quaternion", function()
		local x, y, z, w = quat(2, 3, 4, 1):unpack()
		assert.is.equal(2, x)
		assert.is.equal(3, y)
		assert.is.equal(4, z)
		assert.is.equal(1, w)
	end)

	it("converts quaternion to a vec3", function()
		local v = quat(2, 3, 4, 1):to_vec3()
		assert.is.equal(2, v.x)
		assert.is.equal(3, v.y)
		assert.is.equal(4, v.z)
	end)

	it("gets the conjugate quaternion", function()
		local a = quat(2, 3, 4, 1):conjugate()
		assert.is.equal(-2, a.x)
		assert.is.equal(-3, a.y)
		assert.is.equal(-4, a.z)
		assert.is.equal( 1, a.w)
	end)

	it("gets the reciprocal quaternion", function()
		local a = quat(1, 1, 1, 1)
		local b = a:reciprocal()
		local c = b:reciprocal()

		assert.is_not.equal(a.x, b.x)
		assert.is_not.equal(a.y, b.y)
		assert.is_not.equal(a.z, b.z)
		assert.is_not.equal(a.w, b.w)

		assert.is.equal(a.x, c.x)
		assert.is.equal(a.y, c.y)
		assert.is.equal(a.z, c.z)
		assert.is.equal(a.w, c.w)
	end)

	it("converts between a quaternion and angle/axis", function()
		local a = quat.from_angle_axis(math.pi, vec3.unit_z)
		local angle, axis = a:to_angle_axis()
		assert.is.equal(math.pi,     angle)
		assert.is.equal(vec3.unit_z, axis)
	end)

	it("converts between a quaternion and angle/axis (specify by component)", function()
		local a = quat.from_angle_axis(math.pi, vec3.unit_z.x, vec3.unit_z.y, vec3.unit_z.z)
		local angle, axis = a:to_angle_axis()
		assert.is.equal(math.pi,     angle)
		assert.is.equal(vec3.unit_z, axis)
	end)

	it("converts between a quaternion and angle/axis (w=2)", function()
		local angle, axis = quat(1, 1, 1, 2):to_angle_axis()
		assert.is_true(utils.tolerance(1.427-angle,  0.001))
		assert.is_true(utils.tolerance(0.577-axis.x, 0.001))
		assert.is_true(utils.tolerance(0.577-axis.y, 0.001))
		assert.is_true(utils.tolerance(0.577-axis.z, 0.001))
	end)

	it("converts between a quaternion and angle/axis (w=2) (by component)", function()
		local angle, x,y,z = quat(1, 1, 1, 2):to_angle_axis_unpack()
		assert.is_true(utils.tolerance(1.427-angle,  0.001))
		assert.is_true(utils.tolerance(0.577-x, 0.001))
		assert.is_true(utils.tolerance(0.577-y, 0.001))
		assert.is_true(utils.tolerance(0.577-z, 0.001))
	end)

	it("converts between a quaternion and angle/axis (w=1)", function()
		local angle, axis = quat(1, 2, 3, 1):to_angle_axis()
		assert.is.equal(0, angle)
		assert.is.equal(1, axis.x)
		assert.is.equal(2, axis.y)
		assert.is.equal(3, axis.z)
	end)

	it("converts between a quaternion and angle/axis (identity quaternion) (by component)", function()
		local angle, x,y,z = quat():to_angle_axis_unpack()
		assert.is.equal(0, angle)
		assert.is.equal(0, x)
		assert.is.equal(0, y)
		assert.is.equal(1, z)
	end)

	it("converts between a quaternion and angle/axis (identity quaternion with fallback)", function()
		local angle, axis = quat():to_angle_axis(vec3(2,3,4))
		assert.is.equal(0, angle)
		assert.is.equal(2, axis.x)
		assert.is.equal(3, axis.y)
		assert.is.equal(4, axis.z)
	end)

	it("gets a string representation of a quaternion", function()
		local a = quat():to_string()
		assert.is.equal("(+0.000,+0.000,+0.000,+1.000)", a)
	end)
end)
