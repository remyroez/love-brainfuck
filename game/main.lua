
-- デバッグモード
local debugMode = true

-- フォーカス
local pauseOnUnfocus = true
local focused = true
local screenshot

-- アプリケーション
local application = (require 'Game')()
application:setDebugMode(debugMode)

-- 読み込み
function love.load()
    love.math.setRandomSeed(love.timer.getTime())
end

-- 更新
function love.update(dt)
    if focused then
        application:update(dt)
    end
end

-- 描画
function love.draw()
    if focused or screenshot == nil then
        -- 画面のリセット
        love.graphics.reset()

        -- ゲーム描画
        application:draw()

    elseif screenshot then
        -- スクリーンショットを描画
        love.graphics.draw(screenshot)
    end
end

-- キー入力
function love.keypressed(key, scancode, isrepeat)
    if key == 'escape' then
        -- 終了
        love.event.quit()
    elseif key == 'printscreen' then
        -- スクリーンショット
        love.graphics.captureScreenshot('' .. os.time() .. '.png')
    elseif key == 'f5' then
        -- リスタート
        love.event.quit('restart')
    elseif key == 'f12' then
        -- デバッグモード切り替え
        debugMode = not debugMode

        -- アプリケーションのデバッグモード切り替え
        application:setDebugMode(debugMode)
    else
        -- アプリケーションへ渡す
        application:keypressed(key, scancode, isrepeat)
    end
end

-- キー離した
function love.keyreleased(...)
    application:keyreleased(...)
end

-- マウス入力
function love.mousepressed(...)
    application:mousepressed(...)
end

-- マウス離した
function love.mousereleased(...)
    application:mousereleased(...)
end

-- マウス移動
function love.mousemoved(...)
    application:mousemoved(...)
end

-- マウスホイール
function love.wheelmoved(...)
    application:wheelmoved(...)
end

-- テキスト入力
function love.textinput(...)
    application:textinput(...)
end

-- フォーカス
function love.focus(f)
    focused = f

    if not pauseOnUnfocus then
        -- フォーカスがない時にポーズしない
    elseif not f then
        -- フォーカスを失ったので、スクリーンショット撮影
        love.graphics.captureScreenshot(
            function (imageData)
                screenshot = love.graphics.newImage(imageData)
            end
        )
    elseif screenshot then
        -- フォーカスが戻ったので、スクリーンショット開放
        screenshot:release()
        screenshot = nil
    end
end

-- リサイズ
function love.resize(...)
    application:resize(...)
end
