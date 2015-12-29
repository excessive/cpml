--- double 4x4, 1-based, column major matrices
-- @module mat4
local current_folder = (...):gsub('%.[^%.]+$', '') .. "."
local constants = require(current_folder .. "constants")
local vec2 = require(current_folder .. "vec2")
local vec3 = require(current_folder .. "vec3")
local quat = require(current_folder .. "quat")

local mat4 = {}

-- Private constructor.
local function new(m)
	m = m or {
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	}
	m._m = m
	return setmetatable(m, vec3_mt)
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double _m[16]; } cpml_mat4;"
		new = ffi.typeof("cpml_mat4")
	end
end

function mat4.new(v)
	local o = new()
	local m = o._m

	if type(v) == "table" and #v == 16 then
		for i=1,16 do
			m[i] = tonumber(v[i])
		end
	elseif type(v) == "table" and #v == 9 then
		m[1], m[2], m[3] = v[1], v[2], v[3]
		m[5], m[6], m[7] = v[4], v[5], v[6]
		m[9], m[10], m[11] = v[7], v[8], v[9]
		m[16] = 1
	elseif type(v) == "table" and type(v[1]) == "table" then
		local idx = 1
		for i=1, 4 do
			for j=1, 4 do
				m[idx] = v[i][j]
				idx = idx + 1
			end
		end
	else
		m[1] = 1
		m[6] = 1
		m[11] = 1
		m[16] = 1
	end

	return o
end

local temp = mat4.new()

function mat4:clone()
	return new(self._m)
end

function mat4.from_axis_angle(angle, axis)
	if type(angle) == "table" then
		angle, axis = angle:to_axis_angle()
	end
	local l = axis:len()
	if l == 0 then
		return self
	end
	local x, y, z = axis.x / l, axis.y / l, axis.z / l
	local c = math.cos(angle)
	local s = math.sin(angle)
	local m = {
		x*x*(1-c)+c, y*x*(1-c)+z*s, x*z*(1-c)-y*s, 0,
		x*y*(1-c)-z*s, y*y*(1-c)+c, y*z*(1-c)+x*s, 0,
		x*z*(1-c)+y*s, y*z*(1-c)-x*s, z*z*(1-c)+c, 0,
		0, 0, 0, 1,
	}
	return new(m)
end

function mat4.from_direction(direction, up)
	local forward = direction:normalize()
	local side = forward:cross(up):normalize()
	local new_up = side:cross(forward):normalize()

	local view = mat4.new()
	local m = view._m
	m[1]  = side.x
	m[5]  = side.y
	m[9]  = side.z

	m[2]  = new_up.x
	m[6]  = new_up.y
	m[10] = new_up.z

	m[3]  = forward.x
	m[7]  = forward.y
	m[11] = forward.z

	m[16] = 1

	return view
end

function mat4.from_perspective(fovy, aspect, near, far)
	assert(aspect ~= 0)
	assert(near ~= far)

	local t = math.tan(math.rad(fovy) / 2)
	local result = {
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	}

	result[1]  = 1 / (t * aspect)
	result[6]  = 1 / t
	result[11] = -(far + near) / (far - near)
	result[12] = -1
	result[15] = -(2 * far * near) / (far - near)
	result[16] = 1

	return mat4.new(result)
end

function mat4.from_ortho(left, right, top, bottom, near, far)
	local out = mat4.new()
	out[1] = 2 / (right - left)
	out[6] = 2 / (top - bottom)
	out[11] = -2 / (far - near)
	out[13] = -((right + left) / (right - left))
	out[14] = -((top + bottom) / (top - bottom))
	out[15] = -((far + near) / (far - near))
	out[16] = 1
	return out
end

