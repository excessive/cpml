--- Various geometric intersections
-- @module intersect

local current_folder = (...):gsub('%.[^%.]+$', '') .. "."
local vec3           = require(current_folder .. "vec3")
local constants      = require(current_folder .. "constants")
local intersect      = {}

-- ray = { position, direction }
-- min = vec3
-- max = vec3
function intersect.ray_aabb(ray, min, max)
	local mmin = math.min
	local mmax = math.max

	-- ray.direction is unit direction vector of ray
	local dir = ray.direction:normalize()
	local dirfrac = vec3(1 / dir.x, 1 / dir.y, 1 / dir.z)

	local t1 = (min.x - ray.position.x) * dirfrac.x
	local t2 = (max.x - ray.position.x) * dirfrac.x
	local t3 = (min.y - ray.position.y) * dirfrac.y
	local t4 = (max.y - ray.position.y) * dirfrac.y
	local t5 = (min.z - ray.position.z) * dirfrac.z
	local t6 = (max.z - ray.position.z) * dirfrac.z

	local tmin = mmax(mmax(mmin(t1, t2), mmin(t3, t4)), mmin(t5, t6))
	local tmax = mmin(mmin(mmax(t1, t2), mmax(t3, t4)), mmax(t5, t6))

	-- if tmax < 0, ray (line) is intersecting AABB, but whole AABB is behind us
	if tmax < 0 then
		return false
	end

	-- if tmin > tmax, ray doesn't intersect AABB
	if tmin > tmax then
		return false
	end

	return true, tmin
end

-- ray = { position, direction }
-- plane = { position, normal }
-- https://www.cs.princeton.edu/courses/archive/fall00/cs426/lectures/raycast/sld017.htm
function intersect.ray_plane(ray, plane)
	-- t = distance of direction
	-- d = distance from ray position to plane position
	-- p = point of intersection

	local d = ray.position:dist(plane.position)
	local r = ray.direction:dot(plane.normal)

	if r <= 0 then
		return false
	end

	local t = -(ray.position:dot(plane.normal) + d) / r
	local p = ray.position + t * ray.direction

	if p:dot(plane.normal) + d < constants.FLT_EPSILON then
		return p
	end

	return false
end

-- http://www.lighthouse3d.com/tutorials/maths/ray-triangle-intersection/
function intersect.ray_triangle(ray, triangle)
	assert(ray.position ~= nil)
	assert(ray.direction ~= nil)
	assert(#triangle == 3)

	local p, d = ray.position, ray.direction

	local h, s, q = vec3(), vec3(), vec3()
	local a, f, u, v

	local e1 = triangle[2] - triangle[1]
	local e2 = triangle[3] - triangle[1]

	h = d:cross(e2)

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

	q = s:cross(e1)
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
-- Archive.org am hero \o/ (https://web.archive.org/web/20120414063459/http://local.wasp.uwa.edu.au/~pbourke//geometry/lineline3d/)
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

	return resultSegmentPoint1, resultSegmentPoint2
end

function intersect.segment_segment(p1, p2, p3, p4)
	local c1, c2 = intersect.line_line(p1, p2, p3, p4)

	if c1 and c2 then
		if  ((p1 <= c1 and c1 <= p2) or (p1 >= c1 and c1 >= p2))
		and ((p3 <= c2 and c2 <= p4) or (p3 >= c2 and c2 >= p4)) then
			return c1, c2
		end
	end
end

-- point is a vec3
-- box.min is a vec3
-- box.max is a vec3
function intersect.point_aabb(point, box)
	return
		box.min.x <= point.x and
		box.max.x >= point.x and
		box.min.y <= point.y and
		box.max.y >= point.y and
		box.min.z <= point.z and
		box.max.z >= point.z
end

-- a.min is a vec3
-- a.max is a vec3
-- b.min is a vec3
-- b.max is a vec3
function intersect.aabb_aabb(a, b)
	return
		a.min.x <= b.max.x and
		b.min.x <= a.max.x and
		a.min.y <= b.max.y and
		b.min.y <= a.max.y and
		a.min.z <= b.max.z and
		b.min.z <= a.max.z
end

-- outer.min is a vec3
-- outer.max is a vec3
-- inner.min is a vec3
-- inner.max is a vec3
function intersect.encapsulate_aabb(outer, inner)
	return
		outer.min <= inner.min and
		outer.max >= inner.max
end

function intersect.circle_circle(c1, c2)
	assert(type(c1.position)  == "table",  "c1 position must be a vector")
	assert(type(c1.radius)    == "number", "c1 radius must be a number")
	assert(type(c2.position)  == "table",  "c2 position must be a vector")
	assert(type(c2.radius)    == "number", "c2 radius must be a number")
	return c1.position:dist(c2.position) <= c1.radius + c2.radius
end

return intersect
