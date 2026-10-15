# 在 Claude Code 中使用 iPhone Use

**中文** · 本页只说明 Claude Code 的安装与差异；功能、依赖与 WDA 配置见 [README](../README.md)。

Claude Code 版本与 Codex 版本共用同一个 MCP 服务、技能与本机运行数据（`~/.local/share/iphone-use/`）。已在 Codex 中配置好的设备、签名与 WDA 构建可以直接复用，无需重装。

## 安装

依赖与 Codex 版本相同（macOS、完整 Xcode、Python 3.9+、Node.js、USB 连接的 iPhone），另需已登录的 Claude Code CLI。

```sh
git clone https://github.com/zhongerxin/iPhone-use.git
cd iPhone-use
sh scripts/install_claude.sh
```

脚本把插件暂存到 `dist/claude/`，在用户范围注册本地 marketplace `iphone-use-local` 并安装 `iphone-use@iphone-use-local`。本地 marketplace 原地加载插件，请保留 `dist/claude/`；更新仓库后重新运行脚本即可。安装或更新后新开 Claude Code 会话，或在已有会话中执行 `/reload-plugins`。

脚本不会修改 Codex 的插件、MCP 注册或 `dist/iphone-use/`，两个宿主的安装互不影响。

## 建议的权限设置

Claude Code 默认对每次 MCP 工具调用请求确认。手机任务通常包含大量点击与滑动，建议在 `~/.claude/settings.json` 的 `permissions` 中加入：

```json
{
  "permissions": {
    "allow": ["mcp__plugin_iphone-use_iphone_use__*"],
    "deny": [
      "mcp__plugin_iphone-use_iphone_use__pua_screen_frame",
      "mcp__plugin_iphone-use_iphone_use__pua_screen_action"
    ]
  }
}
```

- `allow` 放行本插件全部工具。若希望发送、提交等操作前仍由自己确认，可只放行读取类工具，或不添加 `allow`。
- `deny` 屏蔽两个仅供屏幕 widget 使用的工具。Claude Code 不渲染 widget，这两个工具对模型无用。

## 开始使用

在新会话中输入：

> 用 iphone-use-setup 帮我配置通过 USB 连接的 iPhone，安装并启动 WDA，验证 READY。

已配置过的设备会复用配置与构建，`pua_ready` 返回 `ready=true` 后即可开始手机任务。

## 与 Codex 版本的差异

| 项目 | Claude Code |
| --- | --- |
| 工具名 | `mcp__plugin_iphone-use_iphone_use__pua_*` |
| 截图 | 随工具结果直接以图片返回给模型 |
| 实时手机屏幕 | 由本地查看服务托管 Codex 同款 widget，显示在 Claude 桌面端 Code 标签页右侧的浏览器面板中，见下节 |
| 认证接管 | 通过 AskUserQuestion 等待用户在手机上完成密码或 Face ID |

补充技能 `iphone-use-claude` 会向模型说明以上差异。

## 实时手机屏幕

Claude Code 不渲染 MCP Apps，插件改用一个只监听 127.0.0.1 的本地查看服务：它加载与 Codex 相同的屏幕 widget，画面、机型与 Live 状态、点击光效以及刷新 / 主屏幕 / 截图按钮与 Codex 侧边栏一致。**自动打开**：在桌面端 Code 标签页中，插件钩子（`hooks/register.ts`）会在 `pua_ready` 返回 `ready=true` 或 `pua_screen` 打开后，自动启动查看服务，并在右侧浏览器面板中打开画面。已有同一预览标签页时只切换过去，不重复打开；查看服务换了端口时，只复用本插件之前打开过的标签页，不改动你自己的本机页面。浏览器面板被收起时无法替你展开，模型会提示你手动展开。关掉画面后想再看，直接说「打开手机屏幕」。

