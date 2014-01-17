local map -- stores tiledata
local mapWidth, mapHeight -- width and height in tiles
local mapX, mapY -- tile in upper-left. can be a fractional value like 3.25.
local textureAtlas
local textures = {} -- parts of the tileset used for different tiles
local tileSize -- size of tiles in pixels
local tilesDisplayWidth, tilesDisplayHeight -- number of tiles to show
local scaleX, scaleY

function love.load()
	math.randomseed(os.time())
	love.graphics.setNewFont(12)

	initMap()
	initTiles()
end

function initMap()
	mapWidth = 2000
	mapHeight = 2000
	
	map = {}
	
	for x = 1, mapWidth do
		map[x] = {}
		
		for y = 1, mapHeight do
			map[x][y] = 1
		end
	end

	mapX = 1
	mapY = 1

	tilesDisplayWidth = 26
	tilesDisplayHeight = 20
	
	scaleX = 1
	scaleY = 1
end

function initTiles()
	textureAtlas = love.graphics.newImage("tileset.png")
	textureAtlas:setFilter("nearest", "linear")

	tileSize = 32
	
	textures[0] = love.graphics.newQuad(0 * tileSize, 0 * tileSize, tileSize, tileSize, textureAtlas:getWidth(), textureAtlas:getHeight())
	textures[1] = love.graphics.newQuad(4 * tileSize, 0 * tileSize, tileSize, tileSize, textureAtlas:getWidth(), textureAtlas:getHeight())
	
	tilesetBatch = love.graphics.newSpriteBatch(textureAtlas, tilesDisplayWidth * tilesDisplayHeight)
	
	updateTilesetBatch()
end

function updateTilesetBatch()
	tilesetBatch:clear()
	
	for x = 0, tilesDisplayWidth - 1 do
		for y = 0, tilesDisplayHeight - 1 do
			tilesetBatch:add(textures[map[x + math.floor(mapX)][y + math.floor(mapY)]], x * tileSize, y * tileSize)
		end
	end
end

function moveMap(dx, dy)
	oldMapX = mapX
	oldMapY = mapY

	mapX = math.max(math.min(mapX + dx, mapWidth - tilesDisplayWidth), 1)
	mapY = math.max(math.min(mapY + dy, mapHeight - tilesDisplayHeight), 1)

	if math.floor(mapX) ~= math.floor(oldMapX) or math.floor(mapY) ~= math.floor(oldMapY) then
		updateTilesetBatch()
	end
end

function love.mousepressed(x, y, button)	
	if button == "l" then
		clickedTileX = math.floor((x / tileSize) + mapX)
		clickedTileY = math.floor((y / tileSize) + mapY)

		print("click pixel " .. x .. " " .. y .. " tile " .. clickedTileX .. " " .. clickedTileY)
		
		map[clickedTileX][clickedTileY] = 0
		updateTilesetBatch()
	end
end


function love.update(dt)
	if love.keyboard.isDown("up") then
		moveMap(0, -0.2 * tileSize * dt)
	end
	
	if love.keyboard.isDown("down") then
		moveMap(0, 0.2 * tileSize * dt)
	end
	
	if love.keyboard.isDown("left") then
		moveMap(-0.2 * tileSize * dt, 0)
	end
	
	if love.keyboard.isDown("right") then
		moveMap(0.2 * tileSize * dt, 0)
	end
end

function love.draw()
	love.graphics.draw(tilesetBatch, math.floor(-scaleX * (mapX % 1) * tileSize), math.floor(-scaleY * (mapY % 1) * tileSize), 0, scaleX, scaleY)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 20)
end
