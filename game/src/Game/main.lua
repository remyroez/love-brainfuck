
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- クラス
local Application = require 'Application'
local Interpreter = require 'Interpreter'
local Processor = require 'Processor'
local Converter = require 'Converter'

-- 初期化
function Game:initialize(...)
    Application.initialize(self, ...)
    self:debugInitialize()
end

-- 読み込み
function Game:load(...)
    self.font = love.graphics.newFont('assets/misaki_gothic_2nd.ttf', 12)

    -- スクリーンサイズ
    self.width, self.height = love.graphics.getDimensions()

    -- プロセッサ
    self.processor = Processor()

    -- コンバーター
    self.converter = Converter()

    -- インタプリタ
    self.interpreter = Interpreter()

    -- プロセッサと命令セットを設定
    self.interpreter:resetProcessor(self.processor)

    -- プログラム
    self.interpreter:load()
end

-- 更新
function Game:update(dt, ...)
    self.interpreter:update()

    if self.debugMode then
        self:debugUpdate(dt)
    end
end

-- 描画
function Game:draw(...)
    -- プロセッサのバッファ
    love.graphics.printf(
        self.processor.buffer,
        self.font, 0, self.debugMode and self.font:getHeight() or 0, self.width
    )

    if self.debugMode then
        self:debugDraw()
    end
end

-- プログラム実行
function Game:toggleProgram()
    self.interpreter:toggle()
end

-- プログラム実行
function Game:completeRunProgram()
    self.interpreter:run('complete')
end

-- プログラムステップ実行
function Game:stepProgram()
    self.interpreter:stop()
    self.interpreter:step()
end

-- 環境のリセット
function Game:resetEnvironment()
    self.interpreter:resetProcessor()
    self.interpreter:resetCounter()
end

-- 環境のリセット
function Game:newEnvironment()
    self:resetEnvironment()
    self.interpreter:load()
end

-- 入力待ちかどうか
function Game:isWaitForInput()
    return self.interpreter.state == 'input'
end

-- コンバート
function Game:convert(op)
    self:resetEnvironment()

    self.converter.operators = op
    self.interpreter:resetProcessor(self.converter)
    self.interpreter:run()
    self.interpreter:load(self.converter.buffer)
    self.interpreter:resetProcessor(self.processor)
    self.interpreter.operators = op
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
end

-- キー離した
function Game:keyreleased(key, scancode)
end

-- テキスト入力
function Game:textinput(text)
    if not self:isWaitForInput() then
        -- 入力待ちではない
    elseif text:match("%w") or text:match("%W") then
        -- 入力可能な文字だったので入力
        self.interpreter:input(text:byte(), true)
    else
        -- それ以外の文字
    end
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
    self.width, self.height = love.graphics.getDimensions()
end
