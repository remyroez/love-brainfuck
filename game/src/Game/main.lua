
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- クラス
local Application = require 'Application'
local Interpreter = require 'Interpreter'

-- 初期化
function Game:initialize(...)
    Application.initialize(self, ...)
end

-- 読み込み
function Game:load(...)
    self.font = love.graphics.newFont('assets/misaki_gothic_2nd.ttf', 12)

    -- スクリーンサイズ
    self.width, self.height = love.graphics.getDimensions()

    -- Ook! 言語
    local Ook = {
        increment = 'Ook. Ook.',
        decrement = 'Ook! Ook!',
        backward = 'Ook? Ook.',
        forward = 'Ook. Ook?',
        output = 'Ook! Ook.',
        input = 'Ook. Ook!',
        open = 'Ook! Ook?',
        close = 'Ook? Ook!',
    }

    -- けもフレ言語
    local kemofre = {
        increment = 'たーのしー',
        decrement = 'すっごーい！',
        backward = 'すごーい！',
        forward = 'たのしー！',
        output = 'なにこれなにこれ！',
        input = 'おもしろーい！',
        open = 'うわー！',
        close = 'わーい！',
    }

    self.interpreter = Interpreter(kemofre)
    self.interpreter:load(
        --'+++++++++[>++++++++>+++++++++++>+++>+<<<<-]>.>++.+++++++..+++.>+++++.<<+++++++++++++++.>.+++.------.--------.>+.>+.'
        'たのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！うわー！すごーい！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たのしー！すっごーい！わーい！すごーい！なにこれなにこれ！たのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！うわー！すごーい！たーのしー！たーのしー！たーのしー！たーのしー！たのしー！すっごーい！わーい！すごーい！たーのしー！なにこれなにこれ！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！なにこれなにこれ！なにこれなにこれ！たーのしー！たーのしー！たーのしー！なにこれなにこれ！うわー！すっごーい！わーい！たのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！うわー！すごーい！たーのしー！たーのしー！たーのしー！たーのしー！たのしー！すっごーい！わーい！すごーい！なにこれなにこれ！たのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！うわー！すごーい！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たのしー！すっごーい！わーい！すごーい！なにこれなにこれ！たのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！うわー！すごーい！たーのしー！たーのしー！たーのしー！たのしー！すっごーい！わーい！すごーい！なにこれなにこれ！たーのしー！たーのしー！たーのしー！なにこれなにこれ！すっごーい！すっごーい！すっごーい！すっごーい！すっごーい！すっごーい！なにこれなにこれ！すっごーい！すっごーい！すっごーい！すっごーい！すっごーい！すっごーい！すっごーい！すっごーい！なにこれなにこれ！うわー！すっごーい！わーい！たのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！うわー！すごーい！たーのしー！たーのしー！たーのしー！たーのしー！たのしー！すっごーい！わーい！すごーい！たーのしー！なにこれなにこれ！うわー！すっごーい！わーい！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！たーのしー！なにこれなにこれ！'
        --'Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook?Ook. Ook?Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook? Ook.Ook! Ook!Ook? Ook!Ook. Ook?Ook. Ook.Ook. Ook.Ook! Ook.Ook? Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook?Ook. Ook?Ook. Ook.Ook. Ook.Ook? Ook.Ook! Ook!Ook? Ook!Ook. Ook?Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook.Ook! Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook.Ook? Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook?Ook. Ook?Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook? Ook.Ook! Ook!Ook? Ook!Ook. Ook?Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook.Ook? Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook?Ook. Ook?Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook? Ook.Ook! Ook!Ook? Ook!Ook. Ook?Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook.Ook? Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook?Ook. Ook?Ook. Ook.Ook. Ook.Ook? Ook.Ook! Ook!Ook? Ook!Ook. Ook?Ook. Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook.Ook. Ook.Ook. Ook.Ook. Ook.Ook! Ook.Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook.Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook!Ook! Ook.'
    )
end

-- 更新
function Game:update(dt, ...)
end

-- 描画
function Game:draw(...)
    love.graphics.printf(
        'counter: ' .. self.interpreter.counter
        .. '\npointer: ' .. self.interpreter.pointer
        .. '\n\nprogram:'
        ,
        self.font, 16, 16, self.width - 32)
    love.graphics.printf(self.interpreter.program, self.font, 16, self.font:getHeight() * 4 + 16, self.width - 32, 'left')
    love.graphics.printf('buffer:\n' .. self.interpreter.buffer, self.font, 16, self.height * 0.5, self.width - 32)
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if key == 'space' then
        self.interpreter:step()
    elseif key == 'return' then
        self.interpreter:run()
    end
end

-- キー離した
function Game:keyreleased(key, scancode)
end

-- テキスト入力
function Game:textinput(text)
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end

-- マウス離した
function Game:mousereleased(x, y, button, istouch, presses)
end

-- マウス移動
function Game:mousemoved(x, y, dx, dy, istouch)
end

-- マウスホイール
function Game:wheelmoved(x, y)
end

-- リサイズ
function Game:resize(width, height)
end
