import "CoreLibs/object"
import 'CoreLibs/sprites'

import 'helpers'

local gfx = playdate.graphics

class('Piece').extends(gfx.sprite)

local whiteImage = gfx.image.new('images/piece1.png')
local blackImage = gfx.image.new('images/piece2.png')

function getImageForColor(color)
	if (color == 0) then
		return blackImage
	else
		return whiteImage
	end
end

function Piece:init(spaceSize, initialColor)
	Piece.super.init(self)
	assert(spaceSize > 0)
	assert(initialColor == 1 or initialColor == 0)
	self.pieceColor = initialColor
	self.diameter = spaceSize - 5
	
	self:setImage(getImageForColor(initialColor))
end

function Piece:flip()
	self.pieceColor = invertColor(self.pieceColor)
	self:setImage(getImageForColor(self.pieceColor))
end