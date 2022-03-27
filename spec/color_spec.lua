local color = require "modules.color"
local DBL_EPSILON = require("modules.constants").DBL_EPSILON

local function assert_is_float_equal(a, b)
	if math.abs(a - b) > DBL_EPSILON then
		assert.is.equal(a, b)
	end
end


describe("color:", function()
	it("operators: add, subract, multiply", function()
		local c = color(1,1,1,1)
		assert.is_true(c:is_color())
		local r = c + c
		assert.is_true(r:is_color())
		assert_is_float_equal(r[1], 2)
		assert_is_float_equal(r[2], 2)
		assert_is_float_equal(r[3], 2)
		r = c - c
		assert.is_true(r:is_color())
		assert_is_float_equal(r[1], 0)
		assert_is_float_equal(r[2], 0)
		assert_is_float_equal(r[3], 0)
		r = c * 5
		assert.is_true(r:is_color())
		assert_is_float_equal(r[1], 5)
		assert_is_float_equal(r[2], 5)
		assert_is_float_equal(r[3], 5)
	end)

end)

--[[
from_hsv(h, s, v)
from_hsva(h, s, v, a)
invert(c)
lighten(c, v)
lerp(a, b, s)
darken(c, v)
multiply(c, v)
alpha(c, v)
opacity(c, v)
hue(color, hue)
saturation(color, percent)
value(color, percent)
gamma_to_linear(r, g, b, a)
linear_to_gamma(r, g, b, a)
to_string(a)
--]]
