--- double 4x4, 1-based, column major matrices
-- @module mat4
local modules   = (...):gsub('%.[^%.]+$', '') .. "."
local constants = require(modules .. "constants")
local vec2      = require(modules .. "vec2")
local vec3      = require(modules .. "vec3")
local quat      = require(modules .. "quat")
local sqrt      = math.sqrt
local cos       = math.cos
local sin       = math.sin
local tan       = math.tan
local rad       = math.rad
local mat4      = {}

-- Private constructor.
local function new(m)
	m = m or {
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	}
	m._m = m
	return setmetatable(m, mat4_mt)
end

local function identity(m)
	m[1],  m[2],  m[3],  m[4]  = 1, 0, 0, 0
	m[5],  m[6],  m[7],  m[8]  = 0, 1, 0, 0
	m[9],  m[10], m[11], m[12] = 0, 0, 1, 0
	m[13], m[14], m[15], m[16] = 0, 0, 0, 1
	return m
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

-- Statically allocate a temporary variable used in some of our functions.
local tmp = new()

function mat4.new(a)
	local o = new()
	local m = o._m

	if type(a) == "table" and #a == 16 then
		for i=1,16 do
			m[i] = tonumber(a[i])
		end
	elseif type(a) == "table" and #a == 9 then
		m[1], m[2],  m[3]  = a[1], a[2], a[3]
		m[5], m[6],  m[7]  = a[4], a[5], a[6]
		m[9], m[10], m[11] = a[7], a[8], a[9]
		m[16] = 1
	elseif type(a) == "table" and type(a[1]) == "table" then
		local idx = 1
		for i = 1, 4 do
			for j = 1, 4 do
				m[idx] = a[i][j]
				idx = idx + 1
			end
		end
	else
		m[1]  = 1
		m[6]  = 1
		m[11] = 1
		m[16] = 1
	end

	return o
end

function mat4.identity()
	return identity(new())
end

function mat4.from_angle_axis(angle, axis)
	if type(angle) == "table" then
		angle, axis = angle:to_angle_axis()
	end

	local l = axis:len()
	if l == 0 then
		return new()
	end

	local x, y, z = axis.x / l, axis.y / l, axis.z / l
	local c = cos(angle)
	local s = sin(angle)

	return new {
		x*x*(1-c)+c,   y*x*(1-c)+z*s, x*z*(1-c)-y*s, 0,
		x*y*(1-c)-z*s, y*y*(1-c)+c,   y*z*(1-c)+x*s, 0,
		x*z*(1-c)+y*s, y*z*(1-c)-x*s, z*z*(1-c)+c,   0,
		0, 0, 0, 1
	}
end

function mat4.from_direction(direction, up)
	local forward = vec3():normalize(direction)

	local side = vec3()
		:cross(forward, up)
		:normalize(side)

	local new_up = vec3()
		:cross(side, forward)
		:normalize(new_up)

	local out = new()
	out[1]    = side.x
	out[5]    = side.y
	out[9]    = side.z
	out[2]    = new_up.x
	out[6]    = new_up.y
	out[10]   = new_up.z
	out[3]    = forward.x
	out[7]    = forward.y
	out[11]   = forward.z
	out[16]   = 1

	return out
end

function mat4.from_transform(trans, rot, scale)
	local angle, axis = rot:to_angle_axis()
	local l = axis:len()

	if l == 0 then
		return new()
	end

	local x, y, z = axis.x / l, axis.y / l, axis.z / l
	local c = cos(angle)
	local s = sin(angle)

	return new {
		x*x*(1-c)+c,   y*x*(1-c)+z*s, x*z*(1-c)-y*s, 0,
		x*y*(1-c)-z*s, y*y*(1-c)+c,   y*z*(1-c)+x*s, 0,
		x*z*(1-c)+y*s, y*z*(1-c)-x*s, z*z*(1-c)+c,   0,
		trans.x, trans.y, trans.z, 1
	}
end

function mat4.from_ortho(left, right, top, bottom, near, far)
	local out = new()
	out[1]    =  2 / (right - left)
	out[6]    =  2 / (top - bottom)
	out[11]   = -2 / (far - near)
	out[13]   = -((right + left) / (right - left))
	out[14]   = -((top + bottom) / (top - bottom))
	out[15]   = -((far + near) / (far - near))
	out[16]   =  1

	return out
end

