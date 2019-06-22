
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

    self.filename = ''

    self.visible = {
        'Editor',
        Editor = true,
    }
end

-- デバッグ更新
function Game:debugUpdate(dt, ...)
    Slab.Update(dt)

    self:mainMenuBar()

    if self.visible.Editor then self:editorWindow() end
end

-- デバッグ描画
function Game:debugDraw(...)
    Slab.Draw()
end

-- メインメニューバー
function Game:mainMenuBar()
    if Slab.BeginMainMenuBar() then
        -- ファイルメニュー
        if Slab.BeginMenu("File") then
            -- 新規作成
            if Slab.MenuItem("New...") then
                Slab.OpenDialog('New')
            end

            -- 開く
            if Slab.MenuItem("Open...") then
                Slab.OpenDialog('Open')
            end

            -- 上書き保存
            if Slab.MenuItem("Save") then
                Slab.OpenDialog('Save')
            end

            -- 名前をつけて保存
            if Slab.MenuItem("Save As...") then
                Slab.OpenDialog('Save')
            end

            Slab.Separator()

            -- セーブフォルダを開く
            if Slab.MenuItem("Open save directory") then
                love.system.openURL('file://' .. love.filesystem.getSaveDirectory())
            end

            Slab.Separator()

            -- 終了
            if Slab.MenuItem("Quit") then
                love.event.quit()
            end

            Slab.EndMenu()
        end

        -- 表示メニュー
        if Slab.BeginMenu("View") then
            for _, name in ipairs(self.visible) do
                if Slab.MenuItemChecked(name, self.visible[name]) then
                    self.visible[name] = not self.visible[name]
                end
            end
            Slab.EndMenu()
        end

        Slab.EndMainMenuBar()
    end
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
        if Slab.Button(self.interpreter.running and 'Stop' or 'Run', { AlignRight = true }) then
            if not self.interpreter.running and (Slab.IsKeyDown('rshift') or Slab.IsKeyDown('lshift')) then
                self:completeRunProgram()
            else
                self:toggleProgram()
            end
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
