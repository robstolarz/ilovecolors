i love colors
-------------

This is a game based on the letting go engine.
It's about self-perspective based on surroundings.
(Except it's not a game but more of an opensource engine thing whatevs)

##To run
Get Love2D and drop the src/ folder onto the Love2D executable
###Editor
* Start editor with `api.edit` from the ingame console (which can be opened with ~ key)
* See the existing level files to find out how to swap tilesets and add entities (because LevEdit doesn't have that)
* Use the arrow keys to switch universe screens
* Hold I to open the Tile Chooser and click to pick a certain tile
* Press C to toggle Collision Editing mode
    * Tile # 0 means no collision, 1 is solid
* Type F to bring up the File Chooser
    * Type a filename and press Enter to Save
    * Type a filename and type @ to Load
    * Press Shift+F to save to the current universe level
* Press Enter when not in a menu to activate the Tile: prompt
    * Type the tile number to choose it or 0 for clearing
    * Press it again without typing to keep the same tile but show what tile you're using
* Press ~ to open the console
    * `api.playhere` starts the game at the current universe location (save first)
        * `api.spawn("Player",123,456)` will spawn a player at location 123,456 in game
        * `api.edit` brings you back to the editor from the game
    * `api.changetex("your mother",2)` will change the second layer texture to the tileset named "your mother"