function mat4.from_perspective(fovy, aspect, near, far)
	assert(aspect ~= 0)
	assert(near   ~= far)

	local t   = tan(rad(fovy) / 2)
	local out = new()
	out[1]    =  1 / (t * aspect)
	out[6]    =  1 / t
	out[11]   = -(far + near) / (far - near)
	out[12]   = -1
	out[15]   = -(2 * far * near) / (far - near)
	out[16]   =  1

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
	local scaleAndOffset  = CreateNDCScaleAndOffsetFromFov(tanHalfFov)
	local handednessScale = rightHanded and -1.0 or 1.0
	local projection      = new()

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

	return projection:transpose(projection)
end

function mat4.clone(a)
	return new(a)
end

function mat4.mul(out, a, b)
	out[1]  = a[1]  * b[1] + a[2]  * b[5] + a[3]  * b[9]  + a[4]  * b[13]
	out[2]  = a[1]  * b[2] + a[2]  * b[6] + a[3]  * b[10] + a[4]  * b[14]
	out[3]  = a[1]  * b[3] + a[2]  * b[7] + a[3]  * b[11] + a[4]  * b[15]
	out[4]  = a[1]  * b[4] + a[2]  * b[8] + a[3]  * b[12] + a[4]  * b[16]
	out[5]  = a[5]  * b[1] + a[6]  * b[5] + a[7]  * b[9]  + a[8]  * b[13]
	out[6]  = a[5]  * b[2] + a[6]  * b[6] + a[7]  * b[10] + a[8]  * b[14]
	out[7]  = a[5]  * b[3] + a[6]  * b[7] + a[7]  * b[11] + a[8]  * b[15]
	out[8]  = a[5]  * b[4] + a[6]  * b[8] + a[7]  * b[12] + a[8]  * b[16]
	out[9]  = a[9]  * b[1] + a[10] * b[5] + a[11] * b[9]  + a[12] * b[13]
	out[10] = a[9]  * b[2] + a[10] * b[6] + a[11] * b[10] + a[12] * b[14]
	out[11] = a[9]  * b[3] + a[10] * b[7] + a[11] * b[11] + a[12] * b[15]
	out[12] = a[9]  * b[4] + a[10] * b[8] + a[11] * b[12] + a[12] * b[16]
	out[13] = a[13] * b[1] + a[14] * b[5] + a[15] * b[9]  + a[16] * b[13]
	out[14] = a[13] * b[2] + a[14] * b[6] + a[15] * b[10] + a[16] * b[14]
	out[15] = a[13] * b[3] + a[14] * b[7] + a[15] * b[11] + a[16] * b[15]
	out[16] = a[13] * b[4] + a[14] * b[8] + a[15] * b[12] + a[16] * b[16]

	return out
end

function mat4.mul_mat4x1(out, a, b)
	out[1] = b[1] * a[1] + b[2] * a[5] + b [3] * a[9]  + b[4] * a[13]
	out[2] = b[1] * a[2] + b[2] * a[6] + b [3] * a[10] + b[4] * a[14]
	out[3] = b[1] * a[3] + b[2] * a[7] + b [3] * a[11] + b[4] * a[15]
	out[4] = b[1] * a[4] + b[2] * a[8] + b [3] * a[12] + b[4] * a[16]

	return out
end

