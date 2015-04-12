-- based on a gist from mentlerd
-- https://gist.github.com/mentlerd/4587030
local octree = {}

octree.__index = octree

function new()
  local t = { 
		root = {
			size = 1, 
		
			x = 0,
			y = 0,
			z = 0
		}
	}
	setmetatable(t, octree)
	return t
end

-- Tree metatable
function octree:expand_if_needed(x, y, z)
	local root = self.root

	local size = root.size
	
	-- Relative coordinates
	local rX = x - root.x
	local rY = y - root.y
	local rZ = z - root.z
	
	-- Out of bounds marks
	local xPos = rX >= size
	local xNeg = rX < -size
	
	local yPos = rY >= size
	local yNeg = rY < -size
	
	local zPos = rZ >= size
	local zNeg = rZ < -size
	
	-- Check if the point is in the bounds
	if xPos or xNeg or
		yPos or yNeg or
		zPos or zNeg then
		
		-- Change the root node to fit
		local node = {
			size = size * 2,
			
			x = 0,
			y = 0,
			z = 0
		}

		local index = 0
		
		-- Offset the new root, and place the old into it
		if rX >= 0 then node.x = root.x + size end
		if rY >= 0 then node.y = root.y + size end
		if rZ >= 0 then node.z = root.z + size end
		
		if rX < 0 then
			node.x = root.x - size
			index = index + 1
		end
		if rY < 0 then
			node.y = root.y - size
			index = index + 2
		end
		if rZ < 0 then
			node.z = root.z - size
			index = index + 4
		end

		node[index] = root

		-- Erase previous root information
		root.size = nil
		root.x = nil
		root.y = nil
		root.z = nil
		
		-- Set the new root
		self.root = node
		
		-- Repeat until the size is sufficient
		self:expand_if_needed(x, y, z)
	end
end

function octree:get(x, y, z)
	self:expand_if_needed(x, y, z)
	
	-- Convert the coordinates relative to the root
	local node = self.root
	local size = node.size
	
	local rX = x - node.x
	local rY = y - node.y
	local rZ = z - node.z
	
	while true do
		size = size / 2

		local index = 0
			
		-- Seek, and offset the point for the next node
		if rX >= 0 then 
			index = index + 1
			rX = rX - size 
		else
			rX = rX + size
		end
				
		if rY >= 0 then
			index = index + 2 
			rY = rY - size
		else
			rY = rY + size
		end
		
		if rZ >= 0 then 
			index = index + 4 
			rZ = rZ - size 
		else
			rZ = rZ + size
		end
		
		-- Get the node/value at the calculated index
		local child = node[index]
		
		if type(child) ~= "table" then	
			return child
		end
		
		-- We must go deeper!
		node = child
	end
end

local function merge_if_possible(stack, path, ref)

	for i = #stack, 1, -1 do
		local node = stack[i]
		
		-- Check if every value is the same in the node		
		for x = 0, 7, 1 do
			if ref ~= node[x] then
				-- Break if any is not
				return
			end
		end
		
		-- Successful merge
		stack[i -1][path[i]] = ref
	end

end

function octree:set(x, y, z, value)
	self:expand_if_needed(x, y, z)
	
	-- Convert the coordinates relative to the root
	local node = self.root
	local size = node.size
	
	local rX = x - node.x
	local rY = y - node.y
	local rZ = z - node.z
	
	local stack = {}
	local path = {}
	
	while true do	
		size = size / 2

		local index = 0
		
		if rX >= 0 then 
			index = index + 1
			rX = rX - size
		else
			rX = rX + size
		end

		if rY >= 0 then
			index = index + 2 
			rY = rY - size
		else
			rY = rY + size
		end
		
		if rZ >= 0 then 
			index = index + 4
			rZ = rZ - size
		else
			rZ = rZ + size
		end
		
		table.insert(stack, node)
		table.insert(path, index)
		
		-- Get the node/value at the calculated index
		local child = node[index]
		
		if type(child) ~= "table" then
			if (child ~= value) then
				-- No node/value present
				if child == nil then
					-- If the size is not 1, it needs further populating,
					-- Otherwise, it just needs a value
					if size ~= 0.5 then				
						child = {}
						node[index] = child
					else						
						node[index] = value
						
						merge_if_possible(stack, path, value)
						return
					end
				else
					-- There is a node, but its value does not match, divide it
					-- If the size is over 1, otherwise, just set the value
					if size ~= 0.5 then						
						local split = {
							child, child, child, child, 
							child, child, child, child
						}
						
						child = split
						node[index] = split
					else					
						-- Hit a real leaf, set the value and walk away
						node[index] = value
						
						merge_if_possible(stack, path, value)
						return
					end
				end
			else
				-- This treenode already has the same value, nothing to do
				return
			end
		end
		
		node = child
	end
end

return setmetatable(
	{ new = new },
	{ __call = function(_, ...) return new(...) end }
)
