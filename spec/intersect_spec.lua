local intersect = require "modules.intersect"

describe("intersect:", function()
end)

--[[
point_triangle(point, triangle)
point_aabb(point, aabb)
point_frustum(point, frustum)
ray_triangle(ray, triangle)
ray_sphere(ray, sphere)
ray_aabb(ray, aabb)
ray_plane(ray, plane)
line_line(a, b)
segment_segment(a, b)
aabb_aabb(a, b)
aabb_obb(aabb, obb)
aabb_sphere(aabb, sphere) -- { position, radius }
aabb_frustum(aabb, frustum)
encapsulate_aabb(outer, inner)
circle_circle(a, b)
sphere_sphere(a, b)
sphere_frustum(sphere, frustum)
--]]