function mat4.invert(out, a)
	out[1]  =  a[6] * a[11] * a[16] - a[6] * a[12] * a[15] - a[10] * a[7] * a[16] + a[10] * a[8] * a[15] + a[14] * a[7] * a[12] - a[14] * a[8] * a[11]
	out[2]  = -a[2] * a[11] * a[16] + a[2] * a[12] * a[15] + a[10] * a[3] * a[16] - a[10] * a[4] * a[15] - a[14] * a[3] * a[12] + a[14] * a[4] * a[11]
	out[3]  =  a[2] * a[7]  * a[16] - a[2] * a[8]  * a[15] - a[6]  * a[3] * a[16] + a[6]  * a[4] * a[15] + a[14] * a[3] * a[8]  - a[14] * a[4] * a[7]
	out[4]  = -a[2] * a[7]  * a[12] + a[2] * a[8]  * a[11] + a[6]  * a[3] * a[12] - a[6]  * a[4] * a[11] - a[10] * a[3] * a[8]  + a[10] * a[4] * a[7]
	out[5]  = -a[5] * a[11] * a[16] + a[5] * a[12] * a[15] + a[9]  * a[7] * a[16] - a[9]  * a[8] * a[15] - a[13] * a[7] * a[12] + a[13] * a[8] * a[11]
	out[6]  =  a[1] * a[11] * a[16] - a[1] * a[12] * a[15] - a[9]  * a[3] * a[16] + a[9]  * a[4] * a[15] + a[13] * a[3] * a[12] - a[13] * a[4] * a[11]
	out[7]  = -a[1] * a[7]  * a[16] + a[1] * a[8]  * a[15] + a[5]  * a[3] * a[16] - a[5]  * a[4] * a[15] - a[13] * a[3] * a[8]  + a[13] * a[4] * a[7]
	out[8]  =  a[1] * a[7]  * a[12] - a[1] * a[8]  * a[11] - a[5]  * a[3] * a[12] + a[5]  * a[4] * a[11] + a[9]  * a[3] * a[8]  - a[9]  * a[4] * a[7]
	out[9]  =  a[5] * a[10] * a[16] - a[5] * a[12] * a[14] - a[9]  * a[6] * a[16] + a[9]  * a[8] * a[14] + a[13] * a[6] * a[12] - a[13] * a[8] * a[10]
	out[10] = -a[1] * a[10] * a[16] + a[1] * a[12] * a[14] + a[9]  * a[2] * a[16] - a[9]  * a[4] * a[14] - a[13] * a[2] * a[12] + a[13] * a[4] * a[10]
	out[11] =  a[1] * a[6]  * a[16] - a[1] * a[8]  * a[14] - a[5]  * a[2] * a[16] + a[5]  * a[4] * a[14] + a[13] * a[2] * a[8]  - a[13] * a[4] * a[6]
	out[12] = -a[1] * a[6]  * a[12] + a[1] * a[8]  * a[10] + a[5]  * a[2] * a[12] - a[5]  * a[4] * a[10] - a[9]  * a[2] * a[8]  + a[9]  * a[4] * a[6]
	out[13] = -a[5] * a[10] * a[15] + a[5] * a[11] * a[14] + a[9]  * a[6] * a[15] - a[9]  * a[7] * a[14] - a[13] * a[6] * a[11] + a[13] * a[7] * a[10]
	out[14] =  a[1] * a[10] * a[15] - a[1] * a[11] * a[14] - a[9]  * a[2] * a[15] + a[9]  * a[3] * a[14] + a[13] * a[2] * a[11] - a[13] * a[3] * a[10]
	out[15] = -a[1] * a[6]  * a[15] + a[1] * a[7]  * a[14] + a[5]  * a[2] * a[15] - a[5]  * a[3] * a[14] - a[13] * a[2] * a[7]  + a[13] * a[3] * a[6]
	out[16] =  a[1] * a[6]  * a[11] - a[1] * a[7]  * a[10] - a[5]  * a[2] * a[11] + a[5]  * a[3] * a[10] + a[9]  * a[2] * a[7]  - a[9]  * a[3] * a[6]

	local det = a[1] * out[1] + a[2] * out[5] + a[3] * out[9] + a[4] * out[13]

	if det == 0 then return a end

	det = 1 / det

	for i = 1, 16 do
		out[i] = out[i] * det
	end

	return out
end

function mat4.scale(out, a, s)
	identity(tmp)
	tmp[1]  = s.x
	tmp[6]  = s.y
	tmp[11] = s.z

	return out:mul(tmp, a)
end

function mat4.rotate(out, a, angle, axis)
	if type(angle) == "table" then
		angle, axis = angle:to_angle_axis()
	end

	local l = axis:len()

	if l == 0 then
		return a
	end

	local x, y, z = axis.x / l, axis.y / l, axis.z / l
	local c = cos(angle)
	local s = sin(angle)

	identity(tmp)
	tmp[1]  = x * x * (1 - c) + c
	tmp[2]  = y * x * (1 - c) + z * s
	tmp[3]  = x * z * (1 - c) - y * s
	tmp[5]  = x * y * (1 - c) - z * s
	tmp[6]  = y * y * (1 - c) + c
 	tmp[7]  = y * z * (1 - c) + x * s
	tmp[9]  = x * z * (1 - c) + y * s
	tmp[10] = y * z * (1 - c) - x * s
	tmp[11] = z * z * (1 - c) + c

	return out:mul(a, tmp)
end

function mat4.translate(out, a, t)
	identity(tmp)
	tmp[13] = t.x
	tmp[14] = t.y
	tmp[15] = t.z

	return out:mul(tmp, a)
end

function mat4.shear(out, a, yx, zx, xy, zy, xz, yz)
	identity(tmp)
	tmp[2]  = yx or 0
	tmp[3]  = zx or 0
	tmp[5]  = xy or 0
	tmp[7]  = zy or 0
	tmp[9]  = xz or 0
	tmp[10] = yz or 0

	return out:mul(tmp, a)
end

