
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- ライブラリ
local Slab = require 'Slab'
local Interpreter = require 'Interpreter'

-- ディープコピー
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        -- tableなら再帰でコピー
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        -- number, string, booleanなどはそのままコピー
        copy = orig
    end
    return copy
end

-- スペーサー
local function spacer(w, h)
    local x, y = Slab.GetCursorPos()
    Slab.Button('', { Invisible = true, W = w, H = h })
    Slab.SetCursorPos(x, y)
end

-- 入力欄
local function input(t, name, label)
    local changed = false

    Slab.BeginColumn(1)
    Slab.Text(label or name or '')
    Slab.EndColumn()

    Slab.BeginColumn(2)
	local ww, wh = Slab.GetWindowActiveSize()
    local h = Slab.GetStyle().Font:getHeight()
    if Slab.Input(name, { Text = tostring(t[name]), ReturnOnText = false, W = ww, H = h }) then
        t[name] = Slab.GetInputText()
        changed = true
    end
    Slab.EndColumn()

    return changed
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
        'Memory',
        'Statements',
        Editor = true,
        Memory = true,
        Statements = false,
    }

    self.currentFilename = ''
    self.filename = ''
    self.fileList = nil
    self.errorMessage = nil

    self.statements = {
        {
            name = 'Brainfuck',
            operators = Interpreter.defaultOperators,
        },
        {
            name = 'Ook!',
            operators = {
                increment = 'Ook. Ook.',
                decrement = 'Ook! Ook!',
                backward = 'Ook? Ook.',
                forward = 'Ook. Ook?',
                output = 'Ook! Ook.',
                input = 'Ook. Ook!',
                open = 'Ook! Ook?',
                close = 'Ook? Ook!',
            }
        },
        {
            name = 'けもフレ言語',
            operators = {
                increment = 'たーのしー',
                decrement = 'すっごーい！',
                backward = 'すごーい！',
                forward = 'たのしー！',
                output = 'なにこれなにこれ！',
                input = 'おもしろーい！',
                open = 'うわー！',
                close = 'わーい！',
            }
        },
        {
            name = 'ライドヘイセイバー',
            operators = {
                increment = 'ヘイ！',
                decrement = 'ディディディディケイド！',
                backward = '平成ライダーズ！',
                forward = '仮面ライダーズ！',
                output = 'セイ！',
                input = 'ヘヘヘイ！',
                open = 'フィニッシュタイム！',
                close = 'アルティメットタイムブレイク！',
            }
        },
    }
    self.selectedStatements = 'Brainfuck'

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
    if self.visible.Statements then self:statementsWindow() end
    if self.visible.Memory then self:memoryWindow() end

    -- エラーメッセージボックス
    if self.errorMessage then
        if Slab.MessageBox('Error', self.errorMessage) ~= '' then
            self.errorMessage = nil
        end
    end
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
                if #self.currentFilename > 0 then
                    -- 既にファイル名が指定されている
                    local success, message = self:saveFile(self.currentFilename, self.interpreter.program)
                    if success then
                    else
                        self.errorMessage = message
                    end
                else
                    -- まだ保存されていない
                    self.filename = self.currentFilename
                    Slab.OpenDialog('Save')
                end
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

        Slab.Separator()

        -- 開くボタン
        if Slab.Button('Open', { AlignRight = true, Disabled = #self.filename == 0 }) then
            local data, message = self:openFile(self.filename)
            if message then
                self.errorMessage = message
            else
                self.interpreter.program = data
                self.filename = ''
                self.fileList = nil
                Slab.CloseDialog()
            end
        end

        -- キャンセルボタン
        Slab.SameLine()
        if Slab.Button('Cancel', { AlignRight = true }) then
            self.filename = ''
            self.fileList = nil
            Slab.CloseDialog()
        end

        Slab.EndDialog()
    end
end

-- ファイルを開く
function Game:openFile(name, data)
    local data, sizeOrMessage = love.filesystem.read('program/' .. name)
    if data and type(sizeOrMessage) == 'number' then
        self.currentFilename = name
    end
    return data, type(sizeOrMessage) == 'string' and sizeOrMessage or nil
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
            local success, message = self:saveFile(self.filename, self.interpreter.program)
            if success then
                self.currentFilename = self.filename
                self.filename = ''
                self.fileList = nil
                Slab.CloseDialog()
            else
                self.errorMessage = message
            end
        end

        -- キャンセルボタン
        Slab.SameLine()
        if Slab.Button('Cancel', { AlignRight = true }) then
            self.filename = ''
            self.fileList = nil
            Slab.CloseDialog()
        end

        Slab.EndDialog()
    end
end

-- ファイルを保存
function Game:saveFile(name, data)
    local success, message = love.filesystem.write('program/' .. name, data)
    if success then
        self.currentFilename = name
    end
    return success, message
end

-- エディタウィンドウ
function Game:editorWindow()
    Slab.BeginWindow(
        'Editor',
        {
            Title = 'Editor' .. ((#self.currentFilename > 0) and (' - ' .. self.currentFilename) or ''),
            AutoSizeWindow = false,
            X = 50, Y = 50,
            W = self.width - 50 * 2,
            H = self.height / 2 - 50 - 50 /2
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
    if Slab.Input(
        'EditorInput',
        {
            MultiLine = true,
            Text = self.interpreter.program,
            W = ww, H = wh - y,
            ReadOnly = self:isWaitForInput(),
         }
    ) then
        self.interpreter.program = Slab.GetInputText()
    end

    Slab.EndWindow()
end

-- メモリウィンドウ
function Game:memoryWindow()
    Slab.BeginWindow(
        'Memory',
        {
            Title = 'Memory',
            AutoSizeWindow = false,
            X = 50, Y = self.height / 2 + 25,
            W = self.width - 50 * 2,
            H = self.height / 2 - 50 - 50 / 2
        }
    )

    for i, value in ipairs(self.processor.memory) do
        Slab.Text(string.format('%02x', value), { Color = i == self.processor.pointer and { 1, 0, 0 } or nil })
        Slab.SameLine()
    end

    Slab.EndWindow()
end

-- 命令ウィンドウ
function Game:statementsWindow()
    Slab.BeginWindow(
        'Statements',
        {
            Title = 'Statements', Columns = 2
        }
    )
    spacer(300)

    -- プリセット
    local w, h = Slab.GetWindowActiveSize()
    if Slab.BeginComboBox(
        'StatementSet',
        { Selected = self.selectedStatements or 'Presets', W = w }) then
        for i, t in ipairs(self.statements) do
            if Slab.TextSelectable(t.name) then
                self.selectedStatements = t.name
                self.interpreter.operators = deepcopy(t.operators)
            end
        end
        Slab.EndComboBox()
    end

    -- 命令セット
    local changed = false
    changed = input(self.interpreter.operators, 'forward', 'Increment Pointer') or changed
    changed = input(self.interpreter.operators, 'backward', 'Decrement Pointer') or changed
    changed = input(self.interpreter.operators, 'increment', 'Increment Byte') or changed
    changed = input(self.interpreter.operators, 'decrement', 'Decrement Byte') or changed
    changed = input(self.interpreter.operators, 'output', 'Output Byte') or changed
    changed = input(self.interpreter.operators, 'input', 'Input Byte') or changed
    changed = input(self.interpreter.operators, 'open', 'Begin Loop') or changed
    changed = input(self.interpreter.operators, 'close', 'End Loop') or changed

    if changed then
        self.selectedStatements = nil
    end

    Slab.EndWindow()
end