-- Adapted from the Oculus SDK.
function mat4.from_hmd_perspective(tanHalfFov, zNear, zFar, flipZ, farAtInfinity)
	-- CPML is right-handed and intended for GL, so these don't need to be arguments.
	local rightHanded = true
	local isOpenGL    = true
	local function CreateNDCScaleAndOffsetFromFov(tanHalfFov)
		x_scale  = 2 / (tanHalfFov.LeftTan + tanHalfFov.RightTan)
		x_offset =     (tanHalfFov.LeftTan - tanHalfFov.RightTan) * x_scale * 0.5
		y_scale  = 2 / (tanHalfFov.UpTan   + tanHalfFov.DownTan )
		y_offset =     (tanHalfFov.UpTan   - tanHalfFov.DownTan ) * y_scale * 0.5

		local result = {
			Scale  = vec2(x_scale, y_scale),
			Offset = vec2(x_offset, y_offset)
		}

		-- Hey - why is that Y.Offset negated?
		-- It's because a projection matrix transforms from world coords with Y=up,
		-- whereas this is from NDC which is Y=down.
		 return result
	end

	if not flipZ and farAtInfinity then
		print("Error: Cannot push Far Clip to Infinity when Z-order is not flipped")
		farAtInfinity = false
	end

	 -- A projection matrix is very like a scaling from NDC, so we can start with that.
	local scaleAndOffset = CreateNDCScaleAndOffsetFromFov(tanHalfFov)
	local handednessScale = rightHanded and -1.0 or 1.0
	local projection = mat4.new()

	-- Produces X result, mapping clip edges to [-w,+w]
	projection[1] = scaleAndOffset.Scale.x
	projection[2] = 0
	projection[3] = handednessScale * scaleAndOffset.Offset.x
	projection[4] = 0

	-- Produces Y result, mapping clip edges to [-w,+w]
	-- Hey - why is that YOffset negated?
	-- It's because a projection matrix transforms from world coords with Y=up,
	-- whereas this is derived from an NDC scaling, which is Y=down.
	projection[5] = 0
	projection[6] = scaleAndOffset.Scale.y
	projection[7] = handednessScale * -scaleAndOffset.Offset.y
	projection[8] = 0

	-- Produces Z-buffer result - app needs to fill this in with whatever Z range it wants.
	-- We'll just use some defaults for now.
	projection[9]  = 0
	projection[10] = 0

	if farAtInfinity then
		if isOpenGL then
			-- It's not clear this makes sense for OpenGL - you don't get the same precision benefits you do in D3D.
			projection[11] = -handednessScale
			projection[12] = 2.0 * zNear
		else
			projection[11] = 0
			projection[12] = zNear
		end
	else
		if isOpenGL then
			-- Clip range is [-w,+w], so 0 is at the middle of the range.
			projection[11] = -handednessScale * (flipZ and -1.0 or 1.0) * (zNear + zFar) / (zNear - zFar)
			projection[12] = 2.0 * ((flipZ and -zFar or zFar) * zNear) / (zNear - zFar)
		else
			-- Clip range is [0,+w], so 0 is at the start of the range.
			projection[11] = -handednessScale * (flipZ and -zNear or zFar) / (zNear - zFar)
			projection[12] = ((flipZ and -zFar or zFar) * zNear) / (zNear - zFar)
		end
	end

	-- Produces W result (= Z in)
	projection[13] = 0
	projection[14] = 0
	projection[15] = handednessScale
	projection[16] = 0

	return projection:transpose()
end


function mat4.compose_world_matrix(t, rot, scale)
	local angle, axis = rot:to_axis_angle()
	local l = axis:len()

	if l == 0 then
		return self
	end

	local x, y, z = axis.x / l, axis.y / l, axis.z / l
	local c = math.cos(angle)
	local s = math.sin(angle)
	local m = {
		x*x*(1-c)+c, y*x*(1-c)+z*s, x*z*(1-c)-y*s, 0,
		x*y*(1-c)-z*s, y*y*(1-c)+c, y*z*(1-c)+x*s, 0,
		x*z*(1-c)+y*s, y*z*(1-c)-x*s, z*z*(1-c)+c, 0,
		t.x, t.y, t.z, 1,
	}

	return new(m)
end

function mat4:to_quat()
	local m = self:transpose():to_vec4s()

	print(m[1][1], m[2][2], m[3][3])
	local w = math.sqrt(1 + m[1][1] + m[2][2] + m[3][3]) / 2
	local scale = w * 4

	return quat.new(
		m[3][2] - m[2][3] / scale,
		m[1][3] - m[3][1] / scale,
		m[2][1] - m[1][2] / scale,
		w
	):normalize()
end

