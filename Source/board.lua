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

-- Removes everything from the board
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

-- Creates the initial data to put on the board
function Board:createBoardData()
	self.data = {}
	for i=1,self.numSpaces do
		self.data[i] = {}
		for j=1,self.numSpaces do
			self.data[i][j] = nil
		end
	end
end

-- Returns the full size of the board
function Board:getBoardSize()
	return self.numSpaces * self.spaceSize;
end

-- Draws the basic board image and returns that image
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

-- Calculates the center x,y coordinates of the indicated row,col space
function Board:calculateSpaceCenter(row, col)
	local distanceFromCenterToEdge = ((self.numSpaces - 1 ) / 2) * self.spaceSize
	local firstRowCenter = self.y - distanceFromCenterToEdge
	local firstColCenter = self.x - distanceFromCenterToEdge
	
	local y = firstRowCenter + (row - 1) * self.spaceSize + 1
	local x = firstColCenter + (col - 1) * self.spaceSize + 1
	
	return x,y
end

-- adds a piece at the indicated location
function Board:addPiece(row, col, pieceColor)
	local piece = Piece(self.spaceSize, pieceColor)
	
	self.data[row][col] = piece
	
	local x, y = self:calculateSpaceCenter(row, col)
	
	piece:moveTo(x, y)
	piece:add()
end

-- Adds a cursor to the board
function Board:addCursor()	
	if (self.cursor) then
		self.cursor.remove()
	end
	self.cursor = Cursor(self.spaceSize)
	self.cursor:add()
	self.cursorRow = 0
	self.cursorCol = 0
end

-- Sets the position of the cursor
function Board:setCursor(row, col)		
	local x, y = self:calculateSpaceCenter(row, col)
	
	self.cursorRow = row
	self.cursorCol = col
	
	self.cursor:moveTo(x, y)
end

-- Moves the cursor to a position indicated by the inputs
function Board:moveCursor(deltaRow, deltaCol)
	local row = self.cursorRow
	local col = self.cursorCol
	row = math.clamp(row + deltaRow, 1, self.numSpaces)
	col = math.clamp(col + deltaCol, 1, self.numSpaces)
	self:setCursor(row,col)	
end

-- Returns the piece at the cursor
function Board:getPieceAtCursor()
	if (self.cursorRow > 0 and self.cursorCol > 0) then
		return self.data[self.cursorRow][self.cursorCol]
	else
		return nil
	end
end

-- Returns true if theres a piece under the cursor
function Board:hasPieceAtCursor()
	local piece = self:getPieceAtCursor()
	return piece ~= nil
end

-- Flips the piece at the cursor, assuming there is one
function Board:flipPieceAtCursor()
	local piece = self:getPieceAtCursor()
	if piece ~= nil then
		piece:flip()
	end
end

-- Adds a piece at the current cursor position
function Board:addPieceAtCursor(pieceColor)
	self:addPiece(self.cursorRow, self.cursorCol, pieceColor)
end