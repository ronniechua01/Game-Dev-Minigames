--[[
    GD50 2018
    Pong Remake

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'


-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 10)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
       
    }
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    
    
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    -- initialize score variables
    player1Score = 0
    player2Score = 0


    gameMode = ''


    difficulty = '' 
    side  = ''     
    controls = ''    

    servingPlayer = 1

    winningPlayer = 0

  
    gameState = 'menu'

   

end



function love.resize(w, h)
    push:resize(w, h)
end


function love.update(dt)
    if (gameState ~= 'menu' and gameState ~= 'diff_option' and gameState ~= 'side_option' and gameState ~= 'control_option') == false then
        
    end

    if (gameState ~= 'menu' and gameState ~= 'diff_option' and gameState ~= 'side_option' and gameState ~= 'control_option') == true then
        
    end

    if gameState == 'serve' then

        
        if gameMode == 'player_player' then                   ---player_player rules
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
                ball.dy = math.random(-50, 50)
             elseif servingPlayer == 2 then  --changes
                ball.dx = -math.random(140, 200)
                ball.dy = math.random(-50, 50)
            end 
        end 


        if servingPlayer == 1 and side == 'left' and gameMode == 'player_computer' then
            ball.dx = math.random(140, 200)
            ball.dy = math.random(-50, 50)
         elseif servingPlayer == 2 and side == 'left' and gameMode == 'player_computer' then  --changes
            ball.dx = -math.random(140, 200)
            ball.dy = math.random(-50, 50)
            gameState = 'play'
         elseif servingPlayer == 1 and side == 'right' and gameMode == 'player_computer'  then
                ball.dx = math.random(140, 200)
                ball.dy = math.random(-50, 50)
                gameState = 'play'
             elseif servingPlayer == 2 and side == 'right' and gameMode == 'player_computer' then  --changes
                ball.dx = -math.random(140, 200)
                ball.dy = math.random(-50, 50)
        end
     elseif gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end 

            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'

                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end
    end

    --
    -- paddles can move no matter what state we're in
    --
    -- player 1          ------------------------------------------- player_player                 
    if gameMode == 'player_player' then
     if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
     elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
     else
        player1.dy = 0
     end
     

     -- player 2
     if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
     elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
     else
        player2.dy = 0
     end
    end
---------------------------------------------------- player_computer
    if gameMode == 'player_computer' then   -- boing
        up_button = 'w'     -- because error
        down_button = 's'
     if controls == 'ws' then            -- set controls
        up_button = 'w'
        down_button = 's'
     elseif controls == 'ud' then
        up_button = 'up'
        down_button = 'down'
     end

     check_width = 0
     if difficulty == 'easy' then
        check_width = VIRTUAL_WIDTH/4
     elseif difficulty == 'hard' then
        check_width = VIRTUAL_WIDTH/2
     elseif difficulty == 'imp' then
        check_width = VIRTUAL_WIDTH
     end


     plyr = player1          --because error  --side
     plyr_n = player2
     if side == 'left' then
         plyr = player1
        plyr_n = player2
     elseif side == 'right' then
         plyr = player2 
         plyr_n = player1
     end
     if ((ball.x - plyr_n.x)^2)^(0.5)  < check_width then 
        if (plyr_n.y > (ball.y + ball.height/2))  then                    -- computer
            plyr_n.dy = -PADDLE_SPEED
         elseif (plyr_n.y + plyr_n.height < (ball.y + ball.height/2))  then
            plyr_n.dy = PADDLE_SPEED
         else
            plyr_n.dy = 0
        end
     end

     if love.keyboard.isDown(up_button) then             -- player
        plyr.dy = -PADDLE_SPEED
      elseif love.keyboard.isDown(down_button) then
        plyr.dy = PADDLE_SPEED
       else
        plyr.dy = 0
      end
   
    end

    
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end