钩子模块需要较新的 Claude Code（桌面端内置版本已支持）。旧版 CLI 会忽略钩子，插件其他功能不受影响，这时由模型按补充技能手动启动查看服务，或者用下面的命令自己打开。

手动启动或停止：

```sh
python3 dist/claude/iphone-use/viewer/screen_viewer.py start
python3 dist/claude/iphone-use/viewer/screen_viewer.py stop
```

`start` 输出的 `url` 可在任意本机浏览器中打开，终端中的 Claude Code 也可以这样查看。服务与 MCP 服务共用运行数据和操作锁：认证暂停、锁屏提示会同步显示，按钮不会与正在执行的手机操作冲突。每个实例使用随机令牌，只接受本机页面发起的请求，10 分钟无请求后自动退出。

修改 `claude/viewer/host.ts` 或 `host.html` 后，在该目录运行 `npm install` 与 `npm run build` 重新生成 `viewer.html`，再运行安装脚本。钩子的测试（`claude/hooks/register.test.ts`）需要支持 `claude plugin test` 的 Claude Code；终端里的 `claude` 版本较旧时，用 `CLAUDE_CODE_BIN` 指向新版可执行文件后运行 `sh scripts/check.sh`，否则这项测试会自动跳过。

## 注意事项

- **不要同时在 Codex 与 Claude Code 中操作手机。** 两边共用同一台设备与同一个 WDA 服务，操作锁会让动作排队，一方重建会话也可能打断另一方正在进行的任务。两边同时打开实时屏幕时，各自建立一路画面连接。
- **在本仓库目录内打开 Claude Code 时**，根目录的 `.mcp.json` 是 Codex 格式（使用 `${PLUGIN_ROOT}`），仓库中的 `.claude/settings.json` 已将其中的 `iphone_use` 停用，手机工具由插件提供。`claude mcp list` 仍会对该文件显示一条缺少 `PLUGIN_ROOT` 的诊断警告，可以忽略。
- 匿名使用统计与 Codex 版本相同，事件的 `source` 记为 `claude_plugin_mcp`（Codex 为 `codex_plugin_mcp`），关闭方式见 [埋点与分析说明](../ANALYTICS.md)。

## Android Use

同一个本地 marketplace 还提供 `android-use` 插件，通过 USB（或已配对的无线）ADB 操作 Android 手机，与 Codex 版 Android Use 共用服务端、技能和依赖环境。需要已开启 USB 调试的 Android 手机。

```sh
sh scripts/install_claude_android.sh
```

脚本把依赖装进 `~/.local/share/android-use/venv`（与 Codex 版 `scripts/install_android.sh` 相同；本机没有 adb 时在 macOS 上自动下载官方 Platform Tools），再安装 `android-use@iphone-use-local`。安装后新开会话或执行 `/reload-plugins`，输入「配置我的 Android 手机并验证连接。」即可开始。

- **工具名**：`mcp__plugin_android-use_android_use__pua_*`。与 iPhone Use 同时安装时，两组工具按前缀区分。建议的权限规则见安装脚本最后的输出（把上文规则里的 `iphone-use_iphone_use` 换成 `android-use_android_use`）。
- **实时手机屏幕**：同一个查看服务的 Android 模式，画面使用 Android 样式，在右侧浏览器面板中打开；也可以手动运行 `python3 dist/claude/android-use/viewer/screen_viewer.py start`。运行数据在 `~/.local/share/android-use/state`，与 iPhone 互不影响。READY 后由补充技能 `android-use-claude` 提示模型打开画面，没有自动打开钩子。
- Android 服务端不发送匿名使用统计。

## 卸载

```sh
claude plugin uninstall iphone-use@iphone-use-local
claude plugin uninstall android-use@iphone-use-local
claude plugin marketplace remove iphone-use-local
```

卸载不会删除 `~/.local/share/iphone-use/` 与 `~/.local/share/android-use/` 中的设备配置、构建和依赖环境，Codex 版本仍可继续使用。
