require"cupid"
function love.conf(t)
    t.title = "colors"        -- The title of the window the game is in (string)
    t.author = "Rob"        -- The author of the game (string)
    t.url = nil                 -- The website of the game (string)
    t.identity = "i love colors"            -- The name of the save directory (string)
    t.version = "0.8.0"         -- The LÖVE version this game was made for (string)
	t.screen.width = 640
    t.screen.height = 480
	--t.console=true
end