
local class = require 'middleclass'

-- プロセッサ クラス
local Processor = class 'Processor'

-- 初期化
function Processor:initialize(fn)
    self:reset()

    self.valueMin = 0
    self.valueMax = 255

    self.functions = fn or {
        increment = function (interpreter, word)
            self:increment(1)
            interpreter:next(#word)
        end,
        decrement = function (interpreter, word)
            self:increment(-1)
            interpreter:next(#word)
        end,
        backward = function (interpreter, word)
            self:movePointer(-1)
            interpreter:next(#word)
        end,
        forward = function (interpreter, word)
            self:movePointer(1)
            interpreter:next(#word)
        end,
        output = function (interpreter, word)
            self:print(string.char(self:value()))
            interpreter:next(#word)
        end,
        input = function (interpreter, word)
            interpreter:next(#word)
        end,
        open = function (interpreter, word)
            interpreter:next(#word)
            if self:value() == 0 then
                local stack = 1
                while stack > 0 do
                    if interpreter.counter > #interpreter.program then
                        break
                    elseif interpreter:match(interpreter.operators.open) then
                        stack = stack + 1
                        interpreter:next(#interpreter.operators.open)
                    elseif interpreter:match(interpreter.operators.close) then
                        stack = stack - 1
                        interpreter:next(#interpreter.operators.close)
                    else
                        interpreter:next()
                    end
                end
            end
        end,
        close = function (interpreter, word)
            if self:value() ~= 0 then
                local count = #word
                local stack = 1
                while stack > 0 do
                    interpreter:next(-count)
                    if interpreter.counter < 1 then
                        break
                    elseif interpreter:match(interpreter.operators.open) then
                        stack = stack - 1
                        count = #interpreter.operators.open
                    elseif interpreter:match(interpreter.operators.close) then
                        stack = stack + 1
                        count = #interpreter.operators.close
                    else
                        count = 1
                    end
                end
            else
                interpreter:next(#word)
            end
        end,
    }
end

-- リセット
function Processor:reset()
    self.memory = { 0 }
    self.pointer = 1

    self.buffer = ''
end

-- ポインタの設定
function Processor:setPointer(pointer)
    self.pointer = pointer or 1
    if self.pointer < 1 then
        self.pointer = 1
    end
    self.memory[self.pointer] = self.memory[self.pointer] or self.valueMin
end

-- ポインタの移動
function Processor:movePointer(move)
    self:setPointer(self.pointer + (move or 1))
end

-- 現在のポインタが指すメモリをインクリメント
function Processor:increment(n)
    self.memory[self.pointer] = self.memory[self.pointer] + (n or 1)
    if self.memory[self.pointer] < self.valueMin then
        self.memory[self.pointer] = self.memory[self.pointer] + self.valueMax
    elseif self.memory[self.pointer] > self.valueMax then
        self.memory[self.pointer] = self.memory[self.pointer] - self.valueMax
    end
end

-- 現在のポインタが指すメモリの値
function Processor:value(v)
    if v ~= nil then self.memory[self.pointer] = v end
    return self.memory[self.pointer]
end

-- プリント
function Processor:print(str)
    self.buffer = self.buffer .. str
end

-- 実行
function Processor:execute(operator, ...)
    if self.functions[operator] then
        self.functions[operator](...)
    end
end

return Processor
