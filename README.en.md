# iPhone Use

[中文](README.md) · **English**

![iPhone Use controlling a real iPhone in Codex with a live screen preview](assets/iphone-use-demo.png)

Let Codex, Claude Code, WorkBuddy, or Doubao Work operate your real iPhone over USB. Describe a task in natural language: open apps, read screens, tap, scroll, enter text, collect lists, and watch the phone preview.

Android phones use the separate **Android Use** plugin for Codex and Claude Code. See [Android support](#android-support-experimental) below for installation and usage.

| Phone platform | Codex | Claude Code | WorkBuddy / Doubao Work |
| --- | --- | --- | --- |
| iPhone | Supported | Supported | Supported |
| Android (experimental) | Supported | Supported | No dedicated adapter |

The plugin connects to [WebDriverAgent](https://github.com/appium/WebDriverAgent) (WDA). It includes a local MCP server, setup and usage skills, and a live screen widget. It reuses healthy connections and existing builds; when element targeting fails, it guides the model to inspect a screenshot and try coordinates.

The iPhone plugin sends anonymous usage statistics to its own PostHog project and GA4 property by default: usage starts, tool calls, connection results, durations and error categories. It uses a random installation ID and never uploads phone images, input text or device identifiers. Set `IPHONE_USE_ANALYTICS=0` or `DO_NOT_TRACK=1` and restart the MCP server to disable it. Android Use does not send these usage statistics. See [analytics documentation](ANALYTICS.md).

**Before using the iPhone plugin, install, sign, and start WDA Runner on your own iPhone.** WDA is the on-device execution service. The prompts and setup workflow below can help your host assistant complete the initial installation; a healthy existing WDA can be reused. Android uses its own ADB + UI Automator setup.

## Recent updates

This branch adds Android Use for installation, phone control, and preview in Codex and Claude Code. See the Android section below.

The following iPhone updates cover October 9–13, 2026. See the [changelog](CHANGELOG.md) for details.

- **Direct preview control**: tap the image, drag with the mouse, or scroll with two fingers on a trackpad.
- **WeChat tap improvements**: use screenshots to tap known navigation targets, with lighter reads for contacts and conversation lists.
- **AirDrop file transfer**: new usage-skill guidance for sending phone photos, videos, and documents to your Mac.
- **Screen reading improvements**: leaner trees, a 200-node default output limit, and optional snapshot limits for large lists.
- **Connection recovery improvements**: clearer timeout and disconnect guidance, with automatic restoration of temporary snapshot settings.
- **Safer long-text continuation**: input stays bound to the original field and stops when the app or focus changes.

## Ask Codex to install the iPhone plugin

Paste this prompt into Codex running on your Mac:

```text
Install and configure iPhone Use for me:
https://github.com/zhongerxin/iPhone-use

Read the repository README and installation script first. Check Codex CLI,
Python, Node.js, npm, full Xcode, and the iPhone connected over USB.
Clone the project into a suitable local directory and run sh scripts/install.sh.

If this chat cannot load the new tools, tell me to reconnect or start a new chat
and continue there. Once tools are available, read the iphone-use-setup skill.
Inspect existing configuration and reuse healthy WDA. For initial setup,
discover my device, use my own Apple development team and signable bundle ID,
fetch the pinned WDA, configure signing, build and start it. Continue until
pua_ready returns ready=true, then show the phone screen. Do not reuse the
author's device identifiers or signing configuration.

Help resolve missing dependencies. If Apple account login, device trust,
Developer Mode, or unlocking needs my input, explain the exact steps and wait
for me to complete them before continuing.
```

A reconnect may be required to load newly installed tools. Apple account login, device trust, Developer Mode, and unlocking must be completed by the device owner in the system UI. You can also extract a source package and run the installer for your host from its root.

## Install in WorkBuddy or Doubao Work

Both hosts can control a real iPhone over USB and show its live screen in a sidebar. They share local device configuration, WDA builds, and the operation lock, so an existing setup is reused. The requirements are macOS, full Xcode, Python, Node.js / npm, and a USB-connected iPhone; these adapters do not require Codex CLI. Anonymous usage statistics are disabled by default in both adapters.

| Host | Run from the source directory | Connect after installation |
| --- | --- | --- |
| [WorkBuddy](https://github.com/zhongerxin/iPhone-use/blob/main/workbuddy/README.md) | `python3 workbuddy/install.py` | Trust `iphone_use` in Connector Management, then start a new chat |
| [Doubao Work](https://github.com/zhongerxin/iPhone-use/blob/main/doubao/README.md) | `python3 doubao/install.py` | Add a STDIO connector using the installer output, upload both skills, then start a Local Computer task |

Paste the matching prompt into the host running on your Mac. The assistant can perform the local installation and explain any host UI steps it cannot complete. First-time signing uses your own Apple account and development team.

### Prompt for WorkBuddy

```text
Install iPhone Use on this Mac so WorkBuddy can operate my real iPhone over USB:
https://github.com/zhongerxin/iPhone-use

Read README.en.md, workbuddy/README.md, and the installer first. Check Python,
Node.js, npm, full Xcode, and the USB iPhone. Clone or reuse a local checkout,
preserve existing changes, and run python3 workbuddy/install.py from its root.
Do not run the Codex installer. Trust and enable iphone_use in WorkBuddy's
Connector Management, then start a new chat to load the tools and skills.
If I need to complete a UI step, give its exact location and wait for me.

Once tools are available, read iphone-use-setup and check setup status first.
Reuse existing configuration, healthy WDA, or an active startup job. For initial
setup, use my own device and Apple development team to sign and start WDA.
After pua_ready returns ready=true, call pua_screen() once to show the live
phone sidebar, then verify 12×34=408 in the iPhone Calculator.
For Apple login, trust, Developer Mode, or unlocking, explain the steps and
wait for me. Do not copy the author's device identifiers or signing settings.
```

### Prompt for Doubao Work

```text
Install iPhone Use on this Mac so Doubao Work can operate my real iPhone over USB:
https://github.com/zhongerxin/iPhone-use

In a Local Computer task, read README.en.md, doubao/README.md, and the installer.
Check Python, Node.js, npm, full Xcode, and the USB iPhone. Clone or reuse a local
checkout, preserve existing changes, and run python3 doubao/install.py from
its root. Do not run the Codex installer. In Plugins · Skills · Partners, create
an iphone_use STDIO connector with the absolute command and argument paths
printed by the installer. Upload the iphone-use and iphone-use-setup skill
folders from the installation directory. Enable the connector and both skills,
then start a new Local Computer task. Toggle an existing connector off and on
after updating. Give exact UI locations and paths for steps I need to complete,
and wait for me before continuing.

Once tools are available, read iphone-use-setup and check setup status first.
Reuse existing configuration, healthy WDA, or an active startup job. For initial
setup, use my own device and Apple development team to sign and start WDA.
After pua_ready returns ready=true, call pua_screen() once to show the live
phone in the right MCP App panel, then verify 12×34=408 in the iPhone Calculator.
For Apple login, trust, Developer Mode, or unlocking, explain the steps and
wait for me. Do not copy the author's device identifiers or signing settings.
```

If tools are missing, confirm the connector is enabled and start a new chat / Local Computer task. When both hosts use the same phone, follow the shared lock's waiting guidance. See the linked host READMEs for installation, updates, and troubleshooting.

## Install in Claude Code

The Claude Code plugin shares the existing MCP server, skills, device configuration, WDA builds, and operation lock, so an existing phone setup is reused. Requirements are listed below, plus a signed-in Claude Code CLI with plugin support; Codex CLI is not required. In the desktop app, use a **Local session in the Code tab** to see the phone in the right browser pane. Terminal CLI sessions can use a local browser instead.

### Prompt for Claude Code

```text
Install iPhone Use on this Mac so Claude Code can operate my real iPhone over USB:
https://github.com/zhongerxin/iPhone-use

Read README.en.md, claude/README.md, and scripts/install_claude.sh first.
Check the signed-in Claude Code CLI, Python, Node.js, npm, full Xcode, and USB iPhone.
Clone or reuse a local checkout, preserve existing changes, and run
sh scripts/install_claude.sh from its root. Use claude plugin list --json
to confirm iphone-use@iphone-use-local is installed.
Start a new Claude Code session or run /reload-plugins. If this session cannot
load the new tools, explain what I need to do and wait for me before continuing.
In the desktop app, use a Local session in the Code tab.

Once tools are available, read iphone-use-claude and iphone-use-setup, then check
setup status first. Reuse existing configuration, healthy WDA, or an active
startup job. For initial setup, use my device, Apple development team, and
signable bundle ID to fetch the pinned WDA, build, and start it.
After pua_ready returns ready=true, show the phone screen and verify 12×34=408
in the iPhone Calculator. A desktop version with hooks opens or reuses the
preview automatically; if that confirmation is present, do not start it again.
Otherwise, follow iphone-use-claude to start the viewer and open the complete
returned url. If the browser pane is hidden, tell me to expand it. In terminal
CLI sessions, give me the preview URL to open in a local browser.

For Apple login, device trust, Developer Mode, passwords, or Face ID,
explain the steps and wait for me to finish. Do not copy the author's device
identifiers or signing settings.
```

### Manual installation

Run from the source root:

```sh
sh scripts/install_claude.sh
```

The script registers the local marketplace `iphone-use-local` at user scope and installs `iphone-use@iphone-use-local`. Start a new Claude Code session or run `/reload-plugins` afterward. Keep the staging directory `dist/claude/` and rerun the installer after updating the source. Codex and Claude share the same phone; avoid operating it from both at once.

For Android phones, run `sh scripts/install_claude_android.sh` to install the `android-use` plugin from the same marketplace.

For permissions, manual preview commands, authentication handoff, updates, and uninstalling, see [Using iPhone Use in Claude Code](claude/README.md) (Chinese).

## Android support (experimental)

**Android Use** is a separately installed plugin that controls real Android phones through ADB + UI Automator. The Codex plugin provides 17 model tools, 2 widget-only tools, setup and usage skills, and a native phone screen panel. Its tool namespace and device configuration are independent of the iPhone plugin, so both can be installed.

### Install in Codex

Requirements: macOS, Codex CLI with plugin support, Python 3.9+, and an Android phone connected over USB. Enable Developer options and USB debugging on the phone, then authorize this computer. Android does not require Xcode, an Apple account, Android Studio, or root.

Run from the source root:

```sh
sh scripts/install_android.sh
```

The installer creates an isolated environment at `~/.local/share/android-use/venv`, installs pinned Python dependencies, downloads Google Platform Tools if needed, and registers the local marketplace `android-use-local` and plugin `android-use@android-use-local`. Reconnect or start a new Codex chat to load the `android_use` tools and the `android-use` and `android-use-setup` skills. Rerun the same installer after updating the source.

### Prompt for Codex

```text
Install and configure Android Use on this Mac so Codex can operate my Android phone over USB.

Reuse a local source checkout that includes Android support. Read README.en.md,
android/README.md, and scripts/install_android.sh first. Check Codex CLI, Python,
ADB, and USB debugging. Preserve existing changes and run
sh scripts/install_android.sh from the source root.
If this chat cannot load the new tools, tell me to reconnect or start a new chat.

Once tools are available, read android-use-setup and android-use. Use tools from
the android_use namespace. Call pua_setup(action="status") first and reuse
existing configuration and healthy services. If multiple devices are connected,
ask me to select one before configuring it. Start only once when needed and poll
the same job_id. Wait for pua_ready to return ready=true, then show the phone screen.
For USB authorization, unlocking, or authentication, explain the steps and wait
for me to complete them. Do not use the iPhone tools or copy the author's serial.
```

After installation, you can ask in a new chat with the plugin loaded:

> Use android-use-setup to configure my Android phone, verify READY, and show the phone screen.

### Features and current limits

- **Phone control:** read native UI nodes or screenshots, tap elements or display coordinates, swipe, use Back or Home, and launch apps. Send complete Chinese or Unicode text in a single request, up to 10,000 characters; Android does not implement iPhone-style chunk continuation, and apps may impose their own limits. Submission requires exact text readback.
- **Selectors and coordinates:** use Android fields such as `text`, `resource_id`, and `content_desc`. Actions use display pixels. Convert scaled screenshot coordinates using the x and y ratios in `image.pixel_to_display`, and observe again after rotation.
- **Workflows:** batch actions and bounded list search / collection. Observe uncertain outcomes before continuing; clicks and input are not replayed automatically.
- **Phone preview:** view and operate the phone in Codex's native panel, with geometry based on the actual display. Pause preview for passwords or authentication and let the user take over.
- **Optional video capture:** install scrcpy and FFmpeg with `brew install scrcpy ffmpeg` on macOS. If unavailable, capture falls back to UI Automator JPEG or ADB PNG screenshots.
- **Validation scope:** real-device validation targets macOS, Samsung SM-G9500 / Android 9, and USB. Android 11+ wireless pairing endpoints are implemented but still need device validation. Windows, other manufacturers, and custom-rendered editors are not fully supported.

Configuration, runtime state, and screenshots stay outside the repository. See [Android documentation](android/README.md) for full behavior and CLI diagnostics. Claude Code uses `sh scripts/install_claude_android.sh`.

### Updates and connection troubleshooting

From a source checkout with Android support, update and reinstall the Codex plugin:

```sh
git pull --ff-only
sh scripts/install_android.sh
codex plugin list --json
```

Confirm `android-use@android-use-local` is installed and enabled, then reconnect or start a new chat. For Claude Code, rerun `sh scripts/install_claude_android.sh` and start a new session or run `/reload-plugins`. Read `android-use-claude` on first use and follow its instructions to open the local preview URL. Both hosts share the Android environment and device configuration; avoid operating the same phone concurrently.

Dependencies default to `~/.local/share/android-use/venv`. Device configuration, startup logs, and screenshots default to `~/.local/share/android-use/state/`. Override the environment root, state directory, or ADB path with `ANDROID_USE_HOME`, `ANDROID_USE_STATE_DIR`, or `ANDROID_USE_ADB`. Keep custom settings consistent during installation and when the host starts MCP.

| Symptom | Action |
| --- | --- |
| No `android_use` tools in this chat | Confirm the plugin is enabled, then reconnect or start a new chat |
| No device or `unauthorized` | Check the data cable and USB debugging; unlock the phone and authorize the computer |
| Multiple devices | Discover them and let the user choose before calling configure with the actual serial |
| ADB online but automation unavailable | Check setup status, start if needed, poll the same job_id, and check READY again |
| Stalled preview | Try Refresh; read-only channel failures can trigger bounded recovery. A closed host MCP connection requires host reconnection |
| Locked phone or authentication | Let the user unlock or authenticate on the phone; resume authentication pauses only after user confirmation |

Before reconnecting, query status from the source root:

```sh
sh scripts/android_mcp.sh --tool pua_setup --arguments '{"action":"status"}'
```

ADB online does not prove readiness: phone tasks require `pua_ready` to return `ready=true`. Recovery never automatically replays uncertain clicks or input.

## iPhone requirements

| Requirement | Purpose |
| --- | --- |
| macOS and Codex, Claude Code, WorkBuddy, or Doubao Work | Local MCP and phone preview; Codex / Claude installation also requires the corresponding CLI |
| Full Xcode with first-launch setup completed | Build, sign, deploy, and run WDA; Command Line Tools alone are insufficient |
| An Apple account and development team available in Xcode | Sign the on-device WDA Runner |
| A real iPhone connected over USB | Trust the Mac, enable Developer Mode when required, and keep it unlocked during installation / startup |
| Python 3.9+ | Run the MCP server using Python's standard library |
| Node.js 20.19+, 22.12+, or 24+; npm 10+ | USB forwarding and screen streaming; see the project engines and doctor checks |

Xcode must support the phone's iOS version. No jailbreak or separate Appium Server is required. Setup uses a verified, pinned WDA 16.14.0 commit and manages downloads, dependencies, signing, and builds locally.

## Install and start WDA on your own iPhone

The phone-side service comes from [Appium's WebDriverAgent](https://github.com/appium/WebDriverAgent). First-time setup signs and installs `WebDriverAgentRunner` using your own Apple account and development team.

The installation prompt and `iphone-use-setup` workflow fetch the project's pinned WDA version, configure signing, build, deploy, and start it. Codex will explain any steps requiring your input.

For manual Xcode setup:

1. Connect your iPhone over USB, trust the Mac, enable Developer Mode when required, and configure your Apple account in Xcode.
2. Open `WebDriverAgent.xcodeproj`, select the `WebDriverAgentRunner` scheme and your iPhone, and configure your Team and a signable Bundle Identifier in the Runner target's **Signing & Capabilities**.
3. Use **Product → Test** to build, install, and start the runner. Complete any trust prompts on the phone. The WDA service must remain running.

After installing the plugin and configuring USB connectivity, start phone tasks only when `pua_ready` returns `ready=true`. See [Appium's device preparation guide](https://appium.github.io/appium-xcuitest-driver/latest/getting-started/device-setup/) for device and signing requirements.

## Install and connect

```sh
git clone https://github.com/zhongerxin/iPhone-use.git
cd iPhone-use
sh scripts/install.sh
```

The installer validates and stages the source, registers a local Codex marketplace, installs the plugin and skills, and registers the installed server as standard MCP `iphone_use`. Plugin and standard configuration share the same namespace to avoid duplicate tools. An extracted source package uses the same installation command.

Reconnect or start a new chat, enable **iPhone Use**, and ask:

> Use iphone-use-setup to configure my USB-connected iPhone, install and start WDA, verify READY, and show the phone screen.

Setup covers diagnostics, device discovery, signing configuration, download, background build, and startup. Existing configurations and builds are reused. Phone tasks start only after `pua_ready` returns `ready=true`.

## Features

This section describes the iPhone plugin. See the Android section above for its input behavior, coordinates, preview appearance, and compatibility limits.

| Feature | Behavior |
| --- | --- |
| App navigation | Launch apps and navigate search, details, settings, or drafts |
| Screen reading | Compact accessibility trees, text, positions, and actual screenshots |
| Taps and gestures | Element or coordinate taps, swipes, drags, and bounded waits |
| Unicode and long text | Complete text input, chunked long-text entry, and continuation |
| Batch workflows | Combine known actions into one call to reduce model round trips |
| List search and collection | Bounded scrolling, overlap, deduplication, and explicit coverage |
| Visual recovery | Inspect a fresh screenshot when targets are occluded, unfocused, or missing from the tree |
| Live preview | An iPhone frame, status, edge effects, and visible tap / drag indicators |
| Connection recovery | Reuse startup jobs, recreate invalid sessions, and reconnect preview with Refresh |

Example prompts:

```text
Open Notes, create a draft with the following text, verify it, and leave it there.

Open the target app, search for this name, and summarize the first few results.

Read this list while scrolling with overlap. Deduplicate entries and state the
covered range and any remaining uncertainty.
```

Text input and submission are separate; text is not submitted by default. The model checks key screens, recipients, counts, and final results. Passwords, verification codes, and Face ID are handled by the user. While waiting for unlock or authentication, the widget retains the last preview beneath a translucent black overlay with a handoff gesture icon and the prompt “请在手机上接管操作” (take over on your phone). The overlay disappears when the preview resumes.

Repeated preview opens in the same chat reuse the existing widget. Its toolbar offers Refresh, Home, and Screenshot. The appearance follows the connected model: only supported models show a Dynamic Island; other known rounded-screen models keep the rounded corners and frame. Pre-iPhone X models, all iPhone SE models, and unrecognized devices use a plain rectangular screen with no chassis. Without an image, the screen shows a centered status icon; the top badge displays the connection or pause state. The preview is for the user; model decisions use actual tool observations.

## Technical details

This section describes the iPhone / WDA implementation. Android uses separate ADB and UI Automator channels and reuses parts of the protocol and screen widget.

- **Local USB transport:** Python accesses WDA through a loopback-only forwarder; runtime and signing data stay on the Mac.
- **Reuse:** persistent HTTP connections, WDA sessions, healthy services, and builds reduce repeated work.
- **Compact observations and compound actions:** omit duplicate tree fields, skip XML for screenshot-only reads, and reduce turns with batch / scroll-search / list collection.
- **Background setup:** downloads, builds, and startup return queryable job IDs; repeated setup reuses matching active jobs.
- **Screenshot fallback:** inspect the image and multiply pixels by `image.pixel_to_point` to obtain iPhone point coordinates for `pua_tap`.
- **Explicit failure semantics:** a shared operation lock guards concurrent processes; uncertain mutations require reading the actual state before retrying.
- **Preview lifecycle:** streamed frames are not saved to disk; lock-induced pauses and explicit pauses are distinguished, and Refresh can reconnect.

These changes reduce duplicate requests and model round trips. Overall task speed still depends on the app, USB / WDA state, and model response time. Engineering regressions and device acceptance checks are recorded separately in local development notes.

## Tools

iPhone provides 18 model tools and Android provides 17; each also has 2 widget-only tools, `pua_screen_frame` and `pua_screen_action`. iPhone uses the `iphone_use` namespace; Android uses `android_use`. Parameters, selectors, and coordinate units follow each platform's skills and tool schemas.

| Tools | Purpose |
| --- | --- |
| `pua_doctor`, `pua_setup`, `pua_ready` | Diagnostics, configuration, background installation / startup, readiness |
| `pua_observe`, `pua_find` | Trees, observation screenshots, and target queries |
| `pua_screenshot` | Take an iOS system screenshot into iPhone Photos for use or sharing on the phone |
| `pua_apps`, `pua_launch_app` | App identifiers, installation evidence, app launch |
| `pua_tap`, `pua_swipe`, `pua_press_button` | Taps, swipes, and device buttons |
| `pua_type_text`, `pua_wait` | Unicode input and bounded waits |
| `pua_batch`, `pua_scroll_find`, `pua_collect_list` | Compound actions, search, collection |
| `pua_screen`, `pua_metrics` | Preview controls and bounded timing statistics |

Abnormal UI states return a screenshot for the model to inspect before choosing another action. Scroll search performs at most one swipe per call and stops if the target remains unreachable; occlusion, unproven scroll progress, input mismatch, and failed page expectations use the same fallback. Existing screenshots are reused, without automatic extra gestures or action replay.

## iPhone runtime data and updates

For Android environments, state directories, updates, and troubleshooting, see the Android section above.

New installations use `~/.local/share/iphone-use/`. Set `IPHONE_USE_STATE_DIR` for another external directory; `WDA_STATE_DIR` remains supported. If the new default directory does not exist, an existing older configuration directory is reused so device configuration and builds are retained.

Runtime directories use mode 700 and private configuration / image files use 600. Explicit screenshots have retention limits; preview streams stay in memory. Signing material, device data, logs, and dependency directories are excluded from source packages. `WDA_URL` accepts a local address; the default forwarded port is 18100, and remote addresses are rejected.

```sh
git pull --ff-only
sh scripts/install.sh
```

Reconnect the chat after updating. For connection failures, check USB, unlocking, Developer Mode, signing, and the specific setup error. Query an existing startup job before restarting again.

## Development and documentation

```sh
npm ci --prefix ui --no-audit --no-fund
npm run build --prefix ui
# Use a Python environment with Android dependencies for the full checks.
# Default installation location:
. ~/.local/share/android-use/venv/bin/activate
sh scripts/check.sh
python3 scripts/package.py
python3 scripts/package_android.py
```

The UI builds into self-contained HTML. Source packages at `dist/iphone-use-<version>-source.zip` include both platforms. `scripts/package_android.py` stages the Android Codex plugin at `dist/android-marketplace/android-use/` and writes `dist/android-use-<version>.zip`. `scripts/package_claude.py` stages both Claude Code plugins at `dist/claude/`.

Normal installation and use do not require rebuilding the UI. The iPhone installation retains the complete widget source, styles, build scripts, configuration, dependency lockfile, and tests. Android packages use an explicit runtime allowlist and include the built widget, without the complete UI build inputs. Use a source archive or repository checkout to maintain the Android UI. With a custom `ANDROID_USE_HOME`, run checks in that directory's virtual environment.

See [screen preview and recovery](skills/iphone-use/references/screen.md), [app identifiers](skills/iphone-use/references/apps.md), [troubleshooting](skills/iphone-use-setup/references/troubleshooting.md), and [changelog](CHANGELOG.md).

See also [Android installation, features, and recovery](android/README.md).

## Dependencies and acknowledgements

This project relies on the [Appium](https://github.com/appium/appium) ecosystem and [WebDriverAgent](https://github.com/appium/WebDriverAgent). WDA provides the on-device automation service; [appium-ios-device](https://github.com/appium/appium-ios-device) provides USB device communication, port forwarding, and screen-stream connectivity. iPhone Use adds the Codex plugin, MCP tools, setup guidance, and screen widget. A separate Appium Server is not required.

Thanks to the maintainers and contributors of Appium, WebDriverAgent, and related projects for making real iPhone automation possible.

Android uses Google Platform Tools, openatx/uiautomator2, adbutils, and Pillow. Optional video capture uses locally installed scrcpy and FFmpeg. See [Android documentation](android/README.md) for installation requirements; Android plugin packages also include their third-party dependency notices.

MIT License. See [third-party notices](THIRD_PARTY_NOTICES.md).

### Direct preview interaction

Click the live phone image to tap, or drag and release to swipe. Coordinates follow the displayed image as the panel resizes. Two-finger trackpad scrolling and mouse wheels scroll or page the phone, following the system scroll direction. Each wheel burst sends one swipe; momentum and input received during an operation are not queued. Long presses, phone multi-touch, pinch zoom, and keyboard input are not supported. Input is disabled while the preview is paused, offline, stale, or busy. Cancelled gestures and releases outside the image do nothing. Timed-out gestures are never replayed automatically; inspect the phone before trying again.
