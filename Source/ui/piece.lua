import "CoreLibs/object"
import 'CoreLibs/sprites'
import 'lib/AnimatedSprite'

local gfx = playdate.graphics

class('Piece').extends(AnimatedSprite)

function Piece:init(spaceSize, initialColor)
	local pieceImageTable = gfx.imagetable.new('assets/images/piece')
	Piece.super.init(self, pieceImageTable)
	
	assert(spaceSize > 0)
	assert(initialColor == WHITE or initialColor == BLACK)
	
	self.pieceColor = initialColor
	self.diameter = spaceSize - 5
	
	self:addState('black', 2, 7, {tickStep = 2, loop=false})
	self:addState('white', 1, 6, {tickStep = 2, loop=false, reverse=true})
	
	if(initialColor == BLACK) then
		self:changeState('black', false)
		self:setImage(pieceImageTable[7])
	elseif (initialColor == WHITE) then
		self:changeState('white', false)
		self:setImage(pieceImageTable[1])
	end
end

function Piece:flip()
	self.pieceColor = invertColor(self.pieceColor)
	if(self.pieceColor == BLACK) then
		self:changeState('black', true)
	elseif (self.pieceColor == WHITE) then
		self:changeState('white', true)
	end
	
end