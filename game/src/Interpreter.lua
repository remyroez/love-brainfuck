
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
    self:resetCounter()
    self:resetProcessor()
    self.running = false
    self.state = 'stop'
    self.mode = 'step'
end

-- プロセッサの設定
function Interpreter:resetProcessor(processor)
    self.processor = processor or self.processor
    if self.processor then
        self.processor:reset()
    end
end

-- 読み込み
function Interpreter:load(program)
    self:reset()
    self.program = program or ''
end

-- カウンターのリセット
function Interpreter:resetCounter(counter)
    self.counter = counter or 1
    if self.counter < 1 then
        self.counter = 1
    elseif self.counter > #self.program then
        self.counter = #self.program + 1
    end
end

-- プログラムカウンタを進める
function Interpreter:next(n)
    self:resetCounter(self.counter + (n or 1))
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
                --print(op, word)
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
function Interpreter:run(mode)
    self.mode = mode or 'start'
    self.running = true
    self.state = 'run'
end

-- 停止
function Interpreter:stop()
    self.running = false
    self.state = 'stop'
    self.mode = 'start'
end

-- トグル
function Interpreter:toggle()
    self.running = not self.running
end

-- バッファ更新
function Interpreter:flush()
    self.state = 'flush'
end

-- 更新
function Interpreter:update()
    if not self.running then
        -- 実行しない
    elseif self.mode == 'complete' then
        -- 最後まで実行
        while self.counter <= #self.program do
            self:step()
            if self.state == 'flush' then
                self.state = 'run'
                break
            end
        end
        if self.counter <= #self.program then
            -- 一時中止
        else
            self:stop()
        end
    else
        if self.counter <= #self.program then
            self:step()
        else
            self:stop()
        end
    end
end

return Interpreter
