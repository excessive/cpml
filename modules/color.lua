local current_folder = (...):gsub('%.[^%.]+$', '') .. "."
local utils = require(current_folder .. "utils")
local color = {}
local function new(r, g, b, a)
	return setmetatable({r or 0, g or 0, b or 0, a or 255}, color)
end
color.__index = color
color.__call = function(_, ...) return new(...) end

function color.invert(c)
	return new(255 - c[1], 255 - c[2], 255 - c[3], c[4])
end

function color.lighten(c, v)
	return new(
		utils.clamp(c[1] + v * 255, 0, 255),
		utils.clamp(c[2] + v * 255, 0, 255),
		utils.clamp(c[3] + v * 255, 0, 255),
		c[4]
	)
end

function color.darken(c, v)
	return new(
		utils.clamp(c[1] - v * 255, 0, 255),
		utils.clamp(c[2] - v * 255, 0, 255),
		utils.clamp(c[3] - v * 255, 0, 255),
		c[4]
	)
end

function color.mul(c, v)
	local t = {}
	for i=1,3 do
		t[i] = c[i] * v
	end
	t[4] = c[4]
	setmetatable(t, color)
	return t
end

-- directly set alpha channel
function color.alpha(c, v)
	local t = {}
	for i=1,3 do
		t[i] = c[i]
	end
	t[4] = v * 255
	setmetatable(t, color)
	return t
end

function color.opacity(c, v)
	local t = {}
	for i=1,3 do
		t[i] = c[i]
	end
	t[4] = c[4] * v
	setmetatable(t, color)
	return t
end

-- HSV utilities (adapted from http://www.cs.rit.edu/~ncs/color/t_convert.html)

-- hsv_to_color(hsv)
-- Converts a set of HSV values to a color. hsv is a table.
-- See also: hsv(h, s, v)
local function hsv_to_color(hsv)
	local i
	local f, q, p, t
	local r, g, b
	local h, s, v
	local a = hsv[4] or 255
	s = hsv[2]
	v = hsv[3]

	if s == 0 then
		return new(v, v, v, a)
	end

	h = hsv[1] / 60

	i = math.floor(h)
	f = h - i
	p = v * (1-s)
	q = v * (1-s*f)
	t = v * (1-s*(1-f))

	if i == 0 then     return new(v, t, p, a)
	elseif i == 1 then return new(q, v, p, a)
	elseif i == 2 then return new(p, v, t, a)
	elseif i == 3 then return new(p, q, v, a)
	elseif i == 4 then return new(t, p, v, a)
	else               return new(v, p, q, a)
	end
end

function color.from_hsv(h, s, v)
	return hsv_to_color { h, s, v, 255 }
end

function color.from_hsva(h, s, v, a)
	return hsv_to_color { h, s, v, a }
end

-- color_to_hsv(c)
-- Takes in a normal color and returns a table with the HSV values.
local function color_to_hsv(c)
	local r = c[1]
	local g = c[2]
	local b = c[3]
	local a = c[4] or 255

	local h = 0
	local s = 0
	local v = 0

	local min = math.min(r, g, b)
	local max = math.max(r, g, b)
	v = max

	local delta = max - min

	-- black, nothing else is really possible here.
	if min == 0 and max == 0 then
		return { 0, 0, 0, a }
	end

	if max ~= 0 then
		s = delta / max
	else
		-- r = g = b = 0 s = 0, v is undefined
		s = 0
		h = -1
		return { h, s, v, 255 }
	end

	if r == max then
		h = ( g - b ) / delta     -- yellow/magenta
	elseif g == max then
		h = 2 + ( b - r ) / delta -- cyan/yellow
	else
		h = 4 + ( r - g ) / delta -- magenta/cyan
	end

	h = h * 60 -- degrees

	if h < 0 then
		h = h + 360
	end

	return { h, s, v, a }
end

function color.hue(color, newHue)
	local c = color_to_hsv(color)
	c[1] = (newHue + 360) % 360
	return hsv_to_color(c)
end

function color.saturation(color, percent)
	local c = color_to_hsv(color)
	c[2] = utils.clamp(percent, 0, 1)
	return hsv_to_color(c)
end

function color.value(color, percent)
	local c = color_to_hsv(color)
	c[3] = utils.clamp(percent, 0, 1)
	return hsv_to_color(c)
end

return setmetatable({new = new}, color)
