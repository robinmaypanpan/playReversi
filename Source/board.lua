import "CoreLibs/object"
import 'CoreLibs/sprites'

local gfx = playdate.graphics

import 'piece'
import 'cursor'
import 'helpers'

class('Board').extends(gfx.sprite)

function Board:init(numSpaces, spaceSize)
	Board.super.init(self)
	self.numSpaces = numSpaces
	self.spaceSize = spaceSize
	self.cursorRow = 0
	self.cursorCol = 0
	self.padding = 5
	
	self:createBoardData()
	
	self:setImage(self:drawBoard())
end

function Board:clearBoard()
	for i=1,self.numSpaces do
		for j=1,self.numSpaces do
			if (self.data[i][j]) then
				self.data[i][j]:remove()
			end
			self.data[i][j] = nil
		end
	end
	
end

function Board:createBoardData()
	self.data = {}
	for i=1,self.numSpaces do
		self.data[i] = {}
		for j=1,self.numSpaces do
			self.data[i][j] = nil
		end
	end
end

function Board:getBoardSize()
	return self.numSpaces * self.spaceSize;
end

function Board:drawBoard()
	local boardSize = self:getBoardSize()
	local boardImage = gfx.image.new(boardSize+10, boardSize+10)
	local padding = self.padding;
	gfx.pushContext(boardImage)
		gfx.setColor(gfx.kColorBlack)
		
		-- Draw the board squares
		gfx.setLineWidth(1)
		
		-- Draw the vertical lines first
		for col = 1, self.numSpaces - 1 do
			gfx.drawLine(
				padding + col*self.spaceSize, padding, 
				padding + col*self.spaceSize, padding + self.numSpaces*self.spaceSize)
		end
		
		-- Now draw the horizontal lines
		for row = 1, self.numSpaces - 1 do
			gfx.drawLine(
				padding, padding + row*self.spaceSize, 
				padding + self.numSpaces*self.spaceSize, padding + row*self.spaceSize)
		end
		
		-- Draw an outline around the entire board	
		local boardSize = self:getBoardSize()
		gfx.setLineWidth(3)
		gfx.drawRect(padding - 1, padding - 1, boardSize +1, boardSize+1)
	gfx.popContext()
	return boardImage
end

function Board:calculateSpaceCenter(row, col)
	local distanceFromCenterToEdge = ((self.numSpaces - 1 ) / 2) * self.spaceSize
	local firstRowCenter = self.y - distanceFromCenterToEdge
	local firstColCenter = self.x - distanceFromCenterToEdge
	
	local y = firstRowCenter + (row - 1) * self.spaceSize + 1
	local x = firstColCenter + (col - 1) * self.spaceSize + 1
	
	return x,y
end

function Board:addPiece(row, col, pieceColor)
	local piece = Piece(self.spaceSize, pieceColor)
	
	self.data[row][col] = piece
	
	local x, y = self:calculateSpaceCenter(row, col)
	
	piece:moveTo(x, y)
	piece:add()
end

function Board:addCursor()	
	self.cursor = Cursor(self.spaceSize)
	self.cursor:add()
	self.cursorRow = 0
	self.cursorCol = 0
end

function Board:setCursor(row, col)		
	local x, y = self:calculateSpaceCenter(row, col)
	
	self.cursorRow = row
	self.cursorCol = col
	
	self.cursor:moveTo(x, y)
end

function Board:moveCursor(deltaRow, deltaCol)
	local row = self.cursorRow
	local col = self.cursorCol
	row = math.clamp(row + deltaRow, 1, self.numSpaces)
	col = math.clamp(col + deltaCol, 1, self.numSpaces)
	self:setCursor(row,col)	
end

function Board:getPieceAtCursor()
	if (self.cursorRow > 0 and self.cursorCol > 0) then
		return self.data[self.cursorRow][self.cursorCol]
	else
		return nil
	end
end

function Board:hasPieceAtCursor()
	local piece = self:getPieceAtCursor()
	return piece ~= nil
end

function Board:flipPieceAtCursor()
	local piece = self:getPieceAtCursor()
	if piece ~= nil then
		piece:flip()
	end
end

function Board:addPieceAtCursor(pieceColor)
	self:addPiece(self.cursorRow, self.cursorCol, pieceColor)
end