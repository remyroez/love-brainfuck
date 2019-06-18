
local class = require 'middleclass'

local Interpreter = class 'Interpreter'

-- 初期化
function Interpreter:initialize(op)
    self:reset()

    self.operators = op or {
        increment = '+',
        decrement = '-',
        backward = '<',
        forward = '>',
        output = '.',
        input = ',',
        open = '[',
        close = ']',
    }
    self.functions = {
        increment = function (word)
            self:increment(1)
            self:next(#word)
        end,
        decrement = function (word)
            self:increment(-1)
            self:next(#word)
        end,
        backward = function (word)
            self:movePointer(-1)
            self:next(#word)
        end,
        forward = function (word)
            self:movePointer(1)
            self:next(#word)
        end,
        output = function (word)
            self:print(string.char(self:value()))
            self:next(#word)
        end,
        input = function (word)
            self:next(#word)
        end,
        open = function (word)
            self:next(#word)
            if self:value() == 0 then
                local stack = 1
                while stack > 0 do
                    if self.counter > #self.program then
                        break
                    elseif self:match(self.operators.open) then
                        stack = stack + 1
                        self:next(#self.operators.open)
                    elseif self:match(self.operators.close) then
                        stack = stack - 1
                        self:next(#self.operators.close)
                    else
                        self:next()
                    end
                end
            end
        end,
        close = function (word)
            if self:value() ~= 0 then
                local count = #word
                local stack = 1
                while stack > 0 do
                    self:next(-count)
                    if self.counter < 1 then
                        break
                    elseif self:match(self.operators.open) then
                        stack = stack - 1
                        count = #self.operators.open
                    elseif self:match(self.operators.close) then
                        stack = stack + 1
                        count = #self.operators.close
                    else
                        count = 1
                    end
                end
            else
                self:next(#word)
            end
        end,
    }
end

-- リセット
function Interpreter:reset()
    self.program = ''
    self.counter = 1
    self.memory = { 0 }
    self.pointer = 1
    self.buffer = ''
end

-- 読み込み
function Interpreter:load(program)
    self:reset()
    self.program = program or ''
end

-- ポインタの設定
function Interpreter:setPointer(pointer)
    self.pointer = pointer or 1
    if self.pointer < 1 then
        self.pointer = 1
    end
    self.memory[self.pointer] = self.memory[self.pointer] or 0
end

-- ポインタの移動
function Interpreter:movePointer(move)
    self:setPointer(self.pointer + (move or 1))
end

-- 現在のポインタが指すメモリをインクリメント
function Interpreter:increment(n)
    self.memory[self.pointer] = self.memory[self.pointer] + (n or 1)
    if self.memory[self.pointer] < 0 then
        self.memory[self.pointer] = self.memory[self.pointer] + 255
    elseif self.memory[self.pointer] > 255 then
        self.memory[self.pointer] = self.memory[self.pointer] - 255
    end
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

-- 現在のポインタが指すメモリの値
function Interpreter:value(v)
    if v ~= nil then self.memory[self.pointer] = v end
    return self.memory[self.pointer]
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
    for op, word in pairs(self.operators) do
        if self:match(word) then
            print(word)
            if self.functions[op] then
                self.functions[op](word)
            end
            break
        end
    end
end

-- 実行
function Interpreter:run()
    while self.counter <= #self.program do
        self:step()
    end
end

-- プリント
function Interpreter:print(str)
    self.buffer = self.buffer .. str
end

return Interpreter
