-- from: https://love2d.org/wiki/TileMerging
local rectdec = {}

function rectdec:is_wall_f(x, y)
	if self.map.data[y][x] then
		return self.map.data[y][x].properties.collidable == "true"
	else
		return false
	end
end

-- despite the name, this should be a layer, because I'm a bad person
function rectdec:setMap(map)
	self.map = map
	self.map_width = map.width
	self.map_height = map.height
end

function rectdec:parseMap()
	local rectangles = {} -- Each rectangle covers a grid of wall tiles
	
	for x = 1, self.map_width - 1 do
		local start_y
		local end_y

		for y = 1, self.map_height - 1 do
			if self:is_wall_f(x, y) then
				if not start_y then
					start_y = y
				end
				end_y = y
			elseif start_y then
				local overlaps = {}
				for _, r in ipairs(rectangles) do
					if (r.end_x == x - 1)
					  and (start_y <= r.start_y)
					  and (end_y >= r.end_y) then
						table.insert(overlaps, r)
					end
				end
				table.sort(
					overlaps,
					function (a, b)
						return a.start_y < b.start_y
					end
				)

				for _, r in ipairs(overlaps) do
					if start_y < r.start_y then
						local new_rect = {
							start_x = x,
							start_y = start_y,
							end_x = x,
							end_y = r.start_y - 1
						}
						table.insert(rectangles, new_rect)
						start_y = r.start_y
					end

					if start_y == r.start_y then
						r.end_x = r.end_x + 1

						if end_y == r.end_y then
							start_y = nil
							end_y = nil
						elseif end_y > r.end_y then
							start_y = r.end_y + 1
						end
					end
				end

				if start_y then
					local new_rect = {
						start_x = x,
						start_y = start_y,
						end_x = x,
						end_y = end_y
					}
					table.insert(rectangles, new_rect)

					start_y = nil
					end_y = nil
				end
			end
		end

		if start_y then
			local new_rect = {
				start_x = x,
				start_y = start_y,
				end_x = x,
				end_y = end_y
			}
			table.insert(rectangles, new_rect)

			start_y = nil
			end_y = nil
		end
	end
	
	return rectangles
end

return rectdec