local utils = require "modules.utils"

describe("utils tests", function()
	it("tests clamp", function()
		assert.is.equal(utils.clamp(10, 0, 5), 5)
		assert.is.equal(utils.clamp(-5, 0, 5), 0)
	end)

	it("tests map", function()
		assert.is.equal(utils.map(10, 0, 10, 0, 1), 1)
		assert.is.equal(utils.map(-5, 0, 10, 0, 5), -2.5)
	end)


	it("tests wrap", function()
		assert.is.equal(utils.wrap(-2, 6), 4)
		assert.is.equal(utils.wrap(8, 6), 2)
	end)

	it("tests is_pot", function()
		assert.is_true(utils.is_pot(1))
		assert.is_true(utils.is_pot(8))
		assert.is_true(utils.is_pot(16384))
		assert.is_false(utils.is_pot(7))
		assert.is_false(utils.is_pot(-22))
		assert.is_false(utils.is_pot(54812))
	end)

	pending "round"
	pending "lerp"
end)
