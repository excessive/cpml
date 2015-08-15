local utils = require "modules.utils"
local constants = require "modules.constants"

describe("utils:", function()
	it("testing clamp", function()
		assert.is.equal(utils.clamp(10, 0, 5), 5)
		assert.is.equal(utils.clamp(-5, 0, 5), 0)
	end)

	it("testing map", function()
		assert.is.equal(utils.map(10, 0, 10, 0, 1), 1)
		assert.is.equal(utils.map(-5, 0, 10, 0, 5), -2.5)
	end)


	it("testing wrap", function()
		assert.is.equal(utils.wrap(-2, 6), 4)
		assert.is.equal(utils.wrap(8, 6), 2)
	end)

	it("testing is_pot", function()
		assert.is_true(utils.is_pot(1))
		assert.is_true(utils.is_pot(8))
		assert.is_true(utils.is_pot(16384))
		assert.is_false(utils.is_pot(7))
		assert.is_false(utils.is_pot(-22))
		assert.is_false(utils.is_pot(54812))
	end)

	it("testing round", function()
		assert.is.equal(utils.round(5.3), 5)
		assert.is.equal(utils.round(5.8), 6)

		-- comparing floats is annoying...
		assert.is.is_true(math.abs(utils.round(5.5555, 0.1) - 5.6) < constants.FLT_EPSILON)
	end)

	it("testing deadzone", function()
		assert.is.equal(utils.deadzone(0.5, 0.05), 0.5)
		assert.is.equal(utils.deadzone(0.02, 0.05), 0.0)
		assert.is.equal(utils.deadzone(-0.1, 0.02), -0.1)
	end)

	it("testing threshold", function()
		assert.is_true(utils.threshold(0.5, 0.25))
		assert.is_true(utils.threshold(0.25, 0.25))
		assert.is_false(utils.threshold(-0.1, 0.5))
		assert.is_true(utils.threshold(-0.25, 0.1))
	end)

	it("testing lerp", function()
		local l = 0.5
		local h = 20.0
		assert.is.equal(utils.lerp(0, l, h), l)
		assert.is.equal(utils.lerp(1, l, h), h)
		assert.is.equal(utils.lerp(0.5, l, h), (l+h)/2)
	end)

	pending "smoothstep"
end)
