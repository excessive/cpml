local mat4  = require "modules.mat4"
local vec3  = require "modules.vec3"
local utils = require "modules.utils"

describe("mat4:", function()
	it("tests new matrices", function()
		local a = mat4()
		assert.is.equal(a[1],  1)
		assert.is.equal(a[2],  0)
		assert.is.equal(a[3],  0)
		assert.is.equal(a[4],  0)
		assert.is.equal(a[5],  0)
		assert.is.equal(a[6],  1)
		assert.is.equal(a[7],  0)
		assert.is.equal(a[8],  0)
		assert.is.equal(a[9],  0)
		assert.is.equal(a[10], 0)
		assert.is.equal(a[11], 1)
		assert.is.equal(a[12], 0)
		assert.is.equal(a[13], 0)
		assert.is.equal(a[14], 0)
		assert.is.equal(a[15], 0)
		assert.is.equal(a[16], 1)
		assert.is_true(a:is_mat4())

		local b = mat4 {
			3, 3, 3, 3,
			4, 4, 4, 4,
			5, 5, 5, 5,
			6, 6, 6, 6
		}
		assert.is.equal(b[1],  3)
		assert.is.equal(b[2],  3)
		assert.is.equal(b[3],  3)
		assert.is.equal(b[4],  3)
		assert.is.equal(b[5],  4)
		assert.is.equal(b[6],  4)
		assert.is.equal(b[7],  4)
		assert.is.equal(b[8],  4)
		assert.is.equal(b[9],  5)
		assert.is.equal(b[10], 5)
		assert.is.equal(b[11], 5)
		assert.is.equal(b[12], 5)
		assert.is.equal(b[13], 6)
		assert.is.equal(b[14], 6)
		assert.is.equal(b[15], 6)
		assert.is.equal(b[16], 6)

		local c = mat4 {
			{ 3, 3, 3, 3 },
			{ 4, 4, 4, 4 },
			{ 5, 5, 5, 5 },
			{ 6, 6, 6, 6 }
		}
		assert.is.equal(c[1],  3)
		assert.is.equal(c[2],  3)
		assert.is.equal(c[3],  3)
		assert.is.equal(c[4],  3)
		assert.is.equal(c[5],  4)
		assert.is.equal(c[6],  4)
		assert.is.equal(c[7],  4)
		assert.is.equal(c[8],  4)
		assert.is.equal(c[9],  5)
		assert.is.equal(c[10], 5)
		assert.is.equal(c[11], 5)
		assert.is.equal(c[12], 5)
		assert.is.equal(c[13], 6)
		assert.is.equal(c[14], 6)
		assert.is.equal(c[15], 6)
		assert.is.equal(c[16], 6)

		local d = mat4 {
			3, 3, 3,
			4, 4, 4,
			5, 5, 5
		}
		assert.is.equal(d[1],  3)
		assert.is.equal(d[2],  3)
		assert.is.equal(d[3],  3)
		assert.is.equal(d[4],  0)
		assert.is.equal(d[5],  4)
		assert.is.equal(d[6],  4)
		assert.is.equal(d[7],  4)
		assert.is.equal(d[8],  0)
		assert.is.equal(d[9],  5)
		assert.is.equal(d[10], 5)
		assert.is.equal(d[11], 5)
		assert.is.equal(d[12], 0)
		assert.is.equal(d[13], 0)
		assert.is.equal(d[14], 0)
		assert.is.equal(d[15], 0)
		assert.is.equal(d[16], 1)

		local e = mat4.identity()
		assert.is.equal(a, e)

		local f = c:clone()
		assert.is.equal(c, f)
	end)

	it("tests multiplication", function()
		do
			local a = mat4 { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }
			local b = mat4 { 1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16 }
			local c = mat4():mul(a, b)
			assert.is.equal(c[1],  30)
			assert.is.equal(c[2],  70)
			assert.is.equal(c[3],  110)
			assert.is.equal(c[4],  150)

			assert.is.equal(c[5],  70)
			assert.is.equal(c[6],  174)
			assert.is.equal(c[7],  278)
			assert.is.equal(c[8],  382)

			assert.is.equal(c[9],  110)
			assert.is.equal(c[10], 278)
			assert.is.equal(c[11], 446)
			assert.is.equal(c[12], 614)

			assert.is.equal(c[13], 150)
			assert.is.equal(c[14], 382)
			assert.is.equal(c[15], 614)
			assert.is.equal(c[16], 846)
		end

		do
			local a = mat4 { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 , 13, 14, 15, 16 }
			local b = { 10, 20, 30, 40 }
			local c = mat4.mul_mat4x1({}, a, b)
			assert.is.equal(c[1],  900)
			assert.is.equal(c[2],  1000)
			assert.is.equal(c[3],  1100)
			assert.is.equal(c[4],  1200)
		end
	end)

	it("tests transforms", function()
		local a = mat4()

		do
			local b = mat4():scale(a, vec3(5, 5, 5))
			assert.is.equal(b[1],  5)
			assert.is.equal(b[6],  5)
			assert.is.equal(b[11], 5)
		end

		do
			local b = mat4():rotate(a, math.rad(45), vec3.unit_z)
			assert.is_true(utils.tolerance( 0.7071-b[1], 0.001))
			assert.is_true(utils.tolerance( 0.7071-b[2], 0.001))
			assert.is_true(utils.tolerance(-0.7071-b[5], 0.001))
			assert.is_true(utils.tolerance( 0.7071-b[6], 0.001))
		end

		do
			local b = mat4():translate(a, vec3(5, 5, 5))
			assert.is.equal(b[13], 5)
			assert.is.equal(b[14], 5)
			assert.is.equal(b[15], 5)
		end
	end)

	it("tests inversion", function()
		local a = mat4()
		a:rotate(a, math.pi/4, vec3.unit_y)
		a:translate(a, vec3(4, 5, 6))

		local b = mat4():invert(a)
		local c = mat4():mul(a, b)
		assert.is.equal(c, mat4())
	end)

	it("tests transpose", function()
		local a = mat4 { 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3 ,3 ,4, 4 ,4 ,4 }
		local b = mat4():transpose(a)
		assert.is.equal(b[1],  1)
		assert.is.equal(b[2],  2)
		assert.is.equal(b[3],  3)
		assert.is.equal(b[4],  4)
		assert.is.equal(b[5],  1)
		assert.is.equal(b[6],  2)
		assert.is.equal(b[7],  3)
		assert.is.equal(b[8],  4)
		assert.is.equal(b[9],  1)
		assert.is.equal(b[10], 2)
		assert.is.equal(b[11], 3)
		assert.is.equal(b[12], 4)
		assert.is.equal(b[13], 1)
		assert.is.equal(b[14], 2)
		assert.is.equal(b[15], 3)
		assert.is.equal(b[16], 4)
	end)

	it("tests projections", function()
		local a  = mat4()
		local b  = mat4.from_perspective(45, 1, 0.1, 1000)
		local v  = vec3(0, 0, 10)
		local vp = { 0, 0, 400, 400 }

		local c  = mat4.project(v, a, b, vp)
		assert.is.equal(c.x, 200)
		assert.is.equal(c.y, 200)
		assert.is_true(utils.tolerance(1.0101-c.z, 0.001))

		local d  = mat4.unproject(c, a, b, vp)
		assert.is_true(utils.tolerance(v.x-d.x, 0.001))
		assert.is_true(utils.tolerance(v.y-d.y, 0.001))
		assert.is_true(utils.tolerance(v.z-d.z, 0.001))
	end)

	it("tests convertions", function()
		local a = mat4()
		local b = mat4 { 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4 }

		local v = a:to_vec4s()
		assert.is_true(type(v)    == "table")
		assert.is_true(type(v[1]) == "table")
		assert.is_true(type(v[2]) == "table")
		assert.is_true(type(v[3]) == "table")
		assert.is_true(type(v[4]) == "table")
		assert.is.equal(v[1][1], 1)
		assert.is.equal(v[1][2], 0)
		assert.is.equal(v[1][3], 0)
		assert.is.equal(v[1][4], 0)
		assert.is.equal(v[2][1], 0)
		assert.is.equal(v[2][2], 1)
		assert.is.equal(v[2][3], 0)
		assert.is.equal(v[2][4], 0)
		assert.is.equal(v[3][1], 0)
		assert.is.equal(v[3][2], 0)
		assert.is.equal(v[3][3], 1)
		assert.is.equal(v[3][4], 0)
		assert.is.equal(v[4][1], 0)
		assert.is.equal(v[4][2], 0)
		assert.is.equal(v[4][3], 0)
		assert.is.equal(v[4][4], 1)

		local q = b:to_quat()
		--assert.is.equal(q.x, 0)
		--assert.is.equal(q.y, 0)
		--assert.is.equal(q.z, 0)
		--assert.is.equal(q.w, 0)
	end)
end)

--[[
	from_angle_axis
	from_direction
	from_transform
	from_ortho
	from_perspective
	from_hmd_perspective
	shear
	look_at
	to_frustum
--]]
