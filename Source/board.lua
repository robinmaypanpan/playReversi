import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'CoreLibs/graphics'

import 'piece'
import 'cursor'
import 'game-state'

local gfx = playdate.graphics
local vector2D = playdate.geometry.vector2D

class('Board').extends(gfx.sprite)

local SPACE_SIZE = 27
local PADDING = 5
local BOARD_SIZE = NUM_BOARD_SPACES * SPACE_SIZE

function Board:init()
	Board.super.init(self)
	self.cursorPosition = vector2D.new(1,1)
	
	self:createBoardData()
	
	self:setImage(self:drawBoard())
end

-- Removes everything from the board
function Board:clearBoard()
	for i=1,NUM_BOARD_SPACES do
		for j=1,NUM_BOARD_SPACES do
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
	for i=1,NUM_BOARD_SPACES do
		self.data[i] = {}
		for j=1,NUM_BOARD_SPACES do
			self.data[i][j] = nil
		end
	end
end

-- Draws the basic board image and returns that image
function Board:drawBoard()
	local boardImage = gfx.image.new(BOARD_SIZE+10, BOARD_SIZE+10)
	gfx.pushContext(boardImage)
		gfx.setColor(gfx.kColorBlack)
		
		-- Draw the board background
		gfx.setDitherPattern(0.99)
		gfx.fillRect(PADDING, PADDING, BOARD_SIZE, BOARD_SIZE)
		
		-- Draw the board squares
		gfx.setDitherPattern(0)
		gfx.setLineWidth(1)
		gfx.setStrokeLocation(gfx.kStrokeCentered)
		
		-- Draw the vertical lines first
		for col = 1, NUM_BOARD_SPACES - 1 do
			gfx.drawLine(
				PADDING + col*SPACE_SIZE, PADDING, 
				PADDING + col*SPACE_SIZE, PADDING + BOARD_SIZE)
		end
		
		-- Now draw the horizontal lines
		for row = 1, NUM_BOARD_SPACES - 1 do
			gfx.drawLine(
				PADDING, PADDING + row*SPACE_SIZE, 
				PADDING + BOARD_SIZE, PADDING + row*SPACE_SIZE)
		end
		
		-- Draw an outline around the entire board	
		gfx.setStrokeLocation(gfx.kStrokeOutside)
		gfx.setLineWidth(3)
		gfx.drawRect(PADDING, PADDING, BOARD_SIZE, BOARD_SIZE)
	gfx.popContext()
	return boardImage
end

-- Calculates the center x,y coordinates of the indicated row,col space
function Board:calculateSpaceCenter(rcLocation)
	local row, col = rcLocation:unpack()
	local distanceFromCenterToEdge = ((NUM_BOARD_SPACES - 1 ) / 2) * SPACE_SIZE
	
	local firstRowCenter = self.y - distanceFromCenterToEdge
	local firstColCenter = self.x - distanceFromCenterToEdge
	
	local y = firstRowCenter + (row - 1) * SPACE_SIZE + 1
	local x = firstColCenter + (col - 1) * SPACE_SIZE + 1
	
	return vector2D.new(x,y)
end

-- adds a piece at the indicated location
function Board:addPiece(location, pieceColor)
	local row,col = location:unpack()
	local piece = Piece(SPACE_SIZE, pieceColor)
	
	self.data[row][col] = piece
	
	local x, y = self:calculateSpaceCenter(location):unpack()
	
	piece:moveTo(x, y)
	piece:add()
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
	for _,direction in pairs(MOVE_DIRECTIONS) do
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
	self.cursor = Cursor(SPACE_SIZE)
	self.cursor:add()
	self.cursorPosition = vector2D.new(1,1)
end

-- Sets the position of the cursor
function Board:setCursorPosition(newLocation)	
	assert(newLocation ~= nil)
	assert(self:isOnBoard(newLocation))	
	self.cursorPosition = newLocation
	local newScreenPosition = self:calculateSpaceCenter(newLocation)	
	local x,y = newScreenPosition:unpack()
	self.cursor:moveTo(x,y)
end

-- Returns true if the provided location is actually on the board
function Board:isOnBoard(location)
	assert(location ~= nil)
	return location.x >= 1 and location.x <= NUM_BOARD_SPACES
		and location.y >= 1 and location.y <= NUM_BOARD_SPACES
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