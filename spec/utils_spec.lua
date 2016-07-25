local utils     = require "modules.utils"
local constants = require "modules.constants"

describe("utils:", function()
end)

--[[
clamp(value, min, max)
deadzone(value, size)
threshold(value, threshold)
tolerance(value, threshold)
map(value, min_in, max_in, min_out, max_out)
lerp(progress, low, high)
smoothstep(progress, low, high)
round(value, precision)
wrap(value, limit)
is_pot(value)
project_on(out, a, b)
project_from(out, a, b)
mirror_on(out, a, b)
reflect(out, i, n)
refract(out, i, n, ior)
angle_to(a, b)
angle_between(a, b)
--]]