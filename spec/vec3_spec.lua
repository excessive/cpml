local vec3        = require "modules.vec3"
local DBL_EPSILON = require("modules.constants").DBL_EPSILON
local abs, sqrt   = math.abs, math.sqrt

describe("vec3:", function()
	it("Test creating vectors", function()
		-- new empty vector
		local a = vec3()
		assert.is.equal(a.x, 0)
		assert.is.equal(a.y, 0)
		assert.is.equal(a.z, 0)
		assert.is_true(vec3.is_vec3(a))

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
		assert.is.equal(d.x, 3.14159)
		assert.is.equal(d.y, -2.808)
		assert.is.equal(d.z, 1.337)

		-- new vector from other vector
		local e = vec3.clone(d)
		assert.is.equal(d, e)

		local f = d:clone()
		assert.is.equal(d, f)
	end)

	it("Test basic operators", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local s = 2

		-- Add
		do
			local c = vec3.add(vec3(), a, b)
			assert.is.equal(c.x, 10)
			assert.is.equal(c.y, 9)
			assert.is.equal(c.z, 8)

			local d = a + b
			assert.is.equal(c, d)
		end

		-- Subtract
		do
			local c = vec3.sub(vec3(), a, b)
			assert.is.equal(c.x, -4)
			assert.is.equal(c.y, 1)
			assert.is.equal(c.z, 6)

			local d = a - b
			assert.is.equal(c, d)
		end

		-- Multiply
		do
			local c = vec3.mul(vec3(), a, s)
			assert.is.equal(c.x, 6)
			assert.is.equal(c.y, 10)
			assert.is.equal(c.z, 14)

			local d = a * s
			assert.is.equal(c, d)
		end

		-- Divide
		do
			local c = vec3.div(vec3(), a, s)
			assert.is.equal(c.x, 1.5)
			assert.is.equal(c.y, 2.5)
			assert.is.equal(c.z, 3.5)

			local d = a / s
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

	it("Test normal, trim, length", function()
		local a = vec3(3, 5, 7)

		local b = vec3.normalize(vec3(), a)
		assert.is_true(abs(b:len()  - 1) < DBL_EPSILON)
		assert.is_true(abs(b:len()  - 1) < DBL_EPSILON)
		assert.is_true(abs(b:len2() - 1) < DBL_EPSILON * 2)

		local c = vec3.trim(vec3(), a, 0.5)
		assert.is_true(abs(c:len() - 0.5) < DBL_EPSILON)
	end)

	it("Test distance", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)

		-- Distance
		do
			local c = vec3.dist(a, b)
			assert.is.equal(c, sqrt(53))

			local d = a:dist(b)
			assert.is.equal(c, d)
		end

		-- Distance Squared
		do
			local c = vec3.dist2(a, b)
			assert.is.equal(c, 53)

			local d = a:dist2(b)
			assert.is.equal(c, d)
		end
	end)

	it("Test cross product", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)

		local c = vec3.cross(vec3(), a, b)
		assert.is.equal(c.x, -23)
		assert.is.equal(c.y,  46)
		assert.is.equal(c.z, -23)
	end)

	it("Test dot product", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)

		local c = vec3.dot(a, b)
		assert.is.equal(c, 48)

		local d = a:dot(b)
		assert.is.equal(c, d)
	end)

	it("Test lerp", function()
		local a = vec3(3, 5, 7)
		local b = vec3(7, 4, 1)
		local s = 0.1

		local c = vec3.lerp(vec3(), a, b, s)
		assert.is.equal(c.x, 3.4)
		assert.is.equal(c.y, 4.9)
		assert.is.equal(c.z, 6.4)
	end)

	it("Test unpack", function()
		local a = vec3(3, 5, 7)

		do
			local x, y, z = vec3.unpack(a)
			assert.is.equal(x, 3)
			assert.is.equal(y, 5)
			assert.is.equal(z, 7)
		end

		do
			local x, y, z = a:unpack()
			assert.is.equal(x, 3)
			assert.is.equal(y, 5)
			assert.is.equal(z, 7)
		end
	end)
end)

--[[

-- TODO: Reflect
do
	local a = vec3(3, 5, 7)
end

-- TODO: Refract
do
	local a = vec3(3, 5, 7)
end

--]]
