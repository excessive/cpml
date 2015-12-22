local current_folder = (...):gsub('%.[^%.]+$', '') .. "."
local constants      = require(current_folder .. "constants")
local vec3           = require(current_folder .. "vec3")
local ffi            = require "ffi"
local DOT_THRESHOLD  = constants.DOT_THRESHOLD
local FLT_EPSILON    = constants.FLT_EPSILON
local abs            = math.abs
local acos           = math.acos
local asin           = math.asin
local atan2          = math.atan2
local cos            = math.cos
local sin            = math.sin
local min            = math.min
local max            = math.max
local pi             = math.pi
local sqrt           = math.sqrt

ffi.cdef[[
typedef struct {
	double x, y, z, w;
} cpml_quat;
]]

local quat = {}
local cpml_quat = ffi.typeof("cpml_quat")
quat.new = cpml_quat

function quat.identity(out)
	out.x = 0
	out.y = 0
	out.z = 0
	out.w = 1
end

function quat.clone(a)
	local out = quat.new()
	ffi.copy(out, a, ffi.sizeof(cpml_quat))
	return out
end

function quat.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	out.z = a.z + b.z
	out.w = a.w + b.w
end

function quat.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	out.z = a.z - b.z
	out.w = a.w - b.w
end

function quat.mul(out, a, b)
	if type(b) == "table" and b.x and b.y and b.z and b.w then
		out.x = a.x * b.w + a.w * b.x + a.y * b.z - a.z * b.y
		out.y = a.y * b.w + a.w * b.y + a.z * b.x - a.x * b.z
		out.z = a.z * b.w + a.w * b.z + a.x * b.y - a.y * b.x
		out.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
	elseif type(b) == "table" and b.x and b.y and b.z then
		local qv  = vec3(a.x, a.y, a.z)
		local uv, uuv = vec3(), vec3()
		vec3.cross(uv, qv, b)
		vec3.cross(uuv, qv, uv)
		vec3.mul(out, uv, a.w)
		vec3.add(out, out, uuv)
		vec3.mul(out, out, 2)
		vec3.add(out, b, out)
	end
end

function quat.div(out, a, b)
	if type(b) == "number" then
		quat.scale(out, a, 1 / b)
	elseif type(b) == "table" and b.x and b.y and b.z and b.w then
		quat.reciprocal(out, b)
		quat.mul(out, a, out)
	end
end

function quat.pow(out, a, n)
	if n == 0 then
		quat.identity(out)
	elseif n > 0 then
		out.x = a.x^(n-1)
		out.y = a.y^(n-1)
		out.z = a.z^(n-1)
		out.w = a.w^(n-1)
		quat.mul(out, a, out)
	elseif n < 0 then
		quat.reciprocal(out, a)
		out.x = out.x^(-n)
		out.y = out.y^(-n)
		out.z = out.z^(-n)
		out.w = out.w^(-n)
	end
end

function quat.cross(out, a, b)
	out.x = a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y
	out.y = a.w * b.y + a.y * b.w + a.z * b.x - a.x * b.z
	out.z = a.w * b.z + a.z * b.w + a.x * b.y - a.y * b.x
	out.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
end

function quat.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

function quat.normalize(out, a)
	if quat.is_zero(a) then
		error("Cannot normalize a zero-length quaternion.")
		return false
	end

	local l = 1 / quat.len(a)
	quat.scale(out, a, l)
end

function quat.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
end

function quat.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w
end

function quat.lerp(out, a, b, s)
	quat.sub(out, b, a)
	quat.mul(out, out, s)
	quat.add(out, a, out)
	quat.normalize(out, out)
end

function quat.slerp(out, a, b, s)
	local function clamp(n, low, high) return min(max(n, low), high) end
	local dot = quat.dot(a, b)

	if dot < 0 then
		quat.scale(a, a, -1)
		dot = -dot
	end

	if dot > DOT_THRESHOLD then
		quat.lerp(out, a, b, s)
		return
	end

	clamp(dot, -1, 1)
	local temp  = quat.new()
	local theta = acos(dot) * s

	quat.scale(out, a, dot)
	quat.sub(out, b, out)
	quat.normalize(out, out)
	quat.scale(out, out, sin(theta))
	quat.scale(temp, a, cos(theta))
	quat.add(out, temp, out)
