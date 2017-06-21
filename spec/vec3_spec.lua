local vec3        = require "modules.vec3"
local DBL_EPSILON = require("modules.constants").DBL_EPSILON
local abs, sqrt   = math.abs, math.sqrt

describe("vec3:", function()
	it("creates an empty vector", function()
		local a = vec3()
		assert.is.equal(0, a.x)
		assert.is.equal(0, a.y)
		assert.is.equal(0, a.z)
		assert.is_true(a:is_vec3())
		assert.is_true(a:is_zero())
	end)

	it("creates a vector from a number", function()
		local a = vec3(3)
		assert.is.equal(3, a.x)
		assert.is.equal(3, a.y)
		assert.is.equal(3, a.z)
	end)

	it("creates a vector from numbers", function()
		local a = vec3(3, 5, 7)
		assert.is.equal(3, a.x)
		assert.is.equal(5, a.y)
		assert.is.equal(7, a.z)
	end)

	it("creates a vector from a list", function()
		local a = vec3 { 3, 5, 7 }
		assert.is.equal(3, a.x)
		assert.is.equal(5, a.y)
		assert.is.equal(7, a.z)
	end)

	it("creates a vector from a record", function()
		local a = vec3 { x=3, y=5, z=7 }
		assert.is.equal(3, a.x)
		assert.is.equal(5, a.y)
		assert.is.equal(7, a.z)
	end)

	it("clones a vector", function()
		local a = vec3(3, 5, 7)
		local b = a:clone()
		assert.is.equal(a, b)

		local c = vec3()
		a:clone(c)
		assert.is.equal(a, c)
	end)

	it("adds a vector to another", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local c = a:add(b)
		local d = a + b
		assert.is.equal(10, c.x)
		assert.is.equal(9,  c.y)
		assert.is.equal(8,  c.z)
		assert.is.equal(c,  d)

		local e = vec3()
		a:add(b, e)
		assert.is.equal(c, e)
	end)

	it("subracts a vector from another", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local c = a:sub(b)
		local d = a - b
		assert.is.equal(-4, c.x)
		assert.is.equal( 1, c.y)
		assert.is.equal( 6, c.z)
		assert.is.equal( c, d)

		local e = vec3()
		a:sub(b, e)
		assert.is.equal(c, e)
	end)

	it("multiplies a vector by a scale factor", function()
		local a = vec3(3, 5, 7)
		local s = 2
		local c = a:scale(s)
		local d = a * s
		assert.is.equal(6,  c.x)
		assert.is.equal(10, c.y)
		assert.is.equal(14, c.z)
		assert.is.equal(c,  d)

		local e = vec3()
		a:scale(s, e)
		assert.is.equal(c, e)
	end)

	it("divides a vector by another vector", function()
		local a = vec3(3, 5, 7)
		local s = vec3(2, 2, 2)
		local c = a:div(s)
		local d = a / s
		assert.is.equal(1.5, c.x)
		assert.is.equal(2.5, c.y)
		assert.is.equal(3.5, c.z)
		assert.is.equal(c,   d)

		local e = vec3()
		a:div(s, e)
		assert.is.equal(c, e)
	end)

	it("inverts a vector", function()
		local a = vec3(3, -5, 7)
		local b = -a
		assert.is.equal(-a.x, b.x)
		assert.is.equal(-a.y, b.y)
		assert.is.equal(-a.z, b.z)
	end)

	it("gets the length of a vector", function()
		local a = vec3(3, 5, 7)
		assert.is.equal(sqrt(83), a:len())
		end)

	it("gets the square length of a vector", function()
		local a = vec3(3, 5, 7)
		assert.is.equal(83, a:len2())
	end)

	it("normalizes a vector", function()
		local a = vec3(3, 5, 7)
		local b = a:normalize()
		assert.is_true(abs(b:len()-1) < DBL_EPSILON)

		local c = vec3()
		a:normalize(c)
		assert.is.equal(b, c)
	end)

	it("trims the length of a vector", function()
		local a = vec3(3, 5, 7)
		local b = a:trim(0.5)
		assert.is_true(abs(b:len()-0.5) < DBL_EPSILON)

		local c = vec3()
		a:trim(0.5, c)
		assert.is.equal(b, c)
	end)

	it("gets the distance between two vectors", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local c = a:dist(b)
		assert.is.equal(sqrt(53), c)
	end)

	it("gets the square distance between two vectors", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local c = a:dist2(b)
		assert.is.equal(53, c)
	end)

	it("crosses two vectors", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local c = a:cross(b)
		assert.is.equal(-23, c.x)
		assert.is.equal( 46, c.y)
		assert.is.equal(-23, c.z)

		local d = vec3()
		a:cross(b, d)
		assert.is.equal(c, d)
	end)

	it("dots two vectors", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local c = a:dot(b)
		assert.is.equal(48, c)
	end)

	it("interpolates between two vectors", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local s = 0.1
		local c = a:lerp(b, s)
		assert.is.equal(3.4, c.x)
		assert.is.equal(4.9, c.y)
		assert.is.equal(6.4, c.z)

		local d = vec3()
		a:lerp(b, s, d)
		assert.is.equal(c, d)
	end)

	it("unpacks a vector", function()
		local a       = vec3(3, 5, 7)
		local x, y, z = a:unpack()
		assert.is.equal(3, x)
		assert.is.equal(5, y)
		assert.is.equal(7, z)
	end)

	it("rotates a vector", function()
		local a = vec3(3, 5, 7)
		local b = a:rotate( math.pi, vec3.unit_z)
		local c = b:rotate(-math.pi, vec3.unit_z)
		assert.is_not.equal(a, b)
		assert.is.equal(7, b.z)
		assert.is.equal(a, c)

		local d = vec3()
		b:rotate(-math.pi, vec3.unit_z, d)
		assert.is.equal(c, d)
	end)

	it("cannot rotate a vector without a valis axis", function()
		local a = vec3(3, 5, 7)
		local b = a:rotate(math.pi, 0)
		assert.is_equal(a, b)
	end)

	it("gets a perpendicular vector", function()
		local a = vec3(3, 5, 7)
		local b = a:perpendicular()
		assert.is.equal(-5, b.x)
		assert.is.equal( 3, b.y)
		assert.is.equal( 0, b.z)
	end)

	it("gets a string representation of a vector", function()
		local a = vec3()
		local b = a:to_string()
		assert.is.equal("(+0.000,+0.000,+0.000)", b)
	end)
end)