function mat4.look_at(out, a, eye, center, up)
	local forward = vec3():normalize(center - eye)

	local side = vec3()
		:cross(forward, up)
		:normalize(side)

	local new_up = vec3()
		:cross(side, forward)
		:normalize(new_up)

	identity(tmp)
	local view = tmp

	view[1]  =  side.x
	view[5]  =  side.y
	view[9]  =  side.z
	view[2]  =  new_up.x
	view[6]  =  new_up.y
	view[10] =  new_up.z
	view[3]  = -forward.x
	view[7]  = -forward.y
	view[11] = -forward.z

	return out
		:translate(-eye - forward)
		:mul(out, view)
		:mul(out, a)
end

function mat4.transpose(out, a)
	out[1]  = a[1]
	out[2]  = a[5]
	out[3]  = a[9]
	out[4]  = a[13]
	out[5]  = a[2]
	out[6]  = a[6]
	out[7]  = a[10]
	out[8]  = a[14]
	out[9]  = a[3]
	out[10] = a[7]
	out[11] = a[11]
	out[12] = a[15]
	out[13] = a[4]
	out[14] = a[8]
	out[15] = a[12]
	out[16] = a[16]

	return out
end

-- https://github.com/g-truc/glm/blob/master/glm/gtc/matrix_transform.inl#L317
-- Note: GLM calls the view matrix "model"
function mat4.project(obj, view, projection, viewport)
	local position = { obj.x, obj.y, obj.z, 1 }

	identity(tmp)
	mat4.mul_mat4x1(position, tmp:transpose(view),       position)
	mat4.mul_mat4x1(position, tmp:transpose(projection), position)

	position[1] = position[1] / position[4] * 0.5 + 0.5
	position[2] = position[2] / position[4] * 0.5 + 0.5
	position[3] = position[3] / position[4] * 0.5 + 0.5
	position[4] = position[4] / position[4] * 0.5 + 0.5

	position[1] = position[1] * viewport[3] + viewport[1]
	position[2] = position[2] * viewport[4] + viewport[2]

	return vec3(position[1], position[2], position[3])
end

-- https://github.com/g-truc/glm/blob/master/glm/gtc/matrix_transform.inl#L338
-- Note: GLM calls the view matrix "model"
function mat4.unproject(win, view, projection, viewport)
	local position = { win.x, win.y, win.z, 1 }

	position[1] = (position[1] - viewport[1]) / viewport[3]
	position[2] = (position[2] - viewport[2]) / viewport[4]

	position[1] = position[1] * 2 - 1
	position[2] = position[2] * 2 - 1
	position[3] = position[3] * 2 - 1
	position[4] = position[4] * 2 - 1

	identity(tmp)
	tmp:mul(view, projection):invert(tmp)
	mat4.mul_mat4x1(position, tmp, position)

	position[1] = position[1] / position[4]
	position[2] = position[2] / position[4]
	position[3] = position[3] / position[4]

	return vec3(position[1], position[2], position[3])
end

function mat4.is_mat4(a)
	if not type(a) == "table" and not type(a) == "cdata" then
		return false
	end

	for i = 1, 16 do
		if type(a[i]) ~= "number" then
			return false
		end
	end

	return true
end

function mat4.to_string()
	local str = "[ "
	for i, v in ipairs(a) do
		str = str .. string.format("%+0.3f", v)
		if i < #a then
			str = str .. ", "
		end
	end
	str = str .. " ]"
	return str
end

function mat4.to_vec4s(a)
	return {
		{ a[1],  a[2],  a[3],  a[4]  },
		{ a[5],  a[6],  a[7],  a[8]  },
		{ a[9],  a[10], a[11], a[12] },
		{ a[13], a[14], a[15], a[16] }
	}
end

function mat4.to_quat(a)
	identity(tmp):transpose(a)

	local w     = sqrt(1 + m[1] + m[6] + m[11]) / 2
	local scale = w * 4
	local q     = quat.new(
		m[10] - m[7] / scale,
		m[3]  - m[9] / scale,
		m[5]  - m[2] / scale,
		w
	)

	return q:normalize(q)
end

