--game.lua

Game = {}

function Game:new()
    local gameMusic = love.audio.newSource("assets/sounds/game.mp3", "stream")
    gameMusic:setVolume(0.5)
    local buttonTryAgain = love.graphics.newImage("assets/img/button_tryagain.png")
    local buttonContinue = love.graphics.newImage("assets/img/button_continue.png")
    local pauseOrLoseBg = love.graphics.newImage("assets/img/bg_gameover.png")
    
    local soundOnImage = love.graphics.newImage("assets/img/s_on.png")
    local soundOffImage = love.graphics.newImage("assets/img/s_off.png")

    local scoreSound = love.audio.newSource("assets/sounds/coin.mp3", "static")
    local jumpSound = love.audio.newSource("assets/sounds/jump.wav", "static")
    local gameOverSound = love.audio.newSource("assets/sounds/death.mp3", "static")


    local locationStart = love.graphics.newImage("assets/img/lock_1.png")
    local locationBoss = love.graphics.newImage("assets/img/loc2.png")

    local playerDefault = love.graphics.newImage("assets/img/main1.png")
    local playerRun = love.graphics.newImage("assets/img/main2.1.png")
    local playerShoot1 = love.graphics.newImage("assets/img/main3.1.png")
    local playerShoot2 = love.graphics.newImage("assets/img/main3.2.png")
    local currentLocation = locationStart

    local closeDoor = love.graphics.newImage("assets/img/door_closed.png")
    local openDoor = love.graphics.newImage("assets/img/door_opened.png")


    local game = {
        buttons = {},
        visibleButtons = {},
        bullets = {},
        openDoor = openDoor,
        closeDoor = closeDoor,
        pauseOrLoseBg = pauseOrLoseBg,
        gameMusic = gameMusic,
        gameOverSound = gameOverSound,
        soundOnImage = soundOnImage,
        soundOffImage = soundOffImage,
        soundIcon = soundOnImage,
        soundEnabled = true,
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        locationStart = locationStart,
        locationBoss = locationBoss,
        currentLocation = 'locationStart',
        scaleX = screenWidth / currentLocation:getWidth(),
        scaleY = screenHeight / currentLocation:getHeight(),
        flagPause = false,
        isGameOver = false,
        gameStart = false
    }

    setmetatable(game, { __index = self })

    -- Добавление кнопок
    game:addButton("tryAgain", "button_tryagain.png", game.screenWidth/2, game.screenHeight/2, function() game:restartGame() end)
    game:addButton("continue", "button_continue.png", game.screenWidth/2 , game.screenHeight/2, function() game:togglePause() end)
    game:addButton("menu", "button_menu.png", menu.screenWidth/2, menu.screenHeight/2, function() currentGameState=gameState.MENU game:restartGame() end)

    local soundButton = {
        name = "sound",
        image = soundOnImage,
        x = 10,
        y = 10,
        width = soundOnImage:getWidth(),
        height = soundOnImage:getHeight(),
        callback = function() game:toggleSound() end
    }

    local player = {
        x = screenWidth / 2,  -- initial x position
        y = screenHeight / 2, -- initial y position
        speed = 200,           -- player movement speed
        stand = playerDefault,   -- initial player icon
        run = playerRun,
        icon = playerDefault,
        health = 3
    }

    game.player = player

    table.insert(game.buttons, soundButton)

    return game
end

function Game:restartGame()
    self.isGameOver = false
    self.gameStart = false
    self.flagPause = false
    self:getActiveButton().selected = false
end

