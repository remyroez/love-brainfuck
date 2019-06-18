
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
    self.interpreter = Interpreter()
    self.interpreter:load('+++++++++[>++++++++>+++++++++++>+++>+<<<<-]>.>++.+++++++..+++.>+++++.<<+++++++++++++++.>.+++.------.--------.>+.>+.')
end

-- 更新
function Game:update(dt, ...)
end

-- 描画
function Game:draw(...)
    love.graphics.print('counter: ' .. self.interpreter.counter, 0, 0)
    love.graphics.print('pointer: ' .. self.interpreter.pointer, 0, 20)
    love.graphics.print(self.interpreter.buffer, 0, 40)
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
