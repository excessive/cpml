local mat4 = require "modules.mat4"

describe("mat4:", function()
	it("testing basic operators", function()
	end)

	it("testing clone", function()
		local v = mat4()
		local c = v:clone()
		c[1] = 2
		assert.is_not.equal(v, c)
	end)

	describe("vec3 pending tests", function()
		pending "lerp"
	end)
end)
