--[[
    GD50
    Match-3 Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Match-3 has taken several forms over the years, with its roots in games
    like Tetris in the 80s. Bejeweled, in 2001, is probably the most recognized
    version of this game, as well as Candy Crush from 2012, though all these
    games owe Shariki, a DOS game from 1994, for their inspiration.

    The goal of the game is to match any three tiles of the same variety by
    swapping any two adjacent tiles; when three or more tiles match in a line,
    those tiles add to the player's score and are removed from play, with new
    tiles coming from the ceiling to replace them.

    As per previous projects, we'll be adopting a retro, NES-quality aesthetic.

    Credit for graphics (amazing work!):
    https://opengameart.org/users/buch

    Credit for music (awesome track):
    http://freemusicarchive.org/music/RoccoW/

    Cool texture generator, used for background:
    http://cpetry.github.io/TextureGenerator-Online/
]]


love.graphics.setDefaultFilter('nearest', 'nearest')


require 'src/Dependencies'


cindy.applyPatch()


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720


VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

BACKGROUND_SCROLL_SPEED = 80

function love.load()

    love.window.setTitle('Match 3')

    

    cursor = love.mouse.getCursor()

 
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
        canvas = true
    })

    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    bgrX = 0

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
 
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end


function love.mousepressed(x, y, button, istouch, presses)
    love.mouse.buttons[button] = true
end

function love.mouse.wasPressed(button)
    if love.mouse.buttons[button] then
        return true
    else
        return false
    end
end

function love.update(dt)

    bgrX = bgrX - BACKGROUND_SCROLL_SPEED * dt

    if bgrX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
        bgrX = 0
    end

    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}

    love.mouse.buttons = {}

    if love.mouse.isDown(2) then
    print("normal: ")
    print(love.mouse.getPosition())
    print("game: ")
    print(push:toGame(love.mouse.getPosition()))
    end

    
end

function love.draw()
    push:start()

    love.graphics.draw(gTextures['background'], bgrX, 0)
    
    gStateMachine:render()
    push:finish()
end
