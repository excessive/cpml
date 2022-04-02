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
		for h=0,1, 0.1 do
			hsv1[1] = h
			local cc = color.hsv_to_color_table(hsv1)
			local hsv2 = cc:color_to_hsv_table()
			for i=1,4 do
				assert_is_approx_equal(hsv1[i], hsv2[i])
			end
		end
	end)

	it("unpack", function()
		local c = color(122/255, 20/255, 122/255, 255/255)
		local r, g, b, a = c:unpack()
		assert_is_float_equal(c[1], r)
		assert_is_float_equal(c[2], g)
		assert_is_float_equal(c[3], b)
		assert_is_float_equal(c[4], a)
		r, g, b, a = c:as_255()
		assert_is_float_equal(122, r)
		assert_is_float_equal(20, g)
		assert_is_float_equal(122, b)
		assert_is_float_equal(255, a)
	end)

	it("set hsv", function()
		-- hsv value conversion values from http://colorizer.org/
		local c = color(122/255, 20/255, 122/255, 1)
		local hsv = c:color_to_hsv_table()
		assert_is_approx_equal(hsv[1], 300/360)
		assert_is_approx_equal(hsv[2], 0.8361)
		assert_is_approx_equal(hsv[3], 0.4784)
		local r = c:hue(200/360)
		assert_is_approx_equal(r[1], 20/255)
		assert_is_approx_equal(r[2], 88/255)
		assert_is_approx_equal(r[3], 122/255)
		r = c:saturation(0.2)
		assert_is_approx_equal(r[1], 122/255)
		assert_is_approx_equal(r[2], 97.6/255)
		assert_is_approx_equal(r[3], 122/255)
		r = c:value(0.2)
		assert_is_approx_equal(r[1], 51/255)
		assert_is_approx_equal(r[2], 8.36/255)
		assert_is_approx_equal(r[3], 51/255)
	end)

	it("lighten a color", function()
		local c = color(0, 0, 0, 0)
		local r = c:lighten(0.1)
		assert.is.equal(r[1], 0.1)
		r = c:lighten(1000)
		assert.is.equal(r[1], 1)
	end)

	it("darken a color", function()
		local c = color(1, 1, 1, 1)
		local r = c:darken(0.04)
		assert.is.equal(r[1], 0.96)
		r = c:darken(1000)
		assert.is.equal(r[1], 0)
	end)

	it("multiply a color by a scalar", function()
		local c = color(1, 1, 1, 1)
		local r = c:multiply(0.04)
		assert.is.equal(r[1], 0.04)

		r = c:multiply(0)
		for i=1,3 do
			assert.is.equal(0, r[i])
		end
		assert.is.equal(1, r[4])
	end)

	it("modify alpha", function()
		local c = color(1, 1, 1, 1)
		local r = c:alpha(0.1)
		assert.is.equal(r[4], 0.1)
		r = c:opacity(0.5)
		assert.is.equal(r[4], 0.5)
		r = c:opacity(0.5)
			:opacity(0.5)
		assert.is.equal(r[4], 0.25)
	end)

	it("invert", function()
		local c = color(1, 0.6, 0.25, 1)
		local r = c:invert()
		assert_is_float_equal(r[1], 0)
		assert_is_float_equal(r[2], 0.4)
		assert_is_float_equal(r[3], 0.75)
		assert_is_float_equal(r[4], 1)
		r = c:invert()
			:invert()
		for i=1,4 do
			assert.is.equal(c[i], r[i])
		end
	end)

	it("lerp", function()
		local a = color(1, 0.6, 0.25, 1)
		local b = color(1, 0.8, 0.75, 0.5)
		local r = a:lerp(b, 0.5)
		assert_is_float_equal(r[1], 1)
		assert_is_float_equal(r[2], 0.7)
		assert_is_float_equal(r[3], 0.5)
		assert_is_float_equal(r[4], 0.75)
		local r_a = a:lerp(b, 0)
		local r_b = a:lerp(b, 1)
		for i=1,4 do
			assert.is.equal(a[i], r_a[i])
			assert.is.equal(b[i], r_b[i])
		end
	end)

	it("linear_to_gamma -> gamma_to_linear round trip", function()
		local c = color(0.25, 0.25, 0.25, 1)
		local r = color.gamma_to_linear(c:linear_to_gamma())
		for i=1,4 do
			assert_is_approx_equal(c[i], r[i])
		end
	end)

end)

--[[
to_string(a)
--]]