function Game:draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    local hpY = 0
    if self.currentLocation == 'locationStart'then
        hpY = 25
    else
        hpY = self.screenHeight - 25 - love.graphics.newImage("assets/img/hp1.png"):getHeight()
    end

    if self.player.health == 3 then
        love.graphics.draw(love.graphics.newImage("assets/img/hp1.png"), 25,hpY, 0, self.scaleX/3, self.scaleY)
    elseif self.player.health == 2 then
        love.graphics.draw(love.graphics.newImage("assets/img/hp2.png"), 25,hpY, 0, self.scaleX/3, self.scaleY)
    elseif self.player.health == 1 then
        love.graphics.draw(love.graphics.newImage("assets/img/hp3.png"), 25,hpY, 0, self.scaleX/3, self.scaleY)
    elseif self.player.health < 1 then
        love.graphics.draw(love.graphics.newImage("assets/img/hp4.png"), 25,hpY, 0, self.scaleX/3, self.scaleY)
    end

    for i, bullet in ipairs(self.bullets) do
        love.graphics.draw(love.graphics.newImage("assets/img/shoot3.png"), bullet.x, bullet.y, 0)
    end
    
    if self.currentLocation == 'locationStart'then
        love.graphics.draw(self.locationStart, self.screenWidth/4,0, 0, self.scaleX/2, self.scaleY)
        love.graphics.draw(self.player.icon, self.player.x, self.player.y, 0)
        love.graphics.draw(self.openDoor, self.screenWidth/2 - self.openDoor:getWidth()*self.scaleX/4, self.screenHeight - self.openDoor:getHeight()*self.scaleY,0,self.scaleX/2, self.scaleY)
    end

    if self.currentLocation == 'locationBoss' then
        love.graphics.draw(self.locationBoss, self.screenWidth/2-self.locationBoss:getWidth()/2 / self.scaleX - 55,0, 0, self.scaleX/2, self.scaleY)
        love.graphics.draw(self.openDoor, self.screenWidth/2 - self.openDoor:getWidth()*self.scaleX/4, 0,0,self.scaleX/2, self.scaleY)
        love.graphics.draw(self.player.icon, self.player.x, self.player.y, 0)
    end

    if self.isGameOver or self.flagPause then
        love.graphics.draw(self.pauseOrLoseBg, 0, 0, 0, self.scaleX, self.scaleY)
        -- Отрисовка кнопок
        for _, button in pairs(self.visibleButtons) do
            if button.selected then
                love.graphics.setColor(1, 1, 1, 0.96)
            else
                love.graphics.setColor(0.5, 0.5, 0.5, 0.92)
            end
            if button.name == "tryAgain" then 
                love.graphics.draw(button.image, button.x, button.y+button.image:getHeight()*self.scaleY*1.5, 0, self.scaleX, self.scaleY)
            else
                love.graphics.draw(button.image, button.x, button.y, 0, self.scaleX, self.scaleY)
            end
        end

        -- Восстановление цвета
        love.graphics.setColor(1, 1, 1)
    end
end

function Game:shoot(direction)
    local bulletSpeed = 400 -- adjust the bullet speed as needed
    local bulletImage = love.graphics.newImage("assets/img/shoot3.png")
    local bullet = {
        x = self.player.x + self.player.icon:getWidth() / 2,
        y = self.player.y + self.player.icon:getHeight() / 2,
        speed = bulletSpeed,
        direction = direction,
        image = bulletImage
    }
    table.insert(self.bullets, bullet)
end

function Game:update(dt)
    if self.gameStart and not self.isGameOver and not self.flagPause then
        self:updatePlayer(dt)
        for i, bullet in ipairs(self.bullets) do
            if bullet.direction == 1 then
                bullet.y = bullet.y - bullet.speed * dt
            elseif bullet.direction == 2 then
                bullet.x = bullet.x + bullet.speed * dt
            elseif bullet.direction == 3 then
                bullet.y = bullet.y + bullet.speed * dt
            elseif bullet.direction == 4 then
                bullet.x = bullet.x - bullet.speed * dt
            end

            -- Remove bullets that go off-screen
            if bullet.x < 0 or bullet.x > self.screenWidth or
            bullet.y < 0 or bullet.y > self.screenHeight then
                table.remove(self.bullets, i)
            end
        end
        for i, button in pairs(self.buttons) do
            if button.callback == self.toggleSound then
                button.image = self.soundIcon
            end
        end
    end
end

function Game:updatePlayer(dt)
    local player = self.player

    -- Move player based on keyboard input
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    elseif love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end

    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
    elseif love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
    end

    if self.currentLocation == 'locationStart' then
        if player.x <= self.screenWidth/4+10 then 
            player.x = self.screenWidth/4+10 end
        if player.x >= self.screenWidth/5+10 + self.locationStart:getWidth()/self.scaleX then
            player.x = self.screenWidth/5+10 + self.locationStart:getWidth()/self.scaleX end
        if player.y - 50< 0 then player.y = 50 end

        if (player.x < self.screenWidth/2 - self.openDoor:getWidth()*self.scaleX/4 and player.y + player.icon:getHeight() >= self.screenHeight)
        or (player.x > self.screenWidth/2 + self.openDoor:getWidth()*self.scaleX/5 and player.y + player.icon:getHeight() >= self.screenHeight) then
            player.y = self.screenHeight - player.icon:getHeight() 
        end

        if player.y > self.screenHeight then
            self.currentLocation = 'locationBoss'
            player.y = player.icon:getHeight() 
        end
    end

    if self.currentLocation == 'locationBoss' then
        if player.x <= self.screenWidth/2-self.locationBoss:getWidth()/self.scaleX/2 - 13 then 
            player.x = self.screenWidth/2-self.locationBoss:getWidth()/self.scaleX/2 - 13 end
        if player.x + player.icon:getHeight()>= self.screenWidth/2+self.locationBoss:getWidth()/self.scaleX/2 + 13 then
            player.x = self.screenWidth/2+self.locationBoss:getWidth()/self.scaleX/2 + 13 - player.icon:getHeight() end
        if player.y > self.locationBoss:getHeight() then player.y = 50 end

        if (player.x < self.screenWidth/2 - self.openDoor:getWidth()*self.scaleX/4 and player.y + player.icon:getHeight() >= self.screenHeight)
        or (player.x > self.screenWidth/2 + self.openDoor:getWidth()*self.scaleX/5 and player.y + player.icon:getHeight() >= self.screenHeight) then
            player.y = self.screenHeight - player.icon:getHeight() 
        end

        if player.y < 0 then
            self.currentLocation = 'locationStart'
            player.y = self.screenHeight-player.icon:getHeight() 
        end
    end
    -- Update player icon based on movement
    if love.keyboard.isDown("left") or love.keyboard.isDown("right") or
       love.keyboard.isDown("up") or love.keyboard.isDown("down") then
        player.icon = player.run
    else
        player.icon = player.stand
    end
