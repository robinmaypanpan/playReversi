-- Represents the concept of a player in abstract

import 'CoreLibs/object'

import 'location'
import 'lib/list'

class('GameState').extends()

-- Global constants anyone can use
NUM_BOARD_SPACES = 8
WHITE = 2
BLACK = 1
EMPTY = 0

-- State that indicates the game is underway
GAME_UNDERWAY = 0
-- State that indicates the game is completely over and no more moves
GAME_OVER = 1

-- A helpful list of all possible directions
MOVE_DIRECTIONS = {
	Location.new(-1,-1),
	Location.new(-1,0),
	Location.new(-1,1),
	Location.new(0,-1),
	Location.new(0,1),
	Location.new(1,-1),
	Location.new(1,0),
	Location.new(1,1)
}

-- Useful utility for flipping the color of a piece/player
function invertColor(color)
	if (color == BLACK) then
		return WHITE
	elseif (color == WHITE) then
		return BLACK
	else
		return EMPTY
	end
end

function GameState:init(copyState)
	GameState.super.init(self)	
	
	self.boardGrid = intgrid.new(NUM_BOARD_SPACES, NUM_BOARD_SPACES)
	self.boardGrid:setAll(EMPTY)
	
	-- assert(self.boardGrid:get(5,6), -1)
	
	if (copyState) then
		assert(copyState ~= nil)
		-- Copy the other state
		
		self.depth = copyState.depth + 1
		
		-- Copy the values of the board over
		for row = 1,NUM_BOARD_SPACES do
			for col = 1,NUM_BOARD_SPACES do
				local copyValue = copyState.boardGrid:get(row, col)
				self.boardGrid:set(row, col, copyValue)
			end
		end
		
		-- Copy the remaining state values
		self.currentPlayer = copyState.currentPlayer
		self.nonCurrentPlayer = copyState.nonCurrentPlayer
		self.state = copyState.state
		
		-- Copy calculated data over
		self.numWhitePieces = copyState.numWhitePieces
		self.numBlackPieces = copyState.numBlackPieces
		
		-- Copy calculated moves over by value
		self.validMoves = List.new()
		self.validMoveQueue = List.new()
		self.numValidMoves = 0
		List.forEach(copyState.validMoves, function(move)			
			assert(move ~= nil)		
			List.pushEnd(self.validMoves, move)
			List.pushEnd(self.validMoveQueue, move)
			self.numValidMoves += 1
		end)
		
	else		
		-- Create a starter game state
		self.depth = 1
		
		-- Put the 4 pieces in the center
		self.boardGrid:set(4, 5, BLACK)
		self.boardGrid:set(5, 4, BLACK)
		self.boardGrid:set(4, 4, WHITE)
		self.boardGrid:set(5, 5, WHITE)
		
		-- Current player for this game state
		self.currentPlayer = WHITE
		self.nonCurrentPlayer = invertColor(self.currentPlayer)
		
		-- Number of pieces of each color
		self.numWhitePieces = 2
		self.numBlackPieces = 2
		
		-- moves can be made!
		self.state = GAME_UNDERWAY
		
		-- Do bookkeeping
		self:updateValidMoves()
	end
end

-- Returns true if the provided location is actually on the board
function GameState:isOnBoard(location)
	return location.x >= 1 and location.x <= NUM_BOARD_SPACES
		and location.y >= 1 and location.y <= NUM_BOARD_SPACES
end

-- Return the piece at a given location
function GameState:readBoardAt(location)
	if (self:isOnBoard(location)) then
		return self.boardGrid:get(location.x, location.y)
	else
		return EMPTY
	end
end

-- Updates the array of all valid places to move
function GameState:updateValidMoves()
	local newValidMoves = flipflop.generateValidMoves(self.boardGrid, self.currentPlayer)	
	self.numValidMoves = newValidMoves:getSize()
	
	self.validMoves = List.new()
	self.validMoveQueue = List.new()
	
	while(newValidMoves:getSize() > 0) do
		local row, col = newValidMoves:pop()
		assert(row ~= nil)
		assert(col ~= nil)
		local testPoint = Location.new(row, col);
		List.pushEnd(self.validMoves, testPoint)
		List.pushEnd(self.validMoveQueue, testPoint)
	end
end

