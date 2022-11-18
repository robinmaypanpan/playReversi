import "CoreLibs/object"
import 'CoreLibs/sprites'

local gfx = playdate.graphics

import 'piece'

class('Board').extends(gfx.sprite)

function Board:init(numSpaces, spaceSize)
	Board.super.init(self)
	self.numSpaces = numSpaces
	self.spaceSize = spaceSize
	
	self:setImage(self:drawBoard())
end

function Board:getBoardSize()
	return self.numSpaces * self.spaceSize;
end

function Board:drawBoard()
	local boardSize = self:getBoardSize()
	local boardImage = gfx.image.new(boardSize, boardSize)
	gfx.pushContext(boardImage)
		gfx.setColor(gfx.kColorBlack)
		
		-- Draw the board squares
		gfx.setLineWidth(1)
		
		-- Draw the vertical lines first
		for col = 1, self.numSpaces do
			gfx.drawLine(col*self.spaceSize, 0, col*self.spaceSize, self.numSpaces*self.spaceSize)
		end
		
		-- Now draw the horizontal lines
		for row = 1, self.numSpaces do
			gfx.drawLine(0, row*self.spaceSize, self.numSpaces*self.spaceSize, row*self.spaceSize)
		end
		
		-- Draw an outline around the entire board	
		local boardSize = self:getBoardSize()
		gfx.setLineWidth(3)
		gfx.drawRect(0, 0, boardSize, boardSize)
	gfx.popContext()
	return boardImage
end

function Board:calculateSpaceCenter(row, col)
	local distanceFromCenterToEdge = ((self.numSpaces - 1 ) / 2) * self.spaceSize
	local firstRowCenter = self.y - distanceFromCenterToEdge
	local firstColCenter = self.x - distanceFromCenterToEdge
	
	local y = firstRowCenter + row * self.spaceSize + 1
	local x = firstColCenter + col * self.spaceSize + 1
	
	return x,y
end

function Board:addPiece(row, col, pieceColor)
	local piece = Piece(self.spaceSize - 5, pieceColor)
	
	local x, y = self:calculateSpaceCenter(row, col)
	
	piece:moveTo(x, y)
	piece:add()
end

