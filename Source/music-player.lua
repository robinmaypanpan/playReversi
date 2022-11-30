music = {}


-- settings
local repeatCount = 2
local silenceDelay = 5000

-- data
local playlist = {
	'assets/audio/flipflop',
	'assets/audio/flipflop',
	'assets/audio/flipflop',
	'assets/audio/flipflop'
}

local playlistIndex = 1

local musicPlayer


local function randomizeTable( t )
	-- randomize the item orders of the table t
	for i = #t, 2, -1 do
		local j = math.random(i)
		if i ~= j then
			t[i], t[j] = t[j], t[i]
		end
	end
end

function music.init()	
	musicPlayer = playdate.sound.fileplayer.new()	
	randomizeTable(playlist)
	musicPlayer:load(playlist[1])
	musicPlayer:setStopOnUnderrun(false)
	
	musicPlayer:setFinishCallback(function(musicPlayer)
		local playlistSize = table.getsize(playlist)
		playlistIndex += 1
		if (playlistIndex > playlistSize) then
			randomizeTable(playlist)
			playlistIndex = 1
		end
		local nextSong = playlist[playlistIndex]
		
		musicPlayer:load(playlist[playlistIndex])
		playdate.timer.performAfterDelay(silenceDelay, function()			
			musicPlayer:play(repeatCount)
		end)
	end)
end

function music.play()	
	musicPlayer:play(repeatCount)
end