function mat4.mul(out, a, b)
	out[1] = a[1]*b[1]+a[2]*b[5]+a[3]*b[9]+a[4]*b[13]
	out[2] = a[1]*b[2]+a[2]*b[6]+a[3]*b[10]+a[4]*b[14]
	out[3] = a[1]*b[3]+a[2]*b[7]+a[3]*b[11]+a[4]*b[15]
	out[4] = a[1]*b[4]+a[2]*b[8]+a[3]*b[12]+a[4]*b[16]

	out[5] = a[5]*b[1]+a[6]*b[5]+a[7]*b[9]+a[8]*b[13]
	out[6] = a[5]*b[2]+a[6]*b[6]+a[7]*b[10]+a[8]*b[14]
	out[7] = a[5]*b[3]+a[6]*b[7]+a[7]*b[11]+a[8]*b[15]
	out[8] = a[5]*b[4]+a[6]*b[8]+a[7]*b[12]+a[8]*b[16]

	out[9] = a[9]*b[1]+a[10]*b[5]+a[11]*b[9]+a[12]*b[13]
	out[10] = a[9]*b[2]+a[10]*b[6]+a[11]*b[10]+a[12]*b[14]
	out[11] = a[9]*b[3]+a[10]*b[7]+a[11]*b[11]+a[12]*b[15]
	out[12] = a[9]*b[4]+a[10]*b[8]+a[11]*b[12]+a[12]*b[16]

	out[13] = a[13]*b[1]+a[14]*b[5]+a[15]*b[9]+a[16]*b[13]
	out[14] = a[13]*b[2]+a[14]*b[6]+a[15]*b[10]+a[16]*b[14]
	out[15] = a[13]*b[3]+a[14]*b[7]+a[15]*b[11]+a[16]*b[15]
	out[16] = a[13]*b[4]+a[14]*b[8]+a[15]*b[12]+a[16]*b[16]
	return out
end

function mat4.translate(out, a, t)
	local m = new {
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		t.x, t.y, t.z, 1
	}

	return mat4.mul(out, a, m)
end

function mat4.scale(out, a, s)
	local m = new {
		s.x, 0, 0, 0,
		0, s.y, 0, 0,
		0, 0, s.z, 0,
		0, 0, 0, 1
	}

	return mat4.mul(out, a, m)
end

