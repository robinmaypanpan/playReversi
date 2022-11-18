import "CoreLibs/object"
import 'CoreLibs/sprites'

local gfx = playdate.graphics

class('Piece').extends(gfx.sprite)

function Piece:init(spaceSize, initialColor)
	Piece.super.init(self)
	self.pieceColor = initialColor
	self.diameter = spaceSize - 5
	
	local pieceImage = self:drawPiece()
	self:setImage(pieceImage)
end

function Piece:drawPiece()
	local pieceImage = gfx.image.new(self.diameter, self.diameter)
	gfx.pushContext(pieceImage)
		gfx.setColor(gfx.kColorBlack)
		if (self.pieceColor == 0) then
			gfx.fillCircleInRect(0, 0, self.diameter, self.diameter)
		else
			gfx.drawCircleInRect(0, 0, self.diameter, self.diameter)
		end
	gfx.popContext()
	return pieceImage
end