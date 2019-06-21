
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- ライブラリ
local Slab = require 'Slab'

-- デバッグ初期化
function Game:debugInitialize()
    love.keyboard.setKeyRepeat(true)
    Slab.Initialize()
    Slab.GetStyle().Font = self.font
end

-- デバッグ更新
function Game:debugUpdate(dt, ...)
    Slab.Update(dt)

    self:editorWindow()
end

-- デバッグ描画
function Game:debugDraw(...)
    Slab.Draw()
end

-- エディタウィンドウ
function Game:editorWindow()
    Slab.BeginWindow(
        'Editor',
        {
            Title = 'Editor',
            AutoSizeWindow = false,
            X = 50, Y = 50,
            W = self.width - 50 * 2,
            H = self.height - 50 * 2
        }
    )

    do
        local x, y = Slab.GetCursorPos()
        if Slab.Button('Reset', { AlignRight = true }) then
            self:resetEnvironment()
        end
        Slab.SameLine()
        if Slab.Button('Run', { AlignRight = true }) then
            self:runProgram()
        end
        Slab.SameLine()
        if Slab.Button('Step', { AlignRight = true }) then
            self:stepProgram()
        end
        Slab.SetCursorPos(x, y)
        Slab.Text('counter: ' .. self.interpreter.counter .. ' pointer: ' .. self.processor.pointer)
        Slab.SetCursorPos(x, y)
        Slab.NewLine()
    end

    local x, y = Slab.GetCursorPos()
	local ww, wh = Slab.GetWindowActiveSize()
    if Slab.Input('EditorInput', { MultiLine = true, Text = self.interpreter.program, W = ww, H = wh - y }) then
        self.interpreter.program = Slab.GetInputText()
    end

    Slab.EndWindow()
end
