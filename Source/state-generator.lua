import 'CoreLibs/object'

import 'game-state'
import 'lib/queue'

local MS_PER_FRAME <const> = 1000 // playdate.display.getRefreshRate()
local TIME_LIMIT = 0.9 * MS_PER_FRAME
local MAX_TREE_SIZE = 1500

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
	
	List.pushright(self.queue, initialGameState)
end

-- Kills this node and every child
function StateGenerator:cull(gameStateToCull)	
	assert(gameStateToCull ~= nil)	
	for i = gameStateToCull.validMoves.first,gameStateToCull.validMoves.last do
		local move = gameStateToCull.validMoves[i]
		local moveHash = hashMove(move)
		local deadState = self.tree[gameStateToCull][moveHash]
		if (deadState ~= nil) then
			self:cull(deadState)
		end
		self.tree[gameStateToCull][moveHash] = nil
	end
	
	self.tree[gameStateToCull] = nil		
	self.treeSize -= 1
end

-- Moves this node to the top of the true
function StateGenerator:setNewRoot(fromGameState, toMove)
	local toMoveHash = hashMove(toMove)
	local newTreeTop = self.tree[fromGameState][toMoveHash]		
	self.treeTop = newTreeTop

	-- Clean up the move list first
	for i = fromGameState.validMoves.first,fromGameState.validMoves.last do
		local deadMove = fromGameState.validMoves[i]
		local deadMoveHash = hashMove(deadMove)
		if (deadMoveHash ~= toMoveHash) then
			local deadState = self.tree[fromGameState][deadMoveHash]
			if (deadState ~= nil) then
				self:cull(deadState)
			end
		end
	end
	
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
	
	List.pushright(self.queue, newInitialGameState)
end

function StateGenerator:update()
	if (self.treeSize < MAX_TREE_SIZE) then
		-- Only run this if we have room in the tree to add more states
		repeat
			if (self.queue.length > 0) then
				local fromGameState = List.peekleft(self.queue)
				
				-- If the state is dead or there are no moves left to process, remove it from the queue and move on				
				if (self.tree[fromGameState] == nil or fromGameState.validMoveQueue.length == 0) then
					-- Remove this element from the queue
					List.popleft(self.queue)			
				else						
					-- Grab a move to evaluate
					local toMove = List.popleft(fromGameState.validMoveQueue)						
					
					-- Generate the new state
					local newState = fromGameState:copy()
					newState:makeMove(toMove)
					
					-- Update the tree			
					self.tree[fromGameState][hashMove(toMove)] = newState
					self.tree[newState] = {}
					self.treeSize += 1
					
					-- Queue the new state to be processed as well
					List.pushright(self.queue, newState)
				end
			end
		until playdate.getCurrentTimeMilliseconds() - frameStartTime > TIME_LIMIT or self.treeSize > MAX_TREE_SIZE or self.queue.length == 0
	end
end