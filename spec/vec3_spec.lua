local vec3        = require "modules.vec3"
local DBL_EPSILON = require("modules.constants").DBL_EPSILON
local abs, sqrt   = math.abs, math.sqrt

describe("vec3:", function()
	it("tests creating vectors", function()
		-- new empty vector
		local a = vec3()
		assert.is.equal(a.x, 0)
		assert.is.equal(a.y, 0)
		assert.is.equal(a.z, 0)
		assert.is_true(a:is_vec3())
		assert.is_true(a:is_zero())

		-- new vector from table
		local b = vec3 { 0, 0, 0 }
		assert.is.equal(b.x, 0)
		assert.is.equal(b.y, 0)
		assert.is.equal(b.z, 0)

		local c = vec3 { x=0, y=0, z=0 }
		assert.is.equal(c.x, 0)
		assert.is.equal(c.y, 0)
		assert.is.equal(c.z, 0)

		-- new vector from numbers
		local d = vec3(3.14159, -2.808, 1.337)
		assert.is.equal(d.x,  3.14159)
		assert.is.equal(d.y, -2.808)
		assert.is.equal(d.z,  1.337)

		-- new vector from other vector
		local e = d:clone()
		assert.is.equal(d, e)
	end)

	it("tests basic operators", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local s = 2

		-- Add
		do
			local c = vec3():add(a, b)
			local d = a + b

			assert.is.equal(c.x, 10)
			assert.is.equal(c.y, 9)
			assert.is.equal(c.z, 8)
			assert.is.equal(c, d)
		end

		-- Subtract
		do
			local c = vec3():sub(a, b)
			local d = a - b

			assert.is.equal(c.x, -4)
			assert.is.equal(c.y,  1)
			assert.is.equal(c.z,  6)
			assert.is.equal(c, d)
		end

		-- Multiply
		do
			local c = vec3():mul(a, s)
			local d = a * s

			assert.is.equal(c.x, 6)
			assert.is.equal(c.y, 10)
			assert.is.equal(c.z, 14)
			assert.is.equal(c, d)
		end

		-- Divide
		do
			local c = vec3():div(a, s)
			local d = a / s

			assert.is.equal(c.x, 1.5)
			assert.is.equal(c.y, 2.5)
			assert.is.equal(c.z, 3.5)
			assert.is.equal(c, d)
		end

		-- Sign flip
		do
			local c = -a
			assert.is.equal(c.x, -3)
			assert.is.equal(c.y, -5)
			assert.is.equal(c.z, -7)
		end
	end)

	it("tests normal, trim, length", function()
		local a = vec3(3, 5, 7)
		local b = vec3():normalize(a)
		local c = vec3():trim(a, 0.5)

		assert.is_true(abs(b:len()  - 1)   < DBL_EPSILON)
		assert.is_true(abs(b:len()  - 1)   < DBL_EPSILON)
		assert.is_true(abs(b:len2() - 1)   < DBL_EPSILON * 2)
		assert.is_true(abs(c:len()  - 0.5) < DBL_EPSILON)
	end)

	it("tests distance", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)

		-- Distance
		do
			local c = a:dist(b)
			assert.is.equal(c, sqrt(53))
		end

		-- Distance Squared
		do
			local c = a:dist2(b)
			assert.is.equal(c, 53)
		end
	end)

	it("tests cross product", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local c = vec3():cross(a, b)

		assert.is.equal(c.x, -23)
		assert.is.equal(c.y,  46)
		assert.is.equal(c.z, -23)
	end)

	it("tests dot product", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local c = a:dot(b)
		assert.is.equal(c, 48)
	end)

	it("tests lerp", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local s = 0.1
		local c = vec3():lerp(a, b, s)

		assert.is.equal(c.x, 3.4)
		assert.is.equal(c.y, 4.9)
		assert.is.equal(c.z, 6.4)
	end)

	it("tests unpack", function()
		local a = vec3(3, 5, 7)
		local x, y, z = a:unpack()

		assert.is.equal(x, 3)
		assert.is.equal(y, 5)
		assert.is.equal(z, 7)
	end)

	it("tests rotate", function()
		local a = vec3(3, 5, 7)
		local b = vec3():rotate(a,  math.pi, vec3.unit_z)
		local c = vec3():rotate(b, -math.pi, vec3.unit_z)

		assert.is.equal(c.x, 3)
		assert.is.equal(c.y, 5)
		assert.is.equal(c.z, 7)
	end)

	it("tests perpendicular", function()
		local a = vec3(3, 5, 7)
		local b = vec3():perpendicular(a)

		assert.is.equal(b.x, -5)
		assert.is.equal(b.y,  3)
		assert.is.equal(b.z,  0)
	end)
end)
