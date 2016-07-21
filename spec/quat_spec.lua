local quat = require "modules.quat"
local vec3 = require "modules.vec3"

describe("quat:", function()
	it("tests creating new quaternions", function()
		local a = quat()
		assert.is.equal(a.x, 0)
		assert.is.equal(a.y, 0)
		assert.is.equal(a.z, 0)
		assert.is.equal(a.w, 1)
		assert.is_true(a:is_quat())
		assert.is_true(a:is_real())

		local b = quat(0, 0, 0, 0)
		assert.is.equal(b.x, 0)
		assert.is.equal(b.y, 0)
		assert.is.equal(b.z, 0)
		assert.is.equal(b.w, 0)
		assert.is_true(b:is_zero())
		assert.is_true(b:is_imaginary())

		local c = quat { 2, 3, 4, 1 }
		assert.is.equal(c.x, 2)
		assert.is.equal(c.y, 3)
		assert.is.equal(c.z, 4)
		assert.is.equal(c.w, 1)

		local d = quat { x=2, y=3, z=4, w=1 }
		assert.is.equal(d.x, 2)
		assert.is.equal(d.y, 3)
		assert.is.equal(d.z, 4)
		assert.is.equal(d.w, 1)

		local e           = quat.from_angle_axis(math.pi, vec3.unit_z)
		local angle, axis = e:to_angle_axis()
		assert.is.equal(angle, math.pi)
		assert.is.equal(axis, vec3.unit_z)

		local f = quat.from_direction(vec3():normalize(vec3(5, 10, 15)), vec3.unit_z)
		--assert.is.equal(f.x, 0)
		--assert.is.equal(f.y, 0)
		--assert.is.equal(f.z, 0)
		--assert.is.equal(f.w, 0)

		local g = a:clone()
		assert.is.equal(g.x, a.x)
		assert.is.equal(g.y, a.y)
		assert.is.equal(g.z, a.z)
		assert.is.equal(g.w, a.w)
	end)

	it("tests standard operators", function()
		local a = quat(2, 3, 4, 1)
		local b = quat(3, 6, 9, 1)

		do
			local c = quat():add(a, b)
			assert.is.equal(c.x, 5)
			assert.is.equal(c.y, 9)
			assert.is.equal(c.z, 13)
			assert.is.equal(c.w, 2)

			local d = a + b
			assert.is.equal(c.x, d.x)
			assert.is.equal(c.y, d.y)
			assert.is.equal(c.z, d.z)
			assert.is.equal(c.w, d.w)
		end

		do
			local c = quat():sub(a, b)
			assert.is.equal(c.x, -1)
			assert.is.equal(c.y, -3)
			assert.is.equal(c.z, -5)
			assert.is.equal(c.w,  0)

			local d = a - b
			assert.is.equal(c.x, d.x)
			assert.is.equal(c.y, d.y)
			assert.is.equal(c.z, d.z)
			assert.is.equal(c.w, d.w)
		end

		do
			local c = quat():mul(a, b)
			assert.is.equal(c.x,  8)
			assert.is.equal(c.y,  3)
			assert.is.equal(c.z,  16)
			assert.is.equal(c.w, -59)

			local d = a * b
			assert.is.equal(c.x, d.x)
			assert.is.equal(c.y, d.y)
			assert.is.equal(c.z, d.z)
			assert.is.equal(c.w, d.w)
		end

		do
			local c = quat():scale(a, 3)
			assert.is.equal(c.x, 6)
			assert.is.equal(c.y, 9)
			assert.is.equal(c.z, 12)
			assert.is.equal(c.w, 3)

			local d = a * 3
			assert.is.equal(c.x, d.x)
			assert.is.equal(c.y, d.y)
			assert.is.equal(c.z, d.z)
			assert.is.equal(c.w, d.w)

			local e = -a
			assert.is.equal(e.x, -a.x)
			assert.is.equal(e.y, -a.y)
			assert.is.equal(e.z, -a.z)
			assert.is.equal(e.w, -a.w)
		end

		do
			local v = vec3(3, 4, 5)
			local c = quat.mul_vec3(vec3(), a, v)
			--assert.is.equal(c.x, 0)
			--assert.is.equal(c.y, 0)
			--assert.is.equal(c.z, 0)
			--assert.is.equal(c.w, 0)

			local d = a * v
			--assert.is.equal(c.x, d.x)
			--assert.is.equal(c.y, d.y)
			--assert.is.equal(c.z, d.z)
			--assert.is.equal(c.w, d.w)
		end

		do
			local c = quat():pow(a, 2)
			--assert.is.equal(c.x, 0)
			--assert.is.equal(c.y, 0)
			--assert.is.equal(c.z, 0)
			--assert.is.equal(c.w, 0)

			local d = a^2
			--assert.is.equal(c.x, d.x)
			--assert.is.equal(c.y, d.y)
			--assert.is.equal(c.z, d.z)
			--assert.is.equal(c.w, d.w)
		end
	end)

	it("tests normal, dot", function()
		local a = quat(1, 1, 1, 1)
		local b = quat(4, 4, 4, 4)
		local c = quat():normalize(a)
		local d = a:dot(b)

		assert.is.equal(c.x, 0.5)
		assert.is.equal(c.y, 0.5)
		assert.is.equal(c.z, 0.5)
		assert.is.equal(c.w, 0.5)
		assert.is.equal(d,    16)
	end)

	it("tests length", function()
		local a = quat(2, 3, 4, 5)
		local b = a:len()
		local c = a:len2()

		assert.is.equal(b, math.sqrt(54))
		assert.is.equal(c, 54)
	end)

	it("tests interpolation", function()
		local a = quat(3, 3, 3, 3)
		local b = quat(6, 6, 6, 6)
		local s = 0.1

		local c = quat():lerp(a, b, s)
		assert.is.equal(c.x, 0.5)
		assert.is.equal(c.y, 0.5)
		assert.is.equal(c.z, 0.5)
		assert.is.equal(c.w, 0.5)

		local d = quat():slerp(a, b, s)
		assert.is.equal(d.x, 0.5)
		assert.is.equal(d.y, 0.5)
		assert.is.equal(d.z, 0.5)
		assert.is.equal(d.w, 0.5)
	end)

	it("tests extraction", function()
		local a = quat(2, 3, 4, 1)

		local x, y, z, w = a:unpack()
		assert.is.equal(x, 2)
		assert.is.equal(y, 3)
		assert.is.equal(z, 4)
		assert.is.equal(w, 1)

		local v = a:to_vec3()
		assert.is.equal(v.x, 2)
		assert.is.equal(v.y, 3)
		assert.is.equal(v.z, 4)
	end)

	it("tests conjugate", function()
		local a = quat(2, 3, 4, 1)
		local b = quat():conjugate(a)

		assert.is.equal(b.x, -2)
		assert.is.equal(b.y, -3)
		assert.is.equal(b.z, -4)
		assert.is.equal(b.w,  1)
	end)

	it("tests inverse", function()
		local a = quat(1, 1, 1, 1)
		local b = quat():inverse(a)

		assert.is.equal(b.x, -0.5)
		assert.is.equal(b.y, -0.5)
		assert.is.equal(b.z, -0.5)
		assert.is.equal(b.w,  0.5)
	end)

	it("tests reciprocal", function()
		local a = quat(1, 1, 1, 1)
		local b = quat():reciprocal(a)
		local c = quat():reciprocal(b)

		assert.is.equal(c.x, a.x)
		assert.is.equal(c.y, a.y)
		assert.is.equal(c.z, a.z)
		assert.is.equal(c.w, a.w)
	end)
end)
