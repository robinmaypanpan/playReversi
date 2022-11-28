import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'lib/AnimatedSprite'

local gfx = playdate.graphics

class('Cursor').extends(AnimatedSprite)

function Cursor:init()	
	Cursor.super.init(self, gfx.imagetable.new('assets/images/cursor'))
	
	self:addState('valid', 1, 3, {tickStep = 5, yoyo = true})
	self:addState('invalid', 4, 5, {tickStep = 13})
	self:setZIndex(20)
end

function Cursor:setValidPosition(isValid)
	self.isValid = isValid
	if (isValid) then
		self:changeState('valid', true)
	else
		self:changeState('invalid', true)
	end
end