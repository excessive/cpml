local color = require "modules.color"
local DBL_EPSILON = require("modules.constants").DBL_EPSILON

local function assert_is_float_equal(a, b)
	if math.abs(a - b) > DBL_EPSILON then
		assert.is.equal(a, b)
	end
end

local function assert_is_approx_equal(a, b)
	if math.abs(a - b) > 0.001 then
		assert.is.equal(a, b)
	end
end


describe("color:", function()
	it("operators: add, subract, multiply", function()
		local c = color(1, 1, 1, 1)
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

	it("rgb -> hsv -> rgb", function()
		local c = color(1,1,1,1)
		local hsv = c:color_to_hsv_table()
		local c1 = color.hsv_to_color_table(hsv)
		local c2 = color.from_hsva(hsv[1], hsv[2], hsv[3], hsv[4])
		local c3 = color.from_hsv(hsv[1], hsv[2], hsv[3])
		c3[4] = c[4]
		for i=1,4 do
			assert_is_float_equal(c[i], c1[i])
			assert_is_float_equal(c[i], c2[i])
			assert_is_float_equal(c[i], c3[i])
		end
		assert.is_true(c:is_color())
		assert.is_true(c1:is_color())
		assert.is_true(c2:is_color())
		assert.is_true(c3:is_color())
	end)

	it("hsv -> rgb -> hsv", function()
		local hsv1 = { 0, 0.3, 0.8, 0.9 }
		for h=0,359, 10 do
			hsv1[1] = h
			local cc = color.hsv_to_color_table(hsv1)
			local hsv2 = cc:color_to_hsv_table()
			for i=1,4 do
				assert_is_approx_equal(hsv1[i], hsv2[i])
			end
		end
	end)

	it("lighten a color", function()
		local c = color(0, 0, 0, 0)
		local r = c:lighten(10)
		assert.is.equal(r[1], 10)
		r = c:lighten(1000)
		assert.is.equal(r[1], 255)
	end)

	it("darken a color", function()
		local c = color(255, 255, 255, 255)
		local r = c:darken(10)
		assert.is.equal(r[1], 245)
		r = c:darken(1000)
		assert.is.equal(r[1], 0)
	end)

	it("modify alpha", function()
		local c = color(255, 255, 255, 255)
		local r = c:alpha(10)
		assert.is.equal(r[4], 10)
		r = c:opacity(0.5)
		assert.is.equal(r[4], 255/2)
	end)

end)

--[[
invert(c)
lerp(a, b, s)
multiply(c, v)
hue(color, hue)
saturation(color, percent)
value(color, percent)
gamma_to_linear(r, g, b, a)
linear_to_gamma(r, g, b, a)
to_string(a)
--]]