-- frustum = (proj * view):to_frustum(infinite)
-- http://www.crownandcutlass.com/features/technicaldetails/frustum.html
function mat4.to_frustum(a, infinite)
	local t
	local frustum = {}

	-- Extract the TOP plane
	frustum.top = {}
	frustum.top.a = a[ 4] - a[ 2]
	frustum.top.b = a[ 8] - a[ 6]
	frustum.top.c = a[12] - a[10]
	frustum.top.d = a[16] - a[14]

	-- Normalize the result
	t = sqrt(frustum.top.a * frustum.top.a + frustum.top.b * frustum.top.b + frustum.top.c * frustum.top.c)
	frustum.top.a = frustum.top.a / t
	frustum.top.b = frustum.top.b / t
	frustum.top.c = frustum.top.c / t
	frustum.top.d = frustum.top.d / t

	-- Extract the BOTTOM plane
	frustum.bottom = {}
	frustum.bottom.a = a[ 4] + a[ 2]
	frustum.bottom.b = a[ 8] + a[ 6]
	frustum.bottom.c = a[12] + a[10]
	frustum.bottom.d = a[16] + a[14]

	-- Normalize the result
	t = sqrt(frustum.bottom.a * frustum.bottom.a + frustum.bottom.b * frustum.bottom.b + frustum.bottom.c * frustum.bottom.c)
	frustum.bottom.a = frustum.bottom.a / t
	frustum.bottom.b = frustum.bottom.b / t
	frustum.bottom.c = frustum.bottom.c / t
	frustum.bottom.d = frustum.bottom.d / t

	-- Extract the LEFT plane
	frustum.left.a = a[ 4] + a[ 1]
	frustum.left.b = a[ 8] + a[ 5]
	frustum.left.c = a[12] + a[ 9]
	frustum.left.d = a[16] + a[13]

	-- Normalize the result
	t = sqrt(frustum.left.a * frustum.left.a + frustum.left.b * frustum.left.b + frustum.left.c * frustum.left.c)
	frustum.left.a = frustum.left.a / t
	frustum.left.b = frustum.left.b / t
	frustum.left.c = frustum.left.c / t
	frustum.left.d = frustum.left.d / t

	-- Extract the RIGHT plane
	frustum.right = {}
	frustum.right.a = a[ 4] - a[ 1]
	frustum.right.b = a[ 8] - a[ 5]
	frustum.right.c = a[12] - a[ 9]
	frustum.right.d = a[16] - a[13]

	-- Normalize the result
	t = sqrt(frustum.right.a * frustum.right.a + frustum.right.b * frustum.right.b + frustum.right.c * frustum.right.c)
	frustum.right.a = frustum.right.a / t
	frustum.right.b = frustum.right.b / t
	frustum.right.c = frustum.right.c / t
	frustum.right.d = frustum.right.d / t

	-- Extract the NEAR plane
	frustum.near = {}
	frustum.near.a = a[ 4] + a[ 3]
	frustum.near.b = a[ 8] + a[ 7]
	frustum.near.c = a[12] + a[11]
	frustum.near.d = a[16] + a[15]

	-- Normalize the result
	t = sqrt(frustum.near.a * frustum.near.a + frustum.near.b * frustum.near.b + frustum.near.c * frustum.near.c)
	frustum.near.a = frustum.near.a / t
	frustum.near.b = frustum.near.b / t
	frustum.near.c = frustum.near.c / t
	frustum.near.d = frustum.near.d / t

	if not infinite then
		-- Extract the FAR plane
		frustum.far = {}
		frustum.far.a = a[ 4] - a[ 3]
		frustum.far.b = a[ 8] - a[ 7]
		frustum.far.c = a[12] - a[11]
		frustum.far.d = a[16] - a[15]

		-- Normalize the result
		t = sqrt(frustum.far.a * frustum.far.a + frustum.far.b * frustum.far.b + frustum.far.c * frustum.far.c)
		frustum.far.a = frustum.far.a / t
		frustum.far.b = frustum.far.b / t
		frustum.far.c = frustum.far.c / t
		frustum.far.d = frustum.far.d / t
	end

	return frustum
end

local mat4_mt      = {}
mat4_mt.__index    = mat4
mat4_mt.__tostring = mat4.to_string

function mat4_mt.__call(_, a)
	return mat4.new(a)
end

function mat4_mt.__unm(a)
	return new():invert(a)
end

function mat4_mt.__eq(a, b)
	assert(mat4.is_mat4(a), "__eq: Wrong argument type for left hand operant. (<cpml.mat4> expected)")
	assert(mat4.is_mat4(b), "__eq: Wrong argument type for right hand operant. (<cpml.mat4> expected)")

	for i = 1, 16 do
		if a[i] ~= b[i] then
			return false
		end
	end

	return true
end

function mat4_mt.__mul(a, b)
	assert(mat4.is_mat4(a), "__mul: Wrong argument type for left hand operant. (<cpml.mat4> expected)")
	assert(mat4.is_mat4(b) or #b == 4, "__mul: Wrong argument type for right hand operant. (<cpml.mat4> or table #4 expected)")

	if mat4.is_mat4(b) then
		return new():mul(a, b)
	end

	return mat4.mul_mat4x1({}, a, b)
end

if status then
	ffi.metatype(new, mat4_mt)
end

return setmetatable({}, mat4_mt)
