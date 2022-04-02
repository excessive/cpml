local vec2        = require "modules.vec2"
local DBL_EPSILON = require("modules.constants").DBL_EPSILON
local abs, sqrt   = math.abs, math.sqrt

describe("vec2:", function()
	it("creates an empty vector", function()
		local a = vec2()
		assert.is.equal(0, a.x)
		assert.is.equal(0, a.y)
		assert.is_true(a:is_vec2())
		assert.is_true(a:is_zero())
	end)

	it("creates a vector from a number", function()
		local a = vec2(3)
		assert.is.equal(3, a.x)
		assert.is.equal(3, a.y)
	end)

	it("creates a vector from numbers", function()
		local a = vec2(3, 5)
		assert.is.equal(3, a.x)
		assert.is.equal(5, a.y)
	end)

	it("creates a vector from a list", function()
		local a = vec2 { 3, 5 }
		assert.is.equal(3, a.x)
		assert.is.equal(5, a.y)
	end)

	it("creates a vector from a record", function()
		local a = vec2 { x=3, y=5 }
		assert.is.equal(3, a.x)
		assert.is.equal(5, a.y)
	end)

	it("creates a vector from nan", function()
		local a = vec2(0/0)
		assert.is_true(a:has_nan())
	end)

	it("clones a vector", function()
		local a = vec2(3, 5)
		local b = a:clone()
		assert.is.equal(a, b)
	end)

	it("clones a vector using the constructor", function()
		local a = vec2(3, 5)
		local b = vec2(a)
		assert.is.equal(a, b)
	end)

	it("adds a vector to another", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local c = a:add(b)
		local d = a + b
		assert.is.equal(10, c.x)
		assert.is.equal(9,  c.y)
		assert.is.equal(c,  d)
	end)

	it("subracts a vector from another", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local c = a:sub(b)
		local d = a - b
		assert.is.equal(-4, c.x)
		assert.is.equal( 1, c.y)
		assert.is.equal( c, d)
	end)

	it("multiplies a vector by a scale factor", function()
		local a = vec2(3, 5)
		local s = 2
		local c = a:scale(s)
		local d = a * s
		assert.is.equal(6,  c.x)
		assert.is.equal(10, c.y)
		assert.is.equal(c,  d)
	end)

	it("divides a vector by another vector", function()
		local a = vec2(3, 5)
		local s = vec2(2, 2)
		local c = a:div(s)
		local d = a / s
		assert.is.equal(1.5, c.x)
		assert.is.equal(2.5, c.y)
		assert.is.equal(c,   d)
	end)

	it("inverts a vector", function()
		local a = vec2(3, -5)
		local b = -a
		assert.is.equal(-a.x, b.x)
		assert.is.equal(-a.y, b.y)
	end)

	it("gets the length of a vector", function()
		local a = vec2(3, 5)
		assert.is.equal(sqrt(34), a:len())
		end)

	it("gets the square length of a vector", function()
		local a = vec2(3, 5)
		assert.is.equal(34, a:len2())
	end)

	it("normalizes a vector", function()
		local a = vec2(3, 5)
		local b = a:normalized()
		assert.is_true(abs(b:len()-1) < DBL_EPSILON)
		end)

	it("trims the length of a vector", function()
		local a = vec2(3, 5)
		local b = a:trim(0.5)
		assert.is_true(abs(b:len()-0.5) < DBL_EPSILON)
	end)

	it("gets the distance between two vectors", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local c = a:dist(b)
		assert.is.equal(sqrt(17), c)
	end)

	it("gets the square distance between two vectors", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local c = a:dist2(b)
		assert.is.equal(17, c)
	end)

	it("crosses two vectors", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local c = a:cross(b)
		assert.is.equal(-23, c)
	end)

	it("dots two vectors", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local c = a:dot(b)
		assert.is.equal(41, c)
	end)

	it("interpolates between two vectors", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local s = 0.1
		local c = a:lerp(b, s)
		assert.is.equal(3.4, c.x)
		assert.is.equal(4.9, c.y)
	end)

	it("unpacks a vector", function()
		local a    = vec2(3, 5)
		local x, y = a:unpack()
		assert.is.equal(3, x)
		assert.is.equal(5, y)
	end)

	it("rotates a vector", function()
		local a = vec2(3, 5)
		local b = a:rotate( math.pi)
		local c = b:rotate(-math.pi)
		assert.is_not.equal(a, b)
		assert.is.equal(a, c)
	end)

	it("converts between polar and cartesian coordinates", function()
		local a    = vec2(3, 5)
		local r, t = a:to_polar()
		local b    = vec2.from_cartesian(r, t)
		assert.is_true(abs(a.x - b.x) <= DBL_EPSILON*2) -- Allow 2X epsilon error because there were 2 operations.
		assert.is_true(abs(a.y - b.y) <= DBL_EPSILON*2)
	end)

	it("gets a perpendicular vector", function()
		local a = vec2(3, 5)
		local b = a:perpendicular()
		assert.is.equal(-5, b.x)
		assert.is.equal( 3, b.y)
	end)

	it("gets a string representation of a vector", function()
		local a = vec2()
		local b = a:to_string()
		assert.is.equal("(+0.000,+0.000)", b)
	end)

	it("rounds a 2-vector", function()
		local a = vec2(1.1,1.9):round()
		assert.is.equal(a.x, 1)
		assert.is.equal(a.y, 2)
	end)

	it("flips a 2-vector", function()
		local a = vec2(1,2)
		local temp = a:flip_x()
		assert.is.equal(temp, vec2(-1, 2))
		temp = temp:flip_y()
		assert.is.equal(temp, vec2(-1, -2))
	end)

	it("finds angle from one 2-vector to another", function()
		local d = {
			right = vec2(1,  0),
			down  = vec2(0,  -1),
			left  = vec2(-1, 0),
			up    = vec2(0,  1),
		}
		assert.is.equal(math.deg(d.right:angle_to(d.right)), 0.0)
		assert.is.equal(math.deg(d.right:angle_to(d.down)), -90.0)
		assert.is.equal(math.deg(d.right:angle_to(d.left)), 180.0)
		assert.is.equal(math.deg(d.right:angle_to(d.up)), 90.0)

		assert.is.equal(math.deg(d.down:angle_to(d.right)), 90.0)
		assert.is.equal(math.deg(d.down:angle_to(d.down)), 0.0)
		assert.is.equal(math.deg(d.down:angle_to(d.left)), -90.0)
		assert.is.equal(math.deg(d.down:angle_to(d.up)), 180.0)

		assert.is.equal(math.deg(d.left:angle_to(d.right)), 180.0)
		assert.is.equal(math.deg(d.left:angle_to(d.down)), 90.0)
		assert.is.equal(math.deg(d.left:angle_to(d.left)), 0.0)
		assert.is.equal(math.deg(d.left:angle_to(d.up)), -90.0)

		assert.is.equal(math.deg(d.up:angle_to(d.right)), -90.0)
		assert.is.equal(math.deg(d.up:angle_to(d.down)), 180.0)
		assert.is.equal(math.deg(d.up:angle_to(d.left)), 90.0)
		assert.is.equal(math.deg(d.up:angle_to(d.up)), 0.0)
	end)

	it("finds angle between two 2-vectors", function()
		local d = {
			right = vec2(1,  0),
			down  = vec2(0,  -1),
			left  = vec2(-1, 0),
			up    = vec2(0,  1),
		}
		assert.is.equal(math.deg(d.right:angle_between(d.right)), 0.0)
		assert.is.equal(math.deg(d.right:angle_between(d.down)), 90.0)
		assert.is.equal(math.deg(d.right:angle_between(d.left)), 180.0)
		assert.is.equal(math.deg(d.right:angle_between(d.up)), 90.0)

		assert.is.equal(math.deg(d.down:angle_between(d.right)), 90.0)
		assert.is.equal(math.deg(d.down:angle_between(d.down)), 0.0)
		assert.is.equal(math.deg(d.down:angle_between(d.left)), 90.0)
		assert.is.equal(math.deg(d.down:angle_between(d.up)), 180.0)

		assert.is.equal(math.deg(d.left:angle_between(d.right)), 180.0)
		assert.is.equal(math.deg(d.left:angle_between(d.down)), 90.0)
		assert.is.equal(math.deg(d.left:angle_between(d.left)), 0.0)
		assert.is.equal(math.deg(d.left:angle_between(d.up)), 90.0)

		assert.is.equal(math.deg(d.up:angle_between(d.right)), 90.0)
		assert.is.equal(math.deg(d.up:angle_between(d.down)), 180.0)
		assert.is.equal(math.deg(d.up:angle_between(d.left)), 90.0)
		assert.is.equal(math.deg(d.up:angle_between(d.up)), 0.0)
	end)

	-- Do this last, to insulate tests from accidental state contamination
	-- Do vec3 tests last, to insulate tests from accidental state contamination
	it("converts a 2-vector to a 3-vector", function()
		local vec3 = require "modules.vec3"
		local a = vec2(1,2)
		local b = a:to_vec3()
		local c = a:to_vec3(3)
		assert.is.equal(b, vec3(1,2,0))
		assert.is.equal(c, vec3(1,2,3))
	end)

	it("converts a vec3 to vec2 using the constructor", function()
		local vec3 = require "modules.vec3"
		local a = vec2(3, 5)
		local b = vec3(3, 5, 7)
		local c = vec2(b)
		assert.is.equal(a, c)
	end)
end)
