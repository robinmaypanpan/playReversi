import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'CoreLibs/graphics'
import 'pulp-audio'

import 'piece'
import 'cursor'
import 'helpers'

local audio = pulp.audio
local gfx = playdate.graphics
local vector2D = playdate.geometry.vector2D

class('Board').extends(gfx.sprite)

-- A helpful list of all possible directions
local directions = {
	vector2D.new(-1,-1),
	vector2D.new(-1,0),
	vector2D.new(-1,1),
	vector2D.new(0,-1),
	vector2D.new(0,1),
	vector2D.new(1,-1),
	vector2D.new(1,0),
	vector2D.new(1,1)
}

function Board:init(numSpaces, spaceSize)
	Board.super.init(self)
	self.numSpaces = numSpaces
	self.spaceSize = spaceSize
	self.cursorPosition = vector2D.new(0,0)
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
	
	return vector2D.new(x,y)
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

-- Returns an array of all valid places to move
function Board:getValidMoves(playerColor)
	local validMoves = {}
	local numValidMoves = 0
	for i=1,self.numSpaces do
		for j=1,self.numSpaces do
			local testPoint = vector2D.new(i,j)
			if (self:canPlacePieceAt(testPoint, playerColor)) then
				table.insert(validMoves, testPoint)
				numValidMoves+=1
			end
		end
	end
	return validMoves, numValidMoves
end

-- Returns the number of black and white pieces on the board
function Board:getScores()
	local whiteCount = 0
	local blackCount = 0
	for i=1,self.numSpaces do
		for j=1,self.numSpaces do
			local piece = self:getPieceAt(vector2D.new(i,j))
			if (piece ~= nil) then
				if (piece.pieceColor == 0) then
					blackCount += 1
				else
					whiteCount += 1
				end
			end
		end
	end
	return whiteCount, blackCount	
end

-- Returns true if we can flip all the pieces in the direction from the location in that direction
function Board:canFlipInDirection(location, direction, centerColor)
	assert(location ~= nil)
	assert(direction ~= nil)
	
	-- Start by grabbing our starting point information	
	local opponentColor = invertColor(centerColor)
	
	-- Initialize our loop variables
	local foundAnOpponentPiece = false
	local nextLocation = location
	local piece
	
	-- start looping
	repeat
		nextLocation = nextLocation + direction
		piece = self:getPieceAt(nextLocation)
		if (piece and piece.pieceColor == opponentColor) then
			foundAnOpponentPiece = true
		end
	until piece == nil or piece.pieceColor == centerColor
	
	-- If we found at least one opponent piece AND we ended on one of our own pieces, we're good
	if (foundAnOpponentPiece and piece ~= nil and piece.pieceColor == centerColor) then
		return true
	end
	
	return false
end

-- Flips all the pieces in the direction indicated so they match the endpoints
function Board:flipInDirection(location, direction) 
	assert(location ~= nil)
	assert(direction ~= nil)
	
	-- Start by grabbing our starting point information	
	local row,col = location:unpack()
	local centerPiece = self.data[row][col]	
	assert(centerPiece ~= nil)
	
	local centerColor = centerPiece.pieceColor	
	local opponentColor = invertColor(centerColor)	
	
	-- Initialize our loop variables
	local foundAnOpponentPiece = false
	local nextLocation = location
	local piece
	local pieceColor
	
	-- start looping
	repeat
		nextLocation = nextLocation + direction
		piece = self:getPieceAt(nextLocation)
		pieceColor = piece.pieceColor
		if (piece and piece.pieceColor == opponentColor) then
			piece:flip()
		end
	until piece == nil or pieceColor == centerColor	
end

-- Return a boolean indicating whether the row, col space can be moved to
function Board:canPlacePieceAt(location, pieceColor)
	assert(location ~= nil)
	assert(pieceColor ~= nil)
	
	local row,col = location:unpack()
	-- You can't move onto spaces that already have pieces
	if (self.data[row][col] ~= nil) then 
		return false 
	end
	
	-- Look in every direction for a valid move
	for _,direction in pairs(directions) do
		if (self:canFlipInDirection(location, direction, pieceColor)) then
			return true
		end
	end

	-- If we look in every direction and find nothing, we're hosed
	return false
end

-- Flips all of the pieces around the indicated location that can and should be flipped
-- Usually called right after to place a piece.
-- Should be replaced by a crank action to flip all the pieces.
function Board:flipPiecesAround(location)	
	assert(location ~= nil)
	local row,col = location:unpack()
	
	-- Start by grabbing a bunch of our pieces
	local centerPiece = self.data[row][col]	
	local centerColor = centerPiece.pieceColor	
	local opponentColor = invertColor(pieceColor)
	
	-- First find all the valid directions to look in
	local validDirections = {}
	for _,direction in pairs(directions) do
		if (self:canFlipInDirection(location, direction, centerColor)) then
			table.insert(validDirections, direction)
		end
	end
	
	-- Now do the actual flips
	for _,direction in pairs(validDirections) do
		self:flipInDirection(location, direction)
	end
end

-- Adds a cursor to the board
function Board:addCursor()	
	if (self.cursor) then
		self.cursor.remove()
	end
	self.cursor = Cursor(self.spaceSize)
	self.cursor:add()
	self.cursorPosition = vector2D.new(0,0)
end

-- Sets the position of the cursor
function Board:setCursor(newLocation, currentPlayer)	
	assert(self:isOnBoard(newLocation))	
	self.cursorPosition = newLocation
	local newScreenPosition = self:calculateSpaceCenter(newLocation)	
	local x,y = newScreenPosition:unpack()
	self.cursor:moveTo(x,y)
	self.cursor:setValidPosition(self:canPlacePieceAtCursor(currentPlayer))
end

-- Moves the cursor to a position indicated by the inputs
function Board:moveCursor(delta, currentPlayer)
	local newPosition = self.cursorPosition + delta
	if (self:isOnBoard(newPosition)) then
		self:setCursor(newPosition, currentPlayer)
		audio.playSound('moveCursor')
	else
		audio.playSound('invalid')
	end
end

-- Returns true if the provided location is actually on the board
function Board:isOnBoard(location)
	return location.x >= 1 and location.x <= self.numSpaces
		and location.y >= 1 and location.y <= self.numSpaces
end

-- Return the piece at a given location
function Board:getPieceAt(location)
	if (self:isOnBoard(location)) then
		local row,col = location:unpack()
		return self.data[row][col]
	else
		return nil
	end
end

-- Returns the piece at the cursor
function Board:getPieceAtCursor()
	return self:getPieceAt(self.cursorPosition)
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

-- Places a piece at the current cursor position
function Board:placePieceAtCursor(pieceColor)
	self:addPiece(self.cursorPosition, pieceColor)
	self:flipPiecesAround(self.cursorPosition)
	audio.playSound('placePiece')
end

-- Returns true if you can make a move at the cursor
function Board:canPlacePieceAtCursor(pieceColor)
	return self:canPlacePieceAt(self.cursorPosition, pieceColor)
end