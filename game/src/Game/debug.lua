
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- ライブラリ
local Slab = require 'Slab'

-- スペーサー
local function spacer(w, h)
    local x, y = Slab.GetCursorPos()
    Slab.Button('', { Invisible = true, W = w, H = h })
    Slab.SetCursorPos(x, y)
end

-- ディレクトリの準備
local function requireDirectory(name)
    local dir = love.filesystem.getInfo(name, 'directory')
    if dir == nil then
        love.filesystem.createDirectory(name)
    end
end

-- デバッグ初期化
function Game:debugInitialize()
    love.keyboard.setKeyRepeat(true)
    Slab.Initialize()
    Slab.GetStyle().Font = self.font

    self.visible = {
        'Editor',
        Editor = true,
    }

    self.currentFilename = ''
    self.filename = ''
    self.fileList = nil

    requireDirectory('program')
end

-- ファイルリストの更新
function Game:refreshFileList()
    self.fileList = {}
    local items = love.filesystem.getDirectoryItems('program')
    for i, filename in ipairs(items) do
        if love.filesystem.getInfo('program/' .. filename, 'file') then
            table.insert(self.fileList, filename)
        end
    end
end

-- デバッグ更新
function Game:debugUpdate(dt, ...)
    Slab.Update(dt)

    -- メインメニューバー
    self:mainMenuBar()

    -- ダイアログ
    self:openDialog()
    self:saveDialog()

    -- ウィンドウ
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
            if Slab.MenuItem("New") then
                self.currentFilename = ''
                self:newEnvironment()
            end

            -- 開く
            if Slab.MenuItem("Open...") then
                Slab.OpenDialog('Open')
            end

            -- 上書き保存
            if Slab.MenuItem("Save") then
                self.filename = self.currentFilename
                Slab.OpenDialog('Save')
            end

            -- 名前をつけて保存
            if Slab.MenuItem("Save As...") then
                self.filename = ''
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

-- 開くダイアログ
function Game:openDialog()
    if Slab.BeginDialog('Open', { Title = 'Open' }) then
        spacer(300)

        -- ファイル一覧リストボックス
        Slab.BeginListBox('OpenList')
        do
            -- ファイル一覧の更新
            if self.fileList == nil then
                self:refreshFileList()
            end

            -- ファイル一覧リストボックスアイテム
            for i, file in ipairs(self.fileList) do
                Slab.BeginListBoxItem('OpenItem_' .. i, { Selected = self.filename == file })
                Slab.Text(file)
                if Slab.IsListBoxItemClicked() then
                    self.filename = file
                end
                Slab.EndListBoxItem()
            end
        end
        Slab.EndListBox()

        --Slab.Separator()

        -- 開くボタン
        if Slab.Button('Open', { AlignRight = true, Disabled = #self.filename == 0 }) then

            Slab.CloseDialog()
        end

        -- キャンセルボタン
        Slab.SameLine()
        if Slab.Button('Cancel', { AlignRight = true }) then
            self.filename = ''
            Slab.CloseDialog()
        end

        Slab.EndDialog()
    end
end

-- 保存ダイアログ
function Game:saveDialog()
    if Slab.BeginDialog('Save', { Title = 'Save' }) then
        spacer(300)

        -- ファイル一覧リストボックス
        Slab.BeginListBox('SaveList')
        do
            -- ファイル一覧の更新
            if self.fileList == nil then
                self:refreshFileList()
            end

            -- ファイル一覧リストボックスアイテム
            for i, file in ipairs(self.fileList) do
                Slab.BeginListBoxItem('SaveItem_' .. i, { Selected = self.filename == file })
                Slab.Text(file)
                if Slab.IsListBoxItemClicked() then
                    self.filename = file
                end
                Slab.EndListBoxItem()
            end
        end
        Slab.EndListBox()

        Slab.Separator()

        -- ファイル名
        Slab.Text('File name: ')
        Slab.SameLine()
        if Slab.Input('filename', { Text = self.filename, ReturnOnText = false }) then
            self.filename = Slab.GetInputText()
        end

        Slab.Separator()

        -- 保存ボタン
        if Slab.Button('Save', { AlignRight = true, Disabled = #self.filename == 0 }) then

            Slab.CloseDialog()
        end

        -- キャンセルボタン
        Slab.SameLine()
        if Slab.Button('Cancel', { AlignRight = true }) then
            self.filename = ''
            Slab.CloseDialog()
        end

        Slab.EndDialog()
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
