# TurnSignalMirrors — The Bus

打方向燈時才顯示該側的 HUD 後視鏡（Tab 編輯模式裡加的那幾個視窗）。
Shows each HUD mirror window (the ones added in Tab/HUD edit mode) only while the indicator on that side is active.

## 需求 / Requirements

- The Bus（測試版本 1.2.0.100996，UE 5.6）
- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest) experimental 版（正式版 v3.0.1 不支援 UE 5.6）

## 安裝 / Install

1. 把 UE4SS experimental zip 解壓到 `The Bus\TheBus\Binaries\Win64\`（會多出 `dwmapi.dll` 和 `ue4ss\`）。
2. 把本 repo 的 `TurnSignalMirrors` 資料夾放進 `Win64\ue4ss\Mods\`。
3. 在 `ue4ss\Mods\mods.txt` 的 `Keybinds : 1` 之前加一行：`TurnSignalMirrors : 1`
4. 進遊戲上車，按 Tab 把左/右 HUD 後視鏡加上去。

移除：刪掉 `ue4ss\Mods\TurnSignalMirrors`；不再用 UE4SS 的話再刪 `dwmapi.dll` 和 `ue4ss\`。

## 行為 / Behavior

| 狀態 | 左鏡 | 右鏡（含輪邊鏡） |
|---|---|---|
| 方向燈關 | 隱藏 | 隱藏 |
| 左燈 | 顯示 | 隱藏 |
| 右燈 | 隱藏 | 顯示 |
| Tab 編輯模式 | 顯示 | 顯示 |

方向燈關掉後會多留 `HoldSeconds` 秒才收起。

## 熱鍵 / Hotkeys

- `Ctrl+F11` — 開/關本 mod（關閉時鏡子恢復常駐）
- `Ctrl+F12` — 把目前狀態寫入 `ue4ss\UE4SS.log`

## 設定 / Config

`Scripts/main.lua` 最上方：

| 參數 | 預設 | 說明 |
|---|---|---|
| `HoldSeconds` | `1.5` | 方向燈關掉後延遲收起的秒數 |
| `ShowBothOnHazard` | `false` | 雙閃時兩邊都顯示 |
| `IncludeRightWheel` | `true` | 右側輪邊鏡跟著右燈 |
| `PollMs` | `100` | 輪詢間隔（毫秒） |

## 已知限制 / Notes

- 只在單機、Berlin、Scania Citywide 實測；其他車只要鏡子元件叫 `Mirror_Left_*` / `Mirror_Right_*` 應該都能用。
- 多人連線未測試。
- 鏡子只是設為透明，遊戲仍會渲染，不會提升 FPS。
- 依賴遊戲內部類別名稱（`UMG_MirrorHUD_C`、`BP_IndicatorModule_C`），遊戲更新後可能失效。
- Steam「驗證檔案完整性」會清掉 UE4SS，需重裝。
