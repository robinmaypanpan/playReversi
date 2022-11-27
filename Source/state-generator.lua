import 'CoreLibs/object'

import 'game-state'
import 'lib/list'

local MS_PER_FRAME <const> = 1000 // playdate.display.getRefreshRate()
local TIME_LIMIT = 0.9 * MS_PER_FRAME
local MAX_DEPTH = 5
local MAX_TREE_SIZE = 3000

-- Returns a hash of the move
function hashMove(move)
	assert(move ~= nil)
	return move.x + NUM_BOARD_SPACES * move.y
end

class('StateGenerator').extends()

function StateGenerator:init(initialGameState)
	StateGenerator.super.init(self)
	self.queue = List.new()
	self.tree = {}	
	self.tree[initialGameState] = {}
	self.treeTop = initialGameState
	self.treeSize = 1
	
	List.pushEnd(self.queue, initialGameState)
end

-- Kills this node and every child
function StateGenerator:cull(gameStateToCull)	
	assert(gameStateToCull ~= nil)	
	
	List.forEach(gameStateToCull.validMoves, function(move) 		
		local moveHash = hashMove(move)
		local deadState = self.tree[gameStateToCull][moveHash]
		if (deadState ~= nil) then
			self:cull(deadState)
		end
		self.tree[gameStateToCull][moveHash] = nil
	end)
	
	self.tree[gameStateToCull] = nil		
	self.treeSize -= 1
end

-- Moves this node to the top of the true
function StateGenerator:setNewRoot(fromGameState, toMove)
	local toMoveHash = hashMove(toMove)
	local newTreeTop = self.tree[fromGameState][toMoveHash]		
	self.treeTop = newTreeTop

	-- Clean up the move list first	
	List.forEach(fromGameState.validMoves, function(deadMove) 		
		local deadMoveHash = hashMove(deadMove)
		if (deadMoveHash ~= toMoveHash) then
			local deadState = self.tree[fromGameState][deadMoveHash]
			if (deadState ~= nil) then
				self:cull(deadState)
			end
		end
	end)
	
	self.tree[fromGameState] = nil	
	self.treeSize -= 1	
end

-- Virtually executes this move by resetting the root and returning the new state
function StateGenerator:makeMove(gameState, move)
	assert(gameState == self.treeTop)
	assert(self.tree[gameState][hashMove(move)] ~= null)
	
	local newGameState = self.tree[gameState][hashMove(move)]
	self:setNewRoot(gameState, move)
	
	assert(newGameState == self.treeTop)
	
	return newGameState
end

-- Returns the game state associated with this move
function StateGenerator:getState(gameState, move)
	return self.tree[gameState][hashMove(move)]
end

-- Deletes all generated states and starts over with new states
function StateGenerator:reset(newInitialGameState)
	assert(newInitialGameState ~= nil)	
	self.queue = List.new()
	self.tree = {}	
	self.tree[newInitialGameState] = {}
	self.treeTop = newInitialGameState
	self.treeSize = 1
	
	List.pushEnd(self.queue, newInitialGameState)
end

function StateGenerator:update()
	local topDepth = self.treeTop.depth
	-- Only run this if we have room in the tree to add more states
	repeat
		if (self.queue.length > 0) then
			local fromGameState = List.peekFront(self.queue)
			
			-- We are working on the depth below this one
			self.depth = fromGameState.depth + 1 - topDepth + 1
						
			if (self.tree[fromGameState] == nil or fromGameState.validMoveQueue.length == 0) then
				-- If the state is dead or there are no moves left to process, remove it from the queue and move on	
				
				-- Remove this element from the queue
				List.popFront(self.queue)
			elseif(self.depth <= MAX_DEPTH and self.treeSize <= MAX_TREE_SIZE) then
				-- Don't run if we're out of space to do our calculations
					
				-- Grab a move to evaluate
				local toMove = List.popFront(fromGameState.validMoveQueue)						
				
				-- Generate the new state
				local newState = fromGameState:copy()
				newState:makeMove(toMove)
				
				-- Update the tree			
				self.tree[fromGameState][hashMove(toMove)] = newState
				self.tree[newState] = {}
				self.treeSize += 1
				
				-- Queue the new state to be processed as well
				List.pushEnd(self.queue, newState)
			end
		end
	until playdate.getCurrentTimeMilliseconds() - frameStartTime > TIME_LIMIT or self.depth > MAX_DEPTH or self.queue.length == 0 or self.treeSize > MAX_TREE_SIZE
end