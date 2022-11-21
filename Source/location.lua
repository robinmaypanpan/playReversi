function Location(x, y)
	return {
		x = x,
		y = y,
		unpack = function() return x,y end,
		add = function(other) 
			return Location(x + other.x, y + other.y)
		end
	}
end