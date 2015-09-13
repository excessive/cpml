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
		assert.is.equal(vec3(1, 1, 1) / vec3(2, 2, 2), vec3(0.5, 0.5, 0.5))
		assert.is.equal(1 / vec3(2, 2, 2), vec3(0.5, 0.5, 0.5))
	end)

	it("testing value ranges", function()
		-- This makes sure we are initializing reasonably and that
		-- we haven't broken everything with some FFI magic.
		assert.is.equal(vec3(256, 0, 0).x, 256)
		assert.is.equal(vec3(0, 65537, 0).y, 65537)
		assert.is.equal(vec3(953, 0, 491.5).z, 491.5)
		assert.is.equal(vec3(0, 1.2222, 0).y, 1.2222)
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

	it("testing new", function()
		local v = vec3()
		assert.is_true(v.x == 0)
		assert.is_true(v.y == 0)
		assert.is_true(v.z == 0)

		v = vec3{1, 2, 3}
		assert.is_true(v.x == 1)
		assert.is_true(v.y == 2)
		assert.is_true(v.z == 3)

		v = vec3(4, 5, 6)
		assert.is_true(v.x == 4)
		assert.is_true(v.y == 5)
		assert.is_true(v.z == 6)
	end)

	it("testing tostring", function()
		assert.has_no.errors(function() return tostring(vec3(1,1,1)) end)
	end)

	it("testing isvector", function()
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
		assert.is.equal(vec3.unit_x:cross(vec3.unit_y), vec3.unit_z)
	end)

	it("testing len and normalize", function()
		assert.is.equal(vec3(1,0,0):len(), 1)
		assert.is.equal(vec3(5,-10,9):normalize():len(), 1)
	end)

	it("testing len2", function()
		assert.is.equal(vec3(1,0,0):len2(), 1)
		assert.is.equal(vec3(2,0,2):len2(), 8)
	end)

	it("testing lerp", function()
		assert.is.equal(vec3(0, 0, 0):lerp(vec3(1, 1, 1), 0.5), vec3(0.5, 0.5, 0.5))
	end)

	it("testing rotate", function()
		local t = 1.0e-15
		assert.is_true(vec3(1,0,0):rotate(math.pi, vec3.unit_z) - vec3(-1, 0, 0) < vec3(t, t, t))
	end)

	describe("vec3 pending tests", function()
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