end

function quat.rotate(out, angle, axis)
	local len = vec3.len(axis)

	if abs(len - 1) > FLT_EPSILON then
		axis.x = axis.x / len
		axis.y = axis.y / len
		axis.z = axis.z / len
	end

	local s = sin(angle * 0.5)
	local c = cos(angle * 0.5)

	out.x = axis.x * s
	out.y = axis.y * s
	out.z = axis.z * s
	out.w = c
end

function quat.scale(out, a, s)
	out.x = a.x * s
	out.y = a.y * s
	out.z = a.z * s
	out.w = a.w * s
end

function quat.conjugate(out, a)
	out.x = -a.x
	out.y = -a.y
	out.z = -a.z
	out.w = a.w
end

function quat.inverse(out, a)
	quat.conjugate(out, a)
	quat.normalize(out, out)
end

function quat.reciprocal(out, a)
	if quat.is_zero(a) then
		error("Cannot reciprocate a zero-length quaternion.")
		return false
	end

	local l = quat.len2(a)
	quat.conjugate(out, a)
	quat.scale(out, out, 1 / l)
end

function quat.is_zero(a)
	return a.x == 0 and a.y == 0 and a.z == 0 and a.w == 0 then
end

function quat.is_real(a)
	return a.x == 0 and a.y == 0 and a.z == 0 then
end

function quat.is_imaginary(a)
	return a.w == 0 then
end

function quat.real(a)
	return a.w
end

function quat.imaginary(a)
	return vec3(a.x, a.y, a.z)
end

function quat.from_direction(out, normal, up)
	local d = vec3.dot(up, normal)
	local a = vec3()
	vec3.cross(a, up, normal)
	out.x = a.x
	out.y = a.y
	out.z = a.z
	out.w = d + 1
end

function quat.to_angle_axis(a)
	if a.w > 1 or a.w < -1 then
		quat.normalize(a, a)
	end

	local angle = 2 * acos(a.w)
	local s     = sqrt(1 - a.w * a.w)
	local x, y, z

	if s < FLT_EPSILON then
		x = a.x
		y = a.y
		z = a.z
	else
		x = a.x / s
		y = a.y / s
		z = a.z / s
	end

	return angle, vec3(x, y, z)
end

function quat.to_euler(a)
	local sqx = a.x * a.x
	local sqy = a.y * a.y
	local sqz = a.z * a.z
	local sqw = a.w * a.w

	local unit = sqx + sqy + sqz + sqw
	local test = a.x * a.y + a.z * a.w
	local pitch, yaw, roll

	if test > 0.499 * unit then
		pitch = pi / 2
		yaw   = 2 * atan2(a.x, a.w)
		roll  = 0
	elseif test < -0.499 * unit then
		pitch = -pi / 2
		yaw   = -2 * atan2(a.x, a.w)
		roll  = 0
	else
		pitch = asin(2 * test / unit)
		yaw   = atan2(2 * a.y * a.w - 2 * a.x * a.z,  sqx - sqy - sqz + sqw)
		roll  = atan2(2 * a.x * a.w - 2 * a.y * a.z, -sqx + sqy - sqz + sqw)
	end

	return pitch, yaw, roll
end

function quat.unpack(a)
	return a.x, a.y, a.z, a.w
end

function quat.tostring(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z, a.w)
end

local quat_mt = {}

quat_mt.__index = quat
quat_mt.__call = quat.new
quat_mt.__tostring = quat.tostring

function quat_mt.__unm(a)
	local temp = quat.new()
	quat.scale(temp, a, -1)
	return temp
end

function quat_mt.__eq(a,b)
	return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

function quat_mt.__add(a, b)
	local temp = quat.new()
	quat.add(temp, a, b)
	return temp
end

function quat_mt.__mul(a, b)
	local temp = quat.new()
	quat.mul(temp, a, b)
	return temp
end

function quat_mt.__div(a, b)
	local temp = quat.new()
	quat.div(temp, a, b)
	return temp
end

function quat_mt.__pow(a, n)
	local temp = quat.new()
	quat.pow(temp, a, n)
	return temp
end

ffi.metatype(cpml_quat, quat_mt)
return setmetatable({}, quat_mt)
