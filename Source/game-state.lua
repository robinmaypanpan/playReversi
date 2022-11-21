-- Represents the concept of a player in abstract

import 'CoreLibs/object'

class('GameState').extends()

-- Useful way to communicate pairs of information around
local vector2D = playdate.geometry.vector2D

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
	vector2D.new(-1,-1),
	vector2D.new(-1,0),
	vector2D.new(-1,1),
	vector2D.new(0,-1),
	vector2D.new(0,1),
	vector2D.new(1,-1),
	vector2D.new(1,0),
	vector2D.new(1,1)
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
		
		-- Copy the board over
		assert(copyState.board ~= nil)
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
		self.state = copyState.state
		
		-- Copy calculated data over
		self.numWhitePieces = copyState.numWhitePieces
		self.numBlackPieces = copyState.numBlackPieces
		
		assert(copyState.validMoves ~= nil)
		self.validMoves = {}
		self.numValidMoves = 0
		for _,move in pairs(copyState.validMoves) do
			table.insert(self.validMoves, move)
			self.numValidMoves += 1
		end
		
	else		
		-- Create a starter game state
		
		-- Put the 4 pieces in the center
		self.board[4][5] = BLACK
		self.board[5][4] = BLACK
		self.board[4][4] = WHITE
		self.board[5][5] = WHITE
		
		-- Current player for this game state
		self.currentPlayer = WHITE
		
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
		local row,col = location:unpack()
		return self.board[row][col]
	else
		return nil
	end
end

-- Updates the array of all valid places to move
function GameState:updateValidMoves()
	self.validMoves = {}
	self.numValidMoves = 0
	for i=1,NUM_BOARD_SPACES do
		for j=1,NUM_BOARD_SPACES do
			local testPoint = vector2D.new(i,j)
			if (self:calculateIfValidMove(testPoint)) then
				table.insert(self.validMoves, testPoint)
				self.numValidMoves+=1
			end
		end
	end
end

-- Add a piece of the current player at the indicated location
function GameState:addCurrentPlayerPieceAt(location)
	local row, col = location:unpack()
	self.board[row][col] = self.currentPlayer
	if (self.currentPlayer == WHITE) then
		self.numWhitePieces += 1
	else
		self.numBlackPieces += 1
	end
end

-- Flip the piece at the indicated location
function GameState:flipPieceToCurrentPlayerAt(location)
	local row, col = location:unpack()
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
	assert(location ~= nil)
	assert(direction ~= nil)
	
	-- Start by grabbing our starting point information	
	local opponentColor = invertColor(self.currentPlayer)
	
	-- Initialize our loop variables
	local foundAnOpponentPiece = false
	local nextLocation = location
	local piece
	
	-- start looping
	repeat
		nextLocation = nextLocation + direction
		local row, col = nextLocation:unpack()
		piece = self:readBoardAt(nextLocation)		
		if (piece ~= nil and piece == opponentColor) then			
			foundAnOpponentPiece = true
		end
	until piece == nil or piece == self.currentPlayer
	
	-- If we found at least one opponent piece AND we ended on one of our own pieces, we're good
	if (foundAnOpponentPiece and piece ~= nil and piece == self.currentPlayer) then
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
		nextLocation = nextLocation + direction
		piece = self:readBoardAt(nextLocation)
		if (piece ~= nil and piece == opponentColor) then
			self:flipPieceToCurrentPlayerAt(nextLocation)
		end
	until piece == nil or piece == self.currentPlayer	
end

-- Faster public function to check the list of valid moves to see if you can move there
function GameState:isValidMove(location)
	assert(location~=nil)
	
	for _,validMove in pairs(self.validMoves) do
		if (validMove.x == location.x and validMove.y == location.y) then
			return true
		end
	end
	
	return false
end

-- Function that returns true if the current player can make this move
function GameState:calculateIfValidMove(location)
	assert(location ~= nil)
	
	local row,col = location:unpack()
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
function GameState:makeMove(location, createNewState)	
	local gameState = self	
	if (createNewState) then
		gameState = self:copy()
	end	
	
	local row,col = location:unpack()
	
	-- Update the center space
	gameState:addCurrentPlayerPieceAt(location)	
	
	-- Check for all flips in all directions
	local validDirections = {}
	for _,direction in pairs(MOVE_DIRECTIONS) do
		if (gameState:checkDirectionForMove(location, direction)) then
			table.insert(validDirections, direction)
		end
	end
	
	-- Execute all flips and update count as you go	
	for _,direction in pairs(validDirections) do
		gameState:flipInDirection(location, direction)
	end
	
	-- Update current player
	gameState.currentPlayer = invertColor(gameState.currentPlayer)
	
	-- Update valid moves
	gameState:updateValidMoves()
	
	-- Check to see if we have any actual valid moves
	if (gameState.numValidMoves == 0) then			
		-- Update current player
		gameState.currentPlayer = invertColor(gameState.currentPlayer)
			
		-- Update valid moves
		gameState:updateValidMoves()
		
		if (gameState.numValidMoves == 0) then
			-- if we have to pass twice, the game is over
			gameState.state = GAME_OVER
			gameState.currentPlayer = -1
		end
	end
	
	return gameState
end

-- Returns a copy of this game state
function GameState:copy()
	return GameState(self)
end