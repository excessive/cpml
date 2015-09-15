local constants = require "modules.constants"
local vec2 = require "modules.vec2"

describe("vec2:", function()
	it("testing basic operators", function()
		-- add
		assert.is.equal(vec2(1, 1) + vec2(2, 3), vec2(3, 4))
		assert.has.errors(function() return vec2(1, 1) + 5 end)

		-- sub
		assert.is.equal(vec2(1, 1) - vec2(2, 3), vec2(-1, -2))
		assert.has.errors(function() return vec2(1, 1) - 5 end)

		-- mul
		assert.is.equal(vec2(2, 1) * vec2(2, 3), vec2(4, 3))
		assert.has_no.errors(function() return vec2(1,1) * {x=2,y=2} end)
		assert.has_no.errors(function() return 2 * vec2(1,1) end)
		assert.has_no.errors(function() return vec2(1,1) * 2 end)

		-- unm
		assert.is.equal(vec2(1, 1) + -vec2(1, 1), vec2(0, 0))

		-- div
		assert.is.equal(vec2(1, 1) / 2, vec2(0.5, 0.5))
		assert.is.equal(vec2(1, 1) / vec2(2, 2), vec2(0.5, 0.5))
		assert.is.equal(1 / vec2(2, 2), vec2(0.5, 0.5))
	end)

	it("testing value ranges", function()
		-- This makes sure we are initializing reasonably and that
		-- we haven't broken everything with some FFI magic.
		assert.is.equal(vec2(256, 0).x, 256)
		assert.is.equal(vec2(0, 65537).y, 65537)
		assert.is.equal(vec2(-953, 0).x, -953)
		assert.is.equal(vec2(0, 1.2222).y, 1.2222)
	end)

	it("testing comparison operators", function()
		-- eq
		assert.is_true(vec2(5,5) == vec2(5,5))

		-- lt
		assert.is_true(vec2(3,3) < vec2(5,5))
		assert.is_false(vec2(5,5) < vec2(5,5))

		-- le
		assert.is_true(vec2(5,5) <= vec2(5,5))
		assert.is_false(vec2(3,3) >= vec2(5,5))
	end)

	it("testing new", function()
		local v = vec2()
		assert.is_true(v.x == 0)
		assert.is_true(v.y == 0)

		v = vec2{1, 2}
		assert.is_true(v.x == 1)
		assert.is_true(v.y == 2)

		v = vec2(4, 5)
		assert.is_true(v.x == 4)
		assert.is_true(v.y == 5)
	end)

	it("testing tostring", function()
		assert.has_no.errors(function() return tostring(vec2(1,1)) end)
	end)

	it("testing isvector", function()
		assert.is_true(vec2.isvector(vec2()))
		assert.is_true(vec2.isvector(vec2{1,1}))
		assert.is_true(vec2.isvector{x=1, y=2})
	end)

	it("testing clone", function()
		local v = vec2(1,1)
		local c = v:clone()
		c.x = 2
		assert.is_not.equal(v, c)
	end)

	it("testing len and normalize", function()
		assert.is.equal(vec2(1,0):len(), 1)
		assert.is_true(vec2(5,-10):normalize():len() - 1 < constants.FLT_EPSILON)
	end)

	it("testing len2", function()
		assert.is.equal(vec2(1,0):len2(), 1)
		assert.is.equal(vec2(2,0):len2(), 4)
	end)

	it("testing lerp", function()
		assert.is.equal(vec2(0, 0):lerp(vec2(1, 1), 0.5), vec2(0.5, 0.5))
	end)

	describe("vec2 pending tests", function()
		pending "rotate"
		pending "dot"
		pending "cross"
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
