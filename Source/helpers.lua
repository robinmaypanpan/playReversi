
function math.clamp(val, lower, upper)
	assert(val and lower and upper, "not very useful error message here")
	if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
	return math.max(lower, math.min(upper, val))
end

-- Useful utility for flipping the color of a piece/player
function invertColor(color)
	if (color == 0) then
		return 1
	else
		return 0
	end
end