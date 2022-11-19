import "CoreLibs/object"
import 'CoreLibs/sprites'
import "CoreLibs/graphics"

import 'piece'
import 'cursor'
import 'helpers'

local gfx = playdate.graphics
local point = playdate.geometry.vector2D

class('Board').extends(gfx.sprite)

-- A helpful list of all possible directions
local directions = {
	point.new(-1,-1),
	point.new(-1,0),
	point.new(-1,1),
	point.new(0,-1),
	point.new(0,1),
	point.new(1,-1),
	point.new(1,0),
	point.new(1,1)
}

function Board:init(numSpaces, spaceSize)
	Board.super.init(self)
	self.numSpaces = numSpaces
	self.spaceSize = spaceSize
	self.cursorPosition = point.new(0,0)
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
		
		-- Draw the board background
		gfx.setDitherPattern(0.99)
		gfx.fillRect(padding, padding, boardSize, boardSize)
		
		-- Draw the board squares
		gfx.setDitherPattern(0)
		gfx.setLineWidth(1)
		gfx.setStrokeLocation(gfx.kStrokeCentered)
		
		-- Draw the vertical lines first
		for col = 1, self.numSpaces - 1 do
			gfx.drawLine(
				padding + col*self.spaceSize, padding, 
				padding + col*self.spaceSize, padding + boardSize)
		end
		
		-- Now draw the horizontal lines
		for row = 1, self.numSpaces - 1 do
			gfx.drawLine(
				padding, padding + row*self.spaceSize, 
				padding + boardSize, padding + row*self.spaceSize)
		end
		
		-- Draw an outline around the entire board	
		local boardSize = self:getBoardSize()
		gfx.setStrokeLocation(gfx.kStrokeOutside)
		gfx.setLineWidth(3)
		gfx.drawRect(padding, padding, boardSize, boardSize)
	gfx.popContext()
	return boardImage
end

-- Calculates the center x,y coordinates of the indicated row,col space
function Board:calculateSpaceCenter(rcLocation)
	local row, col = rcLocation:unpack()
	local distanceFromCenterToEdge = ((self.numSpaces - 1 ) / 2) * self.spaceSize
	
	local firstRowCenter = self.y - distanceFromCenterToEdge
	local firstColCenter = self.x - distanceFromCenterToEdge
	
	local y = firstRowCenter + (row - 1) * self.spaceSize + 1
	local x = firstColCenter + (col - 1) * self.spaceSize + 1
	
	return point.new(x,y)
end

-- adds a piece at the indicated location
function Board:addPiece(location, pieceColor)
	local row,col = location:unpack()
	local piece = Piece(self.spaceSize, pieceColor)
	
	self.data[row][col] = piece
	
	local x, y = self:calculateSpaceCenter(location):unpack()
	
	piece:moveTo(x, y)
	piece:add()
end

-- Return a boolean indicating whether the row, col space can be moved to
function Board:canMoveTo(location, pieceColor)
	local row,col = location:unpack()
	-- You can't move onto spaces that already have pieces
	if (self.data[row][col] ~= nil) then 
		return false 
	end
	
	-- Store the opponent color
	local opponentColor = invertColor(pieceColor)
	
	-- Look in every direction for a valid move
	--[[
	for _,direction in directions do
		local firstSpace
	end
	]]--

	return true
end

-- Adds a cursor to the board
function Board:addCursor()	
	if (self.cursor) then
		self.cursor.remove()
	end
	self.cursor = Cursor(self.spaceSize)
	self.cursor:add()
	self.cursorPosition = point.new(0,0)
end

-- Sets the position of the cursor
function Board:setCursor(newLocation)			
	self.cursorPosition = newLocation
	local newScreenPosition = self:calculateSpaceCenter(newLocation)	
	local x,y = newScreenPosition:unpack()
	self.cursor:moveTo(x,y)
end

-- Moves the cursor to a position indicated by the inputs
function Board:moveCursor(delta, currentPlayer)
	local newPosition = self.cursorPosition + delta
	if (board:isOnBoard(newPosition)) then
		self:setCursor(newPosition)	
		self.cursor:setValidPosition(self:canMoveToCursor(currentPlayer))
	end
end

function Board:isOnBoard(location)
	return location.x >= 1 and location.x <= self.numSpaces
		and location.y >= 1 and location.y <= self.numSpaces
end

-- Returns the piece at the cursor
function Board:getPieceAtCursor()
	if (self:isOnBoard(self.cursorPosition)) then
		local row,col = self.cursorPosition:unpack()
		return self.data[row][col]
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
	self:addPiece(self.cursorPosition, pieceColor)
end

-- Returns true if you can make a move at the cursor
function Board:canMoveToCursor(pieceColor)
	return self:canMoveTo(self.cursorPosition, pieceColor)
end