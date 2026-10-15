#!/bin/sh
# 为 Claude Code 安装 Android Use：准备与 Codex 版共用的 Android 依赖环境，再从本地 marketplace 安装插件。
# 不修改 Codex 的插件、MCP 注册与 dist/android-marketplace。
set -eu
task_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
task_android_home=${ANDROID_USE_HOME:-"$HOME/.local/share/android-use"}
task_plugin=android-use@iphone-use-local
mkdir -p "$task_android_home"
# 依赖安装与 scripts/install_android.sh 相同：MCP 启动脚本 scripts/android_mcp.sh 使用这个 venv。
if [ ! -x "$task_android_home/venv/bin/python" ]; then python3 -m venv "$task_android_home/venv"; fi
"$task_android_home/venv/bin/python" -m pip install -r "$task_root/android/requirements.txt"
if ! command -v adb >/dev/null 2>&1 && [ ! -x "$task_android_home/platform-tools/adb" ] && [ -z "${ANDROID_USE_ADB:-}" ]; then
  if [ "$(uname -s)" != Darwin ]; then printf '%s\n' 'Install official Android Platform Tools and set ANDROID_USE_ADB.' >&2; exit 1; fi
  curl -fL --connect-timeout 20 --max-time 180 https://dl.google.com/android/repository/platform-tools-latest-darwin.zip -o "$task_android_home/platform-tools.zip"
  unzip -q -o "$task_android_home/platform-tools.zip" -d "$task_android_home"
fi
task_stage=$(python3 "$task_root/scripts/package_claude.py")
# 与 iPhone Use 共用本地 marketplace iphone-use-local；重复添加返回成功，update 重新读取暂存目录。
claude plugin marketplace add "$task_stage" --scope user
claude plugin marketplace update iphone-use-local
# 插件按版本号缓存，同版本 update 不会刷新内容；已安装时先卸载再安装。
if claude plugin list --json | python3 -c 'import json,sys;sys.exit(0 if any(item.get("id")==sys.argv[1] and item.get("scope")=="user" for item in json.load(sys.stdin)) else 1)' "$task_plugin"; then
  claude plugin uninstall "$task_plugin" --scope user
fi
claude plugin install "$task_plugin" --scope user
cat <<'EOF'

Android Use is installed for Claude Code. Start a new Claude Code session, or run /reload-plugins in an open one.

Recommended permissions for ~/.claude/settings.json (not written by this script; see claude/README.md):
  "permissions": {
    "allow": ["mcp__plugin_android-use_android_use__*"],
    "deny": ["mcp__plugin_android-use_android_use__pua_screen_frame",
             "mcp__plugin_android-use_android_use__pua_screen_action"]
  }
EOF
