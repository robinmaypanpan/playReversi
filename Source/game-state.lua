-- Represents the concept of a player in abstract

import 'CoreLibs/object'

import 'location'
import 'lib/list'

class('GameState').extends()

local THINK_TIME = 20

-- Global constants anyone can use
NUM_BOARD_SPACES = 8
WHITE = 1
BLACK = 0

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

function getPieceString(color)
	if (color == nil) then
		return 'empty'
	elseif (color == WHITE) then
		return 'white'
	else
		return 'black'
	end
end

-- Creates a new, blank board
function createBoard()	
	local boardData = {}
	for i=1,NUM_BOARD_SPACES do
		boardData[i] = {}
		for j=1,NUM_BOARD_SPACES do
			boardData[i][j] = nil
		end
	end
	return boardData
end

-- Useful utility for flipping the color of a piece/player
function invertColor(color)
	if (color == BLACK) then
		return WHITE
	else
		return BLACK
	end
end

function GameState:init(copyState)
	GameState.super.init(self)	
	
	self.board = createBoard()
	
	if (copyState) then
		assert(copyState ~= nil)
		-- Copy the other state
		
		self.depth = copyState.depth + 1
		
		-- Copy the values of the board over
		for row = 1,NUM_BOARD_SPACES do
			for col = 1,NUM_BOARD_SPACES do
				if (copyState.board[row][col] ~= nil) then
					self.board[row][col] = copyState.board[row][col]
				else
					self.board[row][col] = nil
				end
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
			List.pushEnd(self.validMoves, move)
			self.numValidMoves += 1			
		end)
		
	else		
		-- Create a starter game state
		self.depth = 1
		
		-- Put the 4 pieces in the center
		self.board[4][5] = BLACK
		self.board[5][4] = BLACK
		self.board[4][4] = WHITE
		self.board[5][5] = WHITE
		
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
		return self.board[location.x][location.y]
	else
		return nil
	end
end

-- Updates the array of all valid places to move
function GameState:updateValidMoves()
	self.validMoves = List.new()
	self.validMoveQueue = List.new()
	self.numValidMoves = 0
	for i=1,NUM_BOARD_SPACES do
		for j=1,NUM_BOARD_SPACES do
			local testPoint = Location.new(i,j)
			if (self:calculateIfValidMove(testPoint)) then
				List.pushEnd(self.validMoves, testPoint)
				List.pushEnd(self.validMoveQueue, testPoint)
				self.numValidMoves+=1
			end
		end
	end
end

-- Add a piece of the current player at the indicated location
function GameState:addCurrentPlayerPieceAt(location)
	local row, col = Location.unpack(location)
	self.board[row][col] = self.currentPlayer
	if (self.currentPlayer == WHITE) then
		self.numWhitePieces += 1
	else
		self.numBlackPieces += 1
	end
end

-- Flip the piece at the indicated location
function GameState:flipPieceToCurrentPlayerAt(location)
	local row, col = Location.unpack(location)
	self.board[row][col] = self.currentPlayer
	if (self.currentPlayer == WHITE) then
		self.numWhitePieces += 1
		self.numBlackPieces -= 1
	else
		self.numBlackPieces += 1
		self.numWhitePieces -= 1
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
	local board = self.board
	
	-- start looping
	repeat
		nextRow += direction.x
		nextCol += direction.y
		if (nextRow >= 1 and nextRow <= NUM_BOARD_SPACES and nextCol >= 1 and nextCol <= NUM_BOARD_SPACES) then
			piece = board[nextRow][nextCol]
			if (piece == nonCurrentPlayer) then			
				foundAnOpponentPiece = true
			end
		else
			piece = nil
		end
	until piece == nil or piece == currentPlayer
	
	-- If we found at least one opponent piece AND we ended on one of our own pieces, we're good
	if (foundAnOpponentPiece and piece ~= nil and piece == currentPlayer) then
		return true
	end
	
	return false
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
		if (piece ~= nil and piece == opponentColor) then
			self:flipPieceToCurrentPlayerAt(nextLocation)
		end
	until piece == nil or piece == self.currentPlayer	
end

-- Faster public function to check the list of valid moves to see if you can move there
function GameState:isValidMove(location)
	assert(location~=nil)
	
	return List.check(self.validMoves, function(validMove)
		return validMove.x == location.x and validMove.y == location.y
	end)
end

-- Function that returns true if the current player can make this move
function GameState:calculateIfValidMove(location)
	assert(location ~= nil)
	
	local row,col = Location.unpack(location)
	-- You can't move onto spaces that already have pieces
	if (self.board[row][col] ~= nil) then 
		return false 
	end	
	
	-- Look in every direction for a valid move
	for _,direction in pairs(MOVE_DIRECTIONS) do
		if (self:checkDirectionForMove(location, direction)) then
			return true
		end
	end
	
	-- If we look in every direction and find nothing, we're hosed
	return false	
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
			self.nonCurrentPlayer = -1
			self.currentPlayer = -1
		end
	end
end

-- Returns a copy of this game state
function GameState:copy()
	return GameState(self)
end