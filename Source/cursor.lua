import "CoreLibs/object"
import 'CoreLibs/sprites'

local gfx = playdate.graphics

class('Cursor').extends(gfx.sprite)

function Cursor:init(spaceSize)	
	Cursor.super.init(self)
	self.spaceSize = spaceSize;
	self:setImage(self:drawCursor())
end

function Cursor:drawCursor()
	local cursorSize = self.spaceSize + 20
	local cursorImage = gfx.image.new(cursorSize, cursorSize)
	gfx.pushContext(cursorImage)		
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(10)
		gfx.drawRect(0, 0, cursorSize, cursorSize)
	gfx.popContext()
	return cursorImage
end