-- Add a piece of the current player at the indicated location
function GameState:addCurrentPlayerPieceAt(location)
	local row, col = Location.unpack(location)
	self.boardGrid:set(row, col, self.currentPlayer)
	if (self.currentPlayer == WHITE) then
		self.numWhitePieces += 1
	else
		self.numBlackPieces += 1
	end
end

-- Returns true if we can flip all the pieces in the direction from the location in that direction
function GameState:checkDirectionForMove(location, direction)
	-- Initialize our loop variables
	local foundAnOpponentPiece = false
	local nextRow = location.x
	local nextCol = location.y
	local piece
	local currentPlayer = self.currentPlayer
	local nonCurrentPlayer = self.nonCurrentPlayer
	local boardGrid = self.boardGrid
	
	-- start looping
	repeat
		nextRow += direction.x
		nextCol += direction.y
		if (nextRow >= 1 and nextRow <= NUM_BOARD_SPACES and nextCol >= 1 and nextCol <= NUM_BOARD_SPACES) then
			piece = boardGrid:get(nextRow, nextCol)
			if (piece == nonCurrentPlayer) then			
				foundAnOpponentPiece = true
			end
		else
			return false
		end
	until piece == EMPTY or piece == currentPlayer
	
	-- If we found at least one opponent piece AND we ended on one of our own pieces, we're good
	if (foundAnOpponentPiece and piece ~= EMPTY and piece == currentPlayer) then
		return true
	end
	
	return false
end

-- Flip the piece at the indicated location
function GameState:flipPieceToCurrentPlayerAt(location)
	local row, col = Location.unpack(location)
	self.boardGrid:set(row, col, self.currentPlayer)
	if (self.currentPlayer == WHITE) then
		self.numWhitePieces += 1
		self.numBlackPieces -= 1
	else
		self.numBlackPieces += 1
		self.numWhitePieces -= 1
	end	
end

-- Flips all the pieces in the direction indicated so they match the endpoints
function GameState:flipInDirection(location, direction) 
	assert(location ~= nil)
	assert(direction ~= nil)
	
	local opponentColor = invertColor(self.currentPlayer)	
	
	-- Initialize our loop variables
	local foundAnOpponentPiece = false
	local nextLocation = location
	local piece
	
	-- start looping
	repeat
		nextLocation = Location.add(nextLocation, direction)
		piece = self:readBoardAt(nextLocation)
		if (piece == opponentColor) then
			self:flipPieceToCurrentPlayerAt(nextLocation)
		end
	until piece == EMPTY or piece == self.currentPlayer	
end

-- Faster public function to check the list of valid moves to see if you can move there
function GameState:isValidMove(location)
	assert(location~=nil)
	
	return List.check(self.validMoves, function(validMove)
		assert(validMove ~= nil)
		return validMove.x == location.x and validMove.y == location.y
	end)
end

-- Function to execute a move
function GameState:makeMove(location)	
	local row,col = Location.unpack(location)
	
	-- Update the center space
	self:addCurrentPlayerPieceAt(location)	
	
	-- Check for all flips in all directions
	local validDirections = List.new()
	for _,direction in pairs(MOVE_DIRECTIONS) do
		if (self:checkDirectionForMove(location, direction)) then
			List.pushEnd(validDirections, direction)
		end
	end
	
	-- Execute all flips and update count as you go	
	List.forEach(validDirections, function(direction)		
		self:flipInDirection(location, direction)		
	end)
	
	-- Update current player
	self.nonCurrentPlayer = self.currentPlayer
	self.currentPlayer = invertColor(self.currentPlayer)	
	
	-- Update valid moves
	self:updateValidMoves()
	
	-- Check to see if we have any actual valid moves
	if (self.numValidMoves == 0) then		
		-- Update current player
		self.nonCurrentPlayer = self.currentPlayer
		self.currentPlayer = invertColor(self.currentPlayer)
			
		-- Update valid moves
		self:updateValidMoves()
		
		if (self.numValidMoves == 0) then
			-- if we have to pass twice, the game is over
			self.state = GAME_OVER
			self.nonCurrentPlayer = EMPTY
			self.currentPlayer = EMPTY
		end
	end
end

-- Returns a copy of this game state
function GameState:copy()
	return GameState(self)
end