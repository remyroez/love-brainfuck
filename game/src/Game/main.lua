
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
    local lang = heisei

    -- コンバータ
    self.converter = Converter(lang)

    -- プロセッサ
    self.processor = Processor()

    -- インタプリタ
    self.interpreter = Interpreter()
    self.interpreter:resetProcessor(self.converter)

    -- Brainfuck コードを、別言語コードへ変換
    self.interpreter:load('+++++++++[>++++++++>+++++++++++>+++>+<<<<-]>.>++.+++++++..+++.>+++++.<<+++++++++++++++.>.+++.------.--------.>+.>+.')
    self.interpreter:run()

    -- プロセッサと命令セットを再設定
    self.interpreter:resetProcessor(self.processor)
    self.interpreter.operators = lang

    -- プログラム
    self.interpreter:load(self.converter.buffer)
end

-- 更新
function Game:update(dt, ...)
    if self.debugMode then
        self:debugUpdate(dt)
    end
end

-- 描画
function Game:draw(...)
    love.graphics.printf(
        'counter: ' .. self.interpreter.counter
        .. '\npointer: ' .. self.processor.pointer
        .. '\n\nprogram:'
        ,
        self.font, 16, 16, self.width - 32)
    love.graphics.printf(self.interpreter.program, self.font, 16, self.font:getHeight() * 4 + 16, self.width - 32, 'left')
    love.graphics.printf(
        'buffer:\n' .. self.processor.buffer,
        self.font, 16, self.height * 0.5, math.min(self.font:getWidth('A') * 40, self.width - 32)
    )

    if self.debugMode then
        self:debugDraw()
    end
end

-- プログラム実行
function Game:runProgram()
    self.interpreter:resetProcessor()
    self.interpreter:resetCounter()
    self.interpreter:run()
end

-- プログラムステップ実行
function Game:stepProgram()
    self.interpreter:step()
end

-- 環境のリセット
function Game:resetEnvironment()
    self.interpreter:resetProcessor()
    self.interpreter:resetCounter()
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
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
    self.width, self.height = love.graphics.getDimensions()
end
