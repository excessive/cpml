-- Preconditions for cpml functions.
local precond = {}


function precond.typeof(t, expected, msg)
	if type(t) ~= expected then
		error(("%s: %s (<%s> expected)"):format(msg, type(t), expected), 3)
	end
end

function precond.assert(cond, msg, ...)
	if not cond then
		error(msg:format(...), 3)
	end
end

return precond