end































function Game:startMusic()
    -- Установка музыки на повторение и воспроизведение
    self.gameMusic:setLooping(true)
    love.audio.play(self.gameMusic)
end

function Game:stopMusic()
    self.gameMusic:setLooping(false)
    love.audio.stop(self.gameMusic)
end

function Game:toggleSound()
    self.soundEnabled = not self.soundEnabled

    if self.soundEnabled then
        self.soundIcon = self.soundOnImage
    else
        self.soundIcon = self.soundOffImage
    end
    for i, button in ipairs(self.buttons) do
        if button.name == "sound" then
            button.image = self.soundIcon
        end
    end
end

function Game:addButton(name, imageFile, x, y, callback)
    -- Создание изображения кнопки и добавление кнопки в массив
    local buttonImage = love.graphics.newImage("assets/img/" .. imageFile)
    local button = {
        name = name,
        image = buttonImage,
        x = x - buttonImage:getWidth()/2 * self.scaleX,
        y = y - buttonImage:getHeight() / 2 * self.scaleY + (#self.buttons * buttonImage:getHeight() * self.scaleY),
        selected = false,
        callback = callback,
        buttonMargin = buttonImage:getHeight() * self.scaleY * 1.5
    }

    table.insert(self.buttons, button)

    -- Пересчет координат всех кнопок после добавления новой
    local totalButtonHeight = #self.buttons * buttonImage:getHeight() * self.scaleY
    local centerY = self.screenHeight / 2

    for i, button in ipairs(self.buttons) do
        if i == 1 then button.selected = true end
        button.y = centerY - totalButtonHeight / 2 + (i - 1) * button.buttonMargin - (#self.buttons * buttonImage:getHeight() * self.scaleY) / 2.5
    end
end

function Game:togglePause()
    self.flagPause = not self.flagPause
end

function Game:mousepressed(x, y, button, istouch, presses)
    for i, button in pairs(self.buttons) do
        if x >= button.x and x <= button.x + button.image:getWidth() and y >= button.y and y <= button.y + button.image:getHeight() then
            if button.callback then
                button.callback()
            end
        end
    end
end

function Game:keypressed(key)
    if self.isGameOver == true or self.flagPause == true then
        if key == "return" or key == "kpenter" then
            -- Выполнение обратного вызова активной кнопки
            local activeButton = self:getActiveButton()
            if activeButton and activeButton.callback then
                activeButton.callback()
            end
        elseif key == "up" then
            self:moveSelection(-1)
        elseif key == "down" then
            self:moveSelection(1)
        end
    end
    if self.isGameOver == false then
        if key == "escape" then
            self:togglePause()
            self.visibleButtons = self:getVisibleButtons()
        end
    end
    if not self.flagPause then
        if key == "left" or key == "right" or key == "up" or key == "down" then
            self.gameStart = true
        end
        if key == "1" or key == "2" or key == "3" or key == "4" then
            self:shoot(key)
        end
    end
end

function Game:moveSelection(direction)
    -- Найти текущую выбранную кнопку
    local currentButton = self:getActiveButton()
    -- Снять выделение с текущей кнопки
    if currentButton then
        currentButton.selected = false
    end
    
    -- Вычислить индекс следующей кнопки
    local currentIndex = 1
    if currentButton then
        for i, button in ipairs(self.visibleButtons) do
            if button == currentButton then
                currentIndex = i
                break
            end
        end
    
        local nextIndex = ((currentIndex - 1) + direction) % #self.visibleButtons + 1
    
        -- Выделить следующую кнопку
        local nextButton = self.visibleButtons[nextIndex]
        if nextButton then
            nextButton.selected = true
        end
    end
end

function Game:getVisibleButtons()
    -- Возвращает массив только отображаемых кнопок
    local newVisibleButtons = {}
    for i, button in ipairs(self.buttons) do
        if (button.name == "tryAgain" and not self.flagPause) or
           (button.name == "continue" and not self.isGameOver) or
           (button.name == "sound") or
           (button.name == "menu") then
            table.insert(newVisibleButtons, button)
        end
    end
    newVisibleButtons[1].selected = true
    return newVisibleButtons
end


function Game:getActiveButton()
    for _, button in ipairs(self.visibleButtons) do
        if button.selected then
            return button
        end
    end
    return nil
end
