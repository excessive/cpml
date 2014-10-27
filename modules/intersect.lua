local current_folder = (...):gsub('%.[^%.]+$', '') .. "."
local vec3 = require(current_folder .. "vec3")
local constants = require(current_folder .. "constants")

local intersect = {}

-- http://www.lighthouse3d.com/tutorials/maths/ray-triangle-intersection/
function intersect.ray_triangle(ray, triangle)
	assert(ray.point ~= nil)
	assert(ray.direction ~= nil)
	assert(#triangle == 3)

	local p, d = ray.point, ray.direction

	local h, s, q = vec3(), vec3(), vec3()
	local a, f, u, v

	local e1 = triangle[2] - triangle[1]
	local e2 = triangle[3] - triangle[1]

	h = d:clone():cross(e2)

	a = (e1:dot(h))

	if a > -0.00001 and a < 0.00001 then
		return false
	end

	f = 1/a
	s = p - triangle[1]
	u = f * (s:dot(h))

	if u < 0 or u > 1 then
		return false
	end

	q = s:clone():cross(e1)
	v = f * (d:dot(q))

	if v < 0 or u + v > 1 then
		return false
	end

	-- at this stage we can compute t to find out where
	-- the intersection point is on the line
	t = f * (e2:dot(q))

	if t > constants.FLT_EPSILON then
		return p + t * d -- we've got a hit!
	else
		return false -- the line intersects, but it's behind the point
	end
end

-- Algorithm is ported from the C algorithm of 
-- Paul Bourke at http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline3d/
-- Archive.org am hero \o/
function intersect.line_line(p1, p2, p3, p4)
	local epsilon = constants.FLT_EPSILON
	local resultSegmentPoint1 = vec3(0,0,0)
	local resultSegmentPoint2 = vec3(0,0,0)

	local p13 = p1 - p3
	local p43 = p4 - p3
	local p21 = p2 - p1

	if p43:len2() < epsilon then return false end
	if p21:len2() < epsilon then return false end

	local d1343 = p13.x * p43.x + p13.y * p43.y + p13.z * p43.z
	local d4321 = p43.x * p21.x + p43.y * p21.y + p43.z * p21.z
	local d1321 = p13.x * p21.x + p13.y * p21.y + p13.z * p21.z
	local d4343 = p43.x * p43.x + p43.y * p43.y + p43.z * p43.z
	local d2121 = p21.x * p21.x + p21.y * p21.y + p21.z * p21.z

	local denom = d2121 * d4343 - d4321 * d4321
	if math.abs(denom) < epsilon then return false end
	local numer = d1343 * d4321 - d1321 * d4343

	local mua = numer / denom
	local mub = (d1343 + d4321 * (mua)) / d4343

	resultSegmentPoint1.x = p1.x + mua * p21.x
	resultSegmentPoint1.y = p1.y + mua * p21.y
	resultSegmentPoint1.z = p1.z + mua * p21.z
	resultSegmentPoint2.x = p3.x + mub * p43.x
	resultSegmentPoint2.y = p3.y + mub * p43.y
	resultSegmentPoint2.z = p3.z + mub * p43.z

	return true, resultSegmentPoint1, resultSegmentPoint2
end

return intersect
