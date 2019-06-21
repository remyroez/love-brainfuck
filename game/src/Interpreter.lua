
local class = require 'middleclass'

-- インタプリタ クラス
local Interpreter = class 'Interpreter'

-- デフォルト命令セット
Interpreter.static.defaultOperators = {
    increment = '+',
    decrement = '-',
    backward = '<',
    forward = '>',
    output = '.',
    input = ',',
    open = '[',
    close = ']',
}

-- 初期化
function Interpreter:initialize(op)
    self:reset()

    -- 命令セット
    self.operators = op or {}
    self.operators.increment = self.operators.increment or '+'
    self.operators.decrement = self.operators.decrement or '-'
    self.operators.backward  = self.operators.backward  or '<'
    self.operators.forward   = self.operators.forward   or '>'
    self.operators.output    = self.operators.output    or '.'
    self.operators.input     = self.operators.input     or ','
    self.operators.open      = self.operators.open      or '['
    self.operators.close     = self.operators.close     or ']'
end

-- リセット
function Interpreter:reset()
    self.program = ''
    self.counter = 1
    self:setProcessor(self.processor)
end

-- プロセッサの設定
function Interpreter:setProcessor(processor)
    self.processor = processor
    if self.processor then
        self.processor:reset()
    end
end

-- 読み込み
function Interpreter:load(program)
    self:reset()
    self.program = program or ''
end

-- プログラムカウンタを進める
function Interpreter:next(n)
    self.counter = self.counter + (n or 1)
    if self.counter < 1 then
        self.counter = 1
    elseif self.counter > #self.program then
        self.counter = #self.program + 1
    end
end

-- マッチ
local function match(str, i, word)
    return str:sub(i, i - 1 + #word) == word
end

-- 現在のプログラムの位置にワードがあるかマッチ
function Interpreter:match(word)
    return match(self.program, self.counter, word)
end

-- ステップ実行
function Interpreter:step()
    local processed = false
    while not processed and (self.counter <= #self.program) do
        -- 命令セットから一致するワードを探す
        for op, word in pairs(self.operators) do
            if self:match(word) then
                -- ワードが一致したら処理する
                print(op, word)
                self.processor:execute(op, self, word)
                processed = true
                break
            end
        end

        -- 処理できなかったら次へ
        if not processed then
            self:next()
        end
    end
end

-- 実行
function Interpreter:run()
    -- 最後まで処理する
    while self.counter <= #self.program do
        self:step()
    end
end

return Interpreter
