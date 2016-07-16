local vec2        = require "modules.vec2"
local DBL_EPSILON = require("modules.constants").DBL_EPSILON
local abs, sqrt   = math.abs, math.sqrt

describe("vec2:", function()
	it("Test creating vectors", function()
		-- new empty vector
		local a = vec2()
		assert.is.equal(a.x, 0)
		assert.is.equal(a.y, 0)
		assert.is_true(vec2.isvec2(a))

		-- new vector from table
		local b = vec2 { 0, 0 }
		assert.is.equal(b.x, 0)
		assert.is.equal(b.y, 0)

		local c = vec2 { x=0, y=0 }
		assert.is.equal(c.x, 0)
		assert.is.equal(c.y, 0)

		-- new vector from numbers
		local d = vec2(3.14159, -2.808)
		assert.is.equal(d.x, 3.14159)
		assert.is.equal(d.y, -2.808)

		-- new vector from other vector
		local e = vec2.clone(d)
		assert.is.equal(d, e)

		local f = d:clone()
		assert.is.equal(d, f)
	end)

	it("Test basic operators", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local s = 2

		-- Add
		do
			local c = vec2.add(vec2(), a, b)
			assert.is.equal(c.x, 10)
			assert.is.equal(c.y, 9)

			local d = a + b
			assert.is.equal(c, d)
		end

		-- Subtract
		do
			local c = vec2.sub(vec2(), a, b)
			assert.is.equal(c.x, -4)
			assert.is.equal(c.y, 1)

			local d = a - b
			assert.is.equal(c, d)
		end

		-- Multiply
		do
			local c = vec2.mul(vec2(), a, s)
			assert.is.equal(c.x, 6)
			assert.is.equal(c.y, 10)

			local d = a * s
			assert.is.equal(c, d)
		end

		-- Divide
		do
			local c = vec2.div(vec2(), a, s)
			assert.is.equal(c.x, 1.5)
			assert.is.equal(c.y, 2.5)

			local d = a / s
			assert.is.equal(c, d)
		end

		-- Sign flip
		do
			local c = -a
			assert.is.equal(c.x, -3)
			assert.is.equal(c.y, -5)
		end
	end)

	it("Test normal, trim, length", function()
		local a = vec2(3, 5)

		local b = vec2.normalize(vec2(), a)
		assert.is_true(abs(b:len()  - 1) < DBL_EPSILON)
		assert.is_true(abs(b:len()  - 1) < DBL_EPSILON)
		assert.is_true(abs(b:len2() - 1) < DBL_EPSILON * 2)

		local c = vec2.trim(vec2(), a, 0.5)
		assert.is_true(abs(c:len() - 0.5) < DBL_EPSILON)
	end)

	it("Test distance", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)

		-- Distance
		do
			local c = vec2.dist(a, b)
			assert.is.equal(c, sqrt(17))

			local d = a:dist(b)
			assert.is.equal(c, d)
		end

		-- Distance Squared
		do
			local c = vec2.dist2(a, b)
			assert.is.equal(c, 17)

			local d = a:dist2(b)
			assert.is.equal(c, d)
		end
	end)

	it("Test cross product", function()
		do
			local a = vec2(3, 5)
			local b = vec2(7, 4)

			local c = vec2.cross(a, b)
			assert.is.equal(c, -23)

			local d = a:cross(b)
			assert.is.equal(c, d)
		end
	end)

	it("Test dot product", function()
		do
			local a = vec2(3, 5)
			local b = vec2(7, 4)

			local c = vec2.dot(a, b)
			assert.is.equal(c, 41)

			local d = a:dot(b)
			assert.is.equal(c, d)
		end
	end)

	it("Test lerp", function()
		local a = vec2(3, 5)
		local b = vec2(7, 4)
		local s = 0.1

		local c = vec2.lerp(vec2(), a, b, s)
		assert.is.equal(c.x, 3.4)
		assert.is.equal(c.y, 4.9)
	end)

	it("Test unpack", function()
		local a = vec2(3, 5)

		do
			local x, y = vec2.unpack(a)
			assert.is.equal(x, 3)
			assert.is.equal(y, 5)
		end

		do
			local x, y = a:unpack()
			assert.is.equal(x, 3)
			assert.is.equal(y, 5)
		end
	end)
end)

--[[

-- TODO: To Cartesian
do
	local a = vec2(3, 5)
end

-- TODO: To Polar
do
	local a = vec2(3, 5)
end

--]]
