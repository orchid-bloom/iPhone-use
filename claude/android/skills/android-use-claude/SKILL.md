---
name: android-use-claude
description: 在 Claude Code 中使用 Android Use（pua_ 前缀工具）时与 android-use、android-use-setup 一起读取；说明 Claude Code 下的工具名、截图查看、认证接管提问与实时手机屏幕，覆盖原技能中针对 Codex 宿主的写法。
---

# Claude Code 宿主差异

`android-use` 与 `android-use-setup` 的流程、READY 规则和失败语义不变；只有下面涉及宿主的写法按本节替换。

## 工具名

插件提供的 MCP 工具在 Claude Code 中名为 `mcp__plugin_android-use_android_use__<工具>`，例如 `mcp__plugin_android-use_android_use__pua_ready`。同时安装了 iPhone Use 时，两组工具都以 `pua_` 结尾，按前缀区分：操作 Android 只用 `mcp__plugin_android-use_android_use__` 开头的工具。工具未出现在当前可用列表时，先用工具搜索查找 `android_use`。

## 截图

截图随工具结果以图片内容块直接到达模型。图片未显示时，用 Read 打开结果中的图片路径；不要把 base64 或图片元数据当作已查看截图。坐标按工具结果说明换算。

## 认证接管

App 要求密码、PIN、验证码或指纹 / 人脸认证，或手机需要解锁时，使用 AskUserQuestion 请用户在手机上完成：问题说明实际 App、认证方式和完成后继续的工作，第一个选项固定为「已完成继续」，第二个为「暂时无法完成」。作答前不要恢复手机调用，不索取凭据；暂停与恢复预览按原流程调用 `pua_screen(action="pause")` / `pua_screen(action="resume")`。

## 实时手机屏幕

Claude Code 不渲染 MCP Apps，READY 和 `pua_screen` 不会打开原技能所说的侧边栏，这不是故障。实时屏幕由本插件的查看服务托管：它在 127.0.0.1 上加载与 Codex 相同的屏幕 widget（Android 样式），在右侧内置浏览器面板中显示画面与刷新 / 主屏幕 / 截图按钮。

1. 本对话首次取得 `ready=true` 后，或用户要求查看手机画面时，运行一次 `python3 <PLUGIN_ROOT>/viewer/screen_viewer.py start`。返回 JSON 的 `url` 是预览地址；已有实例时返回同一地址（`reused=true`）。Android 依赖装在 `~/.local/share/android-use/venv` 时，后台服务自动用其中的 Python。
2. 有内置浏览器面板工具（`mcp__Claude_Browser__*`）时，先用 `tabs_context` 查看是否已有同一 `http://127.0.0.1:<端口>` 的标签页：已有则用 `tabs_select` 切到它；有本插件之前打开的其他 127.0.0.1 预览标签页时用 `navigate` 改到新地址；都没有才用 `preview_start` 传入该 `url`，不要重复调用 `preview_start`。面板处于隐藏状态时请用户展开。没有浏览器面板时把地址交给用户在本机浏览器打开。
3. 打开后由 widget 自行刷新画面：不要为刷新重复 start、截图、observe 或 `pua_screen()`，不要通过浏览器工具点击预览页面操作手机，也不要调用仅供 widget 使用的 `pua_screen_frame` 与 `pua_screen_action`。
4. 预览只供用户观看；判断页面、定位目标与最终验收仍以工具返回的截图或控件树为准。
5. 查看服务 10 分钟没有请求会自动退出；用户关闭面板后再次要求查看时重新执行第 1 步。start 失败时说明原因并继续手机任务。

## 脚本入口

本技能中的 `<PLUGIN_ROOT>` 是本技能目录向上两级的插件根目录（含 `server/`、`viewer/` 与 `scripts/android_mcp.sh`）。原技能提到的 `server/android_use.py --tool pua_* --arguments JSON` 入口同样位于该目录下，需用 Android 依赖环境中的 Python 运行。