function love.keypressed(key)

    if key == 'escape' then
        if gameState ~= 'menu' then
         gameState = 'menu'
         ball:reset()
         player1Score = 0
         player2Score = 0
         player1:reset1()
         player2:reset2()
        else
            love.event.quit()
        end


    elseif key == 'enter' or key == 'return' then
       
        
        if(gameMode == 'player_player') or (gameMode == 'player_computer' and ((side == 'left' and servingPlayer == 1) or (side == 'right' and servingPlayer == 2))) then
            if gameState == 'start' then
              gameState = 'serve'
          elseif gameState == 'serve' then
             gameState = 'play'
         elseif gameState == 'done' then

            gameState = 'serve'
    
    
            ball:reset()


            player1Score = 0
            player2Score = 0


            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end

         end
         elseif  (gameMode == 'player_computer') and ((side == 'left' and servingPlayer == 2) or (side == 'right' and servingPlayer == 1)) then
            if gameState == 'start' then
                gameState = 'serve'
            end
            
        end

    end
  
    
    -- the menu where one can choose to play standard player_player, against AI or watch
    if gameState == 'menu' then
        if key == '1'  then
            gameMode = 'player_player'
            gameState = 'start'
           
        elseif key == '2' then
            gameMode = 'player_computer'
            gameState = 'diff_option'
            
        else 
            
        end
    
    

    elseif gameState == 'diff_option' then 
    
        if key == '1'  then
            difficulty = 'easy'
            gameState = 'side_option'
            
        elseif key == '2' then
            difficulty = 'hard'
            gameState = 'side_option'
            
        elseif key == '3' then
            difficulty = 'imp'
            gameState = 'side_option'
            
        else 
            
        end
    
    elseif gameState == 'side_option' then
        
        if key == '1' then
            side = 'left'
            gameState = 'control_option'
            
        elseif key == '2' then
            side = 'right'
            gameState = 'control_option'
            
        else 
            
        end
        
    

    elseif gameState == 'control_option' then
        
        if key == '1' then 
            controls = 'ws'
            gameState = 'start'
            
        elseif key == '2' then
            controls = 'ud'
            gameState = 'start'
            
        else 
            
        end        
        

    end
end


function love.draw()
    
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
    
    if gameState == 'start' then
  
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
     elseif gameState == 'serve' then

        if gameMode == 'player_player' then
         love.graphics.setFont(smallFont)
         love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
         love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
         elseif gameMode == 'player_computer' then
            if (side == 'left' and servingPlayer == 1) or (side == 'right' and servingPlayer == 2) then
                love.graphics.setFont(smallFont)
             love.graphics.printf("Player's serve!", 0, 10, VIRTUAL_WIDTH, 'center')
             love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
             elseif (side == 'left' and servingPlayer == 2) or (side == 'right' and servingPlayer == 1) then
             love.graphics.setFont(smallFont)
             love.graphics.printf("Computer's serve",  0, 10, VIRTUAL_WIDTH, 'center')
             love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
           end
        end
     elseif gameState == 'play' then
        love.graphics.setFont(smallFont)
        if gameMode == 'player_computer' then
        end

     elseif gameState == 'done' then

        

       if gameMode == 'player_player' then
    love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 50, VIRTUAL_WIDTH, 'center')

         elseif gameMode == 'player_computer' then
         if (side == 'left' and winningPlayer == 1) or (side == 'right' and winningPlayer == 2) then
           love.graphics.setFont(largeFont)
         love.graphics.printf("Player wins", 0, 10, VIRTUAL_WIDTH, 'center')
         love.graphics.setFont(smallFont)
         love.graphics.printf('Press Enter to restart', 0, 30, VIRTUAL_WIDTH, 'center')
         elseif (side == 'left' and winningPlayer == 2) or (side == 'right' and winningPlayer == 1) then
         love.graphics.setFont(largeFont)
         love.graphics.printf("Computer wins",  0, 10, VIRTUAL_WIDTH, 'center')
         love.graphics.setFont(smallFont)
         love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
         end
       end 
       
     elseif gameState == 'menu' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a mode. Press the number on your keyboard.',0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. Player vs Player \n 2. Player vs Computer', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press esc to quit.', 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'right')
        
        
     elseif gameState == 'diff_option' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a difficulty. Press the number on your keyboard.',0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. Easy \n \n 2. Hard \n \n 3. Impossible' , 0, 50, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'side_option' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a side. Press the number on your keyboard.',0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(largeFont)
        love.graphics.printf('\t 1. Left \t\t\t\t\t\t\t 2. Right', 0, 125, VIRTUAL_WIDTH, 'left')
    
    elseif gameState == 'control_option' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose your controls. Press the number on your keyboard.',0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. W-S keys \n \n 2. Arrow keys', 0, 50, VIRTUAL_WIDTH, 'center')
 end

    displayScore()
    if gameState ~= 'menu' and gameState ~= 'diff_option' and gameState ~= 'side_option' and gameState ~= 'control_option' then
     player1:render()
     player2:render()
     ball:render()
    end


    displayFPS()


    push:apply('end')
end




function displayScore()

    if gameState ~= 'menu' and gameState ~= 'diff_option' and gameState ~= 'side_option' and gameState ~= 'control_option' then
     love.graphics.setFont(scoreFont)
     love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,VIRTUAL_HEIGHT / 3)
     love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,VIRTUAL_HEIGHT / 3)
    end
end


function displayFPS()
 
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
