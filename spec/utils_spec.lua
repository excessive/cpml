local vec3      = require "modules.vec3"
local utils     = require "modules.utils"
local constants = require "modules.constants"

local function tolerance(v, t)
	return math.abs(v - t) < 1e-6
end

describe("utils:", function()
	it("interpolates between two numbers", function()
		assert.is_true(tolerance(utils.lerp(0, 1, 0.5), 0.5))
	end)

	it("interpolates between two vectors", function()
		local a = vec3(0, 0, 0)
		local b = vec3(1, 1, 1)
		local c = vec3(0.5, 0.5, 0.5)
		assert.is.equal(utils.lerp(a, b, 0.5), c)

		a = vec3(5, 5, 5)
		b = vec3(0, 0, 0)
		c = vec3(2.5, 2.5, 2.5)
		assert.is.equal(utils.lerp(a, b, 0.5), c)
	end)

	it("decays exponentially", function()
		local v = utils.decay(0, 1, 0.5, 1)
		assert.is_true(tolerance(v, 0.39346934028737))
	end)

	it("rounds a number", function()
		-- round up
		local v = utils.round(1.3252525, 0.01)
		assert.is_true(tolerance(v, 1.33))
		-- round down
		v = utils.round(1.3242525, 0.1)
		assert.is_true(tolerance(v, 1.3))
		-- no precision
		v = utils.round(1.3242525)
		assert.is_true(tolerance(v, 1))
	end)
end)

--[[
clamp(value, min, max)
deadzone(value, size)
threshold(value, threshold)
tolerance(value, threshold)
map(value, min_in, max_in, min_out, max_out)
lerp(progress, low, high)
smoothstep(progress, low, high)
wrap(value, limit)
is_pot(value)
project_on(out, a, b)
project_from(out, a, b)
mirror_on(out, a, b)
reflect(out, i, n)
refract(out, i, n, ior)
--]]
