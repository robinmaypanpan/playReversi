Location = {}

function Location.new(x, y)
	return {
		x = x,
		y = y
	}
end

function Location.unpack(location)
	return location.x,location.y 
end

function Location.add(location, other) 
	return Location.new(location.x + other.x, location.y + other.y)
end

function Location.equals(location, other)
	return location ~= nil and other ~= nil and location.x == other.x and location.y == other.y
end