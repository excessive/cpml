--- Point module
-- @module point

local current_folder = (...):gsub('%.[^%.]+$', '') .. "."
local point = {}
local function new(x, y)
	return setmetatable({
		x, y
	}, point)
end
point.__index = point
point.__call = function(_, ...) return new(...) end

--- Rotate a point, optionally about another point.
-- @param point Table with two points as {x, y}
-- @param rotation Radian amount to rotate
-- @param[opt=0] offset_x Point to rotate about
-- @param[optchain=0] offset_y offset_y Point to rotatea about
-- @return New point rotated counter-clockwise
function point.rotate(point, rotation, offset_x, offset_y)
	offset_x, offset_y = offset_x or 0, offset_y or 0
	local x, y = unpack(point)
	local distance_x, distance_y = x - offset_x, y - offset_y
	local cos, sin = math.cos(rotation), math.sin(rotation)
	return new(distance_x * cos + offset_x - distance_y * sin, distance_x * sin + distance_y * cos + offset_y)
end

--- Scale a point a point, optionally about another point.
-- @param point Table with two points as {x, y}
-- @param scale Number or Table in the form of scale or {scaleX [, scaleY=scaleX]}
-- @param[opt=0] offset_x Point to scale about
-- @param[optchain=0] offset_y Point to scale about
-- @return New scaled point
function point.scale(point, scale, offset_x, offset_y)
	local scale_x, scale_y
	if type( scale ) == 'table' then
		scale_x, scale_y = unpack(scale)
		scale_y = scale_y or scale_x
	elseif type( scale ) == 'number' then
		scale_x, scale_y = scale, scale
	end
	offset_x, offset_y = offset_x or 0, offset_y or 0
	local x, y = unpack(point)
	return new((x - offset_x) * scale_x + offset_x, (y - offset_y) * scale_y + offset_y)
end

--- Translate a point.
-- @param point Table with two points as {x, y}
-- @param distance_x Distance to translate along the x-axis
-- @param distance_y Distance to translate along the y-axis
-- @return Translated point
function point.translate(point, distance_x, distance_y)
	return new(point[1] + distance_x, point[2] + distance_y)
end

--- Print point.
-- @param point Table with two numbers as {x, y}
-- @return "[ x, y ]"
function point.__tostring(point)
	return string.format( "[ f, f ]", point[1], point[2] )
end

--- Add points.
-- @param p1 Table with two numbers as {x, y}
-- @param p2 Table with two numbers as {x, y}
-- @return Translated point
function point.__add(p1, p2)
	return p1:translate(p1, p2[1], p2[2])
end

--- Subtract points.
-- @param p1 Table with two numbers as {x, y}
-- @param p2 Table with two numbers as {x, y}
-- @return Translated point
function point.__sub(p1, p2)
	return p1:translate(p1, -p2[1], -p2[2])
end

--- Multiply points.
-- @param p1 Table with two numbers as {x, y}
-- @param scale Amount to scale
-- @return Scaled point
function point.__mul(p1, scale)
	return p1:scale(scale)
end

--- Convert point from polar to cartesian.
-- @param radius Radius of the point
-- @param theta Angle of the point
-- @param[opt=0] offset_radius Distance from origin
-- @param[optchain=0] offset_theta Angle for offset
-- @return Converted point
function point.from_polar(radius, theta, offset_radius, offset_theta)
	local offset_x, offset_y = 0, 0
	if offset_radius and offset_theta then
		offset_x, offset_y = point.from_polar(offset_radius, offset_theta)
	end
	return new(radius * math.cos(theta) + offset_x, radius * math.sin(theta) + offset_y)
end

--- Convert point from cartesian to polar.
-- @param point Table with two numbers as {x, y}
-- @param[opt=0] offset_x Horizontal offset
-- @param[optchain=0] offset_y Vertical offset
-- @return Table in the form {radius, theta}
function point.to_polar(point, offset_x, offset_y)
	local offset_x, offset_y = offset_x or 0, offset_y or 0
	local x, y = point[1] - offset_x, point[2] - offset_y
	local theta = math.atan2(y, x)
	-- Convert to absolute angle
	theta = theta > 0 and theta or theta + 2 * math.pi
	local radius = math.sqrt(x ^ 2 + y ^ 2)
	return {radius, theta}
end

return setmetatable({new = new}, point)