-- Inverse of matrix. Tested OK
function mat4:invert()
	local out = mat4()

	out[1] = self[6]  * self[11] * self[16] - self[6]  * self[12] * self[15] -
	self[10] * self[7]  * self[16] + self[10] * self[8]  * self[15] + self[14]
	* self[7]  * self[12] - self[14] * self[8]  * self[11]

	out[5] = -self[5]  * self[11] * self[16] + self[5]  * self[12] * self[15] +
	self[9]  * self[7]  * self[16] - self[9]  * self[8]  * self[15] - self[13] *
	self[7]  * self[12] + self[13] * self[8]  * self[11]

	out[9] =  self[5]  * self[10] * self[16] - self[5]  * self[12] * self[14] -
	self[9]  * self[6]  * self[16] + self[9]  * self[8]  * self[14] + self[13] *
	self[6]  * self[12] - self[13] * self[8]  * self[10]

	out[13] = -self[5]  * self[10] * self[15] + self[5]  * self[11] * self[14] +
	self[9]  * self[6]  * self[15] - self[9]  * self[7]  * self[14] - self[13  *
	self[6]  * self[11] + self[13] * self[7]  * self[10]

	out[2] = -self[2]  * self[11] * self[16] + self[2]  * self[12] * self[15]  +
	self[10] * self[3]  * self[16] - self[10] * self[4]  * self[15] - self[14] *
	self[3]  * self[12] +self[14] * self[4]  * self[11]

	out[6] =  self[1]  * self[11] * self[16] - self[1]  * self[12] * self[15] -
	self[9]  * self[3] * self[16] + self[9]  * self[4] * self[15] + self[13] *
	self[3] * self[12] - self[13] * self[4] * self[11]

	out[10] = -self[1]  * self[10] * self[16] + self[1]  * self[12] * self[14] +
	self[9]  * self[2]  * self[16] - self[9]  * self[4]  * self[14] - self[13] *
	self[2]  * self[12] + self[13] * self[4]  * self[10]

	out[14] = self[1]  * self[10] * self[15] - self[1]  * self[11] * self[14] -
	self[9]  * self[2] * self[15] + self[9]  * self[3] * self[14] + self[13] *
	self[2] * self[11] - self[13] * self[3] * self[10]

	out[3] = self[2]  * self[7] * self[16] - self[2]  * self[8] * self[15] -
	self[6]  * self[3] * self[16] + self[6]  * self[4] * self[15] + self[14] *
	self[3] * self[8] - self[14] * self[4] * self[7]

	out[7] = -self[1]  * self[7] * self[16] + self[1]  * self[8] * self[15] +
	self[5]  * self[3] * self[16] - self[5]  * self[4] * self[15] - self[13] *
	self[3] * self[8] + self[13] * self[4] * self[7]

	out[11] = self[1]  * self[6] * self[16] - self[1]  * self[8] * self[14] -
	self[5]  * self[2] * self[16] + self[5]  * self[4] * self[14] + self[13] *
	self[2] * self[8] - self[13] * self[4] * self[6]

	out[15] = -self[1]  * self[6] * self[15] + self[1]  * self[7] * self[14] +
	self[5]  * self[2] * self[15] - self[5]  * self[3] * self[14] - self[13] *
	self[2] * self[7] + self[13] * self[3] * self[6]

	out[4] = -self[2]  * self[7] * self[12] + self[2]  * self[8] * self[11] +
	self[6]  * self[3] * self[12] - self[6]  * self[4] * self[11] - self[10] *
	self[3] * self[8] + self[10] * self[4] * self[7]

	out[8] = self[1] * self[7] * self[12] - self[1] * self[8] * self[11] -
	self[5] * self[3] * self[12] + self[5] * self[4] * self[11] +self[9] *
	self[3] * self[8] - self[9] * self[4] * self[7]

	out[12] = -self[1] * self[6] * self[12] + self[1] * self[8] * self[10] +
	self[5] * self[2] * self[12] - self[5] * self[4] * self[10] - self[9] *
	self[2] * self[8] + self[9] * self[4] * self[6]

	out[16] = self[1] * self[6] * self[11] - self[1] * self[7] * self[10] -
	self[5] * self[2] * self[11] + self[5] * self[3] * self[10] + self[9] *
	self[2] * self[7] - self[9] * self[3] * self[6]

	local det = self[1] * out[1] + self[2] * out[5] + self[3] * out[9] + self[4] * out[13]

	if det == 0 then return self end

	det = 1.0 / det

	for i = 1, 16 do
		out[i] = out[i] * det
	end

	return out
end

function mat4:look_at(eye, center, up)
	local forward = (center - eye):normalize()
	local side = forward:cross(up):normalize()
	local new_up = side:cross(forward):normalize()

	local view = mat4()
	view[1]  = side.x
	view[5]  = side.y
	view[9]  = side.z

	view[2]  = new_up.x
	view[6]  = new_up.y
	view[10] = new_up.z

	view[3]  = -forward.x
	view[7]  = -forward.y
	view[11] = -forward.z

	view[16] = 1

	local out = mat4():translate(-eye - forward) * view
	return out * self
end


function mat4.transpose(out, a)
	return new {
		self[1], self[5], self[9], self[13],
		self[2], self[6], self[10], self[14],
		self[3], self[7], self[11], self[15],
		self[4], self[8], self[12], self[16]
	}
	out[1] = a[1]
	out[2] = a[5]
	out[3] = a[9]
	return mat4(m)
end


function mat4:__eq(b)
	local abs = math.abs
	for i=1, 16 do
		if  then
			return false
		end
	end
	return true
end

function mat4:__tostring()
	local str = "[ "
	for i, v in ipairs(self) do
		str = str .. string.format("%2.5f", v)
		if i < #self then
			str = str .. ", "
		end
	end
	str = str .. " ]"
	return str
end

function mat4:__unm()
	return self:invert()
end

-- Multiply mat4 by a mat4. Tested OK
function mat4:__mul(m)
	if #m == 4 then
		local tmp = matrix_mult_nxn(self:transpose():to_vec4s(), { {m[1]}, {m[2]}, {m[3]}, {m[4]} })
		local v = {}
		for i=1, 4 do
			v[i] = tmp[i][1]
		end
		return v
	end


end

return mat4
