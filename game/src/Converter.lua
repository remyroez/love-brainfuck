
local class = require 'middleclass'

-- コンバータ クラス
local Processor = require 'Processor'
local Converter = class('Converter', Processor)

-- 初期化
function Converter:initialize(op)
    Processor.initialize(self)

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

    self.functions = fn or {
        increment = function (interpreter, word)
            self:print(op.increment)
            interpreter:next(#word)
        end,
        decrement = function (interpreter, word)
            self:print(op.decrement)
            interpreter:next(#word)
        end,
        backward = function (interpreter, word)
            self:print(op.backward)
            interpreter:next(#word)
        end,
        forward = function (interpreter, word)
            self:print(op.forward)
            interpreter:next(#word)
        end,
        output = function (interpreter, word)
            self:print(op.output)
            interpreter:next(#word)
        end,
        input = function (interpreter, word)
            self:print(op.input)
            interpreter:next(#word)
        end,
        open = function (interpreter, word)
            self:print(op.open)
            interpreter:next(#word)
        end,
        close = function (interpreter, word)
            self:print(op.close)
            interpreter:next(#word)
        end,
    }
end

return Converter
