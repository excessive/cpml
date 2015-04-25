local vec3 = require "modules.vec3"

describe("vec3:", function()
	it("testing basic operators", function()
		-- add
		assert.is.equal(vec3(1, 1, 1) + vec3(2, 3, 4), vec3(3, 4, 5))
		assert.has.errors(function() return vec3(1, 1, 1) + 5 end)

		-- sub
		assert.is.equal(vec3(1, 1, 1) - vec3(2, 3, 4), vec3(-1, -2, -3))
		assert.has.errors(function() return vec3(1, 1, 1) - 5 end)

		-- mul
		assert.is.equal(vec3(2, 1, 2) * vec3(2, 3, 4), vec3(4, 3, 8))
		assert.has_no.errors(function() return vec3(1,1,1) * {x=2,y=2,z=2} end)
		assert.has_no.errors(function() return 2 * vec3(1,1,1) end)
		assert.has_no.errors(function() return vec3(1,1,1) * 2 end)

		-- unm
		assert.is.equal(vec3(1, 1, 1) + -vec3(1, 1, 1), vec3(0, 0, 0))

		-- div
		assert.is.equal(vec3(1, 1, 1) / 2, vec3(0.5, 0.5, 0.5))
		assert.has.errors(function() return vec3(1, 1, 1) / vec3(2, 2, 2) end)
	end)

	it("testing comparison operators", function()
		-- eq
		assert.is_true(vec3(5,5,5) == vec3(5,5,5))

		-- lt
		assert.is_true(vec3(3,3,3) < vec3(5,5,5))
		assert.is_false(vec3(5,5,5) < vec3(5,5,5))

		-- le
		assert.is_true(vec3(5,5,5) <= vec3(5,5,5))
		assert.is_false(vec3(3,3,3) >= vec3(5,5,5))
	end)

	it("testing misc operators", function()
		-- tostring
		assert.has_no.errors(function() return tostring(vec3(1,1,1)) end)

		assert.is_true(vec3.isvector(vec3()))
		assert.is_true(vec3.isvector(vec3{1,1}))
		assert.is_true(vec3.isvector{x=1, y=2, z=3})
	end)

	it("testing clone", function()
		local v = vec3(1,1,1)
		local c = v:clone()
		c.x = 2
		assert.is_not.equal(v, c)
	end)

	it("testing dot", function()
		assert.is.equal(vec3(5,10,-5):dot(vec3(3,1,1)), 20)
		assert.is.equal(vec3(2,-1,2):dot(vec3(1,2,1)), 2)
		assert.is.equal(vec3(5,5,5):dot(vec3(5,5,5)), 75)
	end)

	it("testing cross", function()
		assert.is.equal(vec3(1,0,0):cross(vec3(0,1,0)), vec3(0,0,1))
	end)

	it("testing len and normalize", function()
		assert.is.equal(vec3(1,0,0):len(), 1)
		assert.is.equal(vec3(5,-10,9):normalize():len(), 1)
	end)

	it("testing len2", function()
		assert.is.equal(vec3(1,0,0):len2(), 1)
		assert.is.equal(vec3(2,0,2):len2(), 8)
	end)

	describe("vec3 pending tests", function()
		pending "lerp"
		pending "trim"
		pending "angle_to"
		pending "angle_between"
		pending "mirror_on"
		pending "orientation_to_direction"
		pending "project_from"
		pending "project_on"
		pending "perpendicular"
		pending "rotate"
		pending "dist"
		pending "dist2"
	end)
end)
