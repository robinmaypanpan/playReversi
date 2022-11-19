import "CoreLibs/object"
import 'CoreLibs/sprites'

local gfx = playdate.graphics

class('Piece').extends(gfx.sprite)

function Piece:init(spaceSize, initialColor)
	Piece.super.init(self)
	assert(spaceSize > 0)
	assert(initialColor == 1 or initialColor == 0)
	self.pieceColor = initialColor
	self.diameter = spaceSize - 5
	
	self:setImage(self:drawPiece())
end

function Piece:drawPiece()
	local pieceImage = gfx.image.new(self.diameter, self.diameter)
	gfx.pushContext(pieceImage)
		gfx.setDitherPattern(0)
		if (self.pieceColor == 0) then
			gfx.setColor(gfx.kColorBlack)
			gfx.fillCircleInRect(0, 0, self.diameter, self.diameter)
		else
			gfx.setColor(gfx.kColorWhite)
			gfx.fillCircleAtPoint(0, 0, self.diameter, self.diameter)
			gfx.setColor(gfx.kColorBlack)
			gfx.drawCircleInRect(0, 0, self.diameter, self.diameter)
		end
	gfx.popContext()
	return pieceImage
end

function Piece:flip()
	if (self.pieceColor == 0) then
		self.pieceColor = 1
	else
		self.pieceColor = 0
	end
	self:setImage(self:drawPiece())
end