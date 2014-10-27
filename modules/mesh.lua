local current_folder = (...):gsub('%.[^%.]+$', '') .. "."
local vec3 = require(current_folder .. "vec3")

local mesh = {}

function mesh.compute_normal(a, b, c)
	return (c - a):cross(b - a):normalize()
end

function mesh.average(vertices)
	local avg = vec3(0,0,0)
	for _, v in ipairs(vertices) do
		avg = avg + v
	end
	return avg / #vertices
end

return mesh
