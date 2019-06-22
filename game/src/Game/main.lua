
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

    -- ヘイセイバー言語
    local heisei = {
        increment = 'ヘイ！',
        decrement = 'ディディディディケイド！',
        backward = '平成ライダーズ！',
        forward = '仮面ライダーズ！',
        output = 'セイ！',
        input = 'ヘヘヘイ！',
        open = 'フィニッシュタイム！',
        close = 'アルティメットタイムブレイク！',
    }

    -- 変換先の言語
    local lang = Interpreter.defaultOperators

    -- プロセッサ
    self.processor = Processor()

    -- インタプリタ
    self.interpreter = Interpreter()

    -- Brainfuck コードを、別言語コードへ変換
    local code = '+++++++++[>++++++++>+++++++++++>+++>+<<<<-]>.>++.+++++++..+++.>+++++.<<+++++++++++++++.>.+++.------.--------.>+.>+.'
    if false then
        lang = heisei
        self.converter = Converter(lang)
        self.interpreter:resetProcessor(self.converter)
        self.interpreter:load(code)
        self.interpreter:run()
        code = self.converter.buffer
    end

    -- プロセッサと命令セットを再設定
    self.interpreter:resetProcessor(self.processor)
    self.interpreter.operators = lang

    -- プログラム
    self.interpreter:load(code)
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
