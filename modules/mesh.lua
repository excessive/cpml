--- Mesh utilities
-- @module mesh

local modules = (...):gsub('%.[^%.]+$', '') .. "."
local vec3    = require(modules .. "vec3")
local mesh    = {}

function mesh.compute_normal(a, b, c)
	local out = vec3()
	local ca  = vec3.sub(vec3(), c, a)
	local ba  = vec3.sub(vec3(), b, a)
	vec3.cross(out, ca, ba)
	vec3.normalize(out, out)
	return out
end

function mesh.average(vertices)
	local out = vec3(0, 0, 0)
	for _, v in ipairs(vertices) do
		vec3.add(out, out, v)
	end
	return vec3.div(out, out, #vertices)
end

return mesh
