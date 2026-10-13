# Screen Awake · 熄屏保活

A tiny native macOS menu bar app that prevents idle system sleep while allowing the display to turn off.

让 Mac 在电池供电、屏幕熄灭后继续运行，无需持续播放音乐。
适合需要电脑保持运行的下载、远程连接和后台任务。

## 下载与使用

1. 从 [Releases](https://github.com/wdz-info/screen-awake/releases/latest) 下载 `ScreenAwake-v1.0.0-universal.zip`。
2. 解压，将 **熄屏保活.app** 拖到“应用程序”文件夹，双击打开。
3. 点击顶部菜单栏 **保活 ○**，选择保活时长；显示 **保活 ●** 表示已开启。
4. 到期自动关闭，也可选择“关闭保活，恢复自动睡眠”或“退出”。

支持 **30 分钟、1 小时、2 小时、4 小时**，以及持续开启到手动关闭。
每次启动默认关闭，无开机启动项。应用没有 Dock 图标，通过顶部菜单栏操作。
需要 **macOS 12 或更高版本**；发布包同时包含 Apple 芯片和 Intel 架构。

发布包使用本地 ad hoc 签名，尚未经过 Apple Developer ID 签名和公证。
如果 macOS 阻止打开，请先确认下载来自本项目，再按照
[Apple 的说明](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unknown-developer-mh40616/mac)
在“系统设置 → 隐私与安全性”中处理；也可以自行编译源码。

## 功能与边界

- 电池供电和接电时均可使用，屏幕仍能正常熄灭和锁定。
- 无需管理员权限，不修改系统电源设置，不播放音频，不发送网络请求。
- 使用 IOKit 的 `PreventUserIdleSystemSleep` 断言；定时释放由 macOS 执行。
- 关闭、退出或进程结束后，保活断言释放，系统恢复原有睡眠行为。

这是防止**因闲置睡眠造成的中断**，不能保证 Wi-Fi、VPN 或远端会话自身永不掉线。
合盖、手动睡眠和低电量仍可能让电脑睡眠。保活会增加耗电，建议按需要定时开启。

## 从源码构建

需要 macOS 和 Xcode Command Line Tools，无第三方依赖。

```bash
git clone https://github.com/wdz-info/screen-awake.git
cd screen-awake
bash build.sh
open 'build/熄屏保活.app'
```

构建产物在 `build/熄屏保活.app`，构建脚本会生成 Universal Binary 并做 ad hoc 签名。
安装到本机时可将应用拖到“应用程序”文件夹。

```bash
bash test.sh       # 验证真实的电源断言创建、切换、关闭、到期和销毁释放
bash package.sh    # 生成 dist/ 下的 ZIP 和 SHA-256 校验文件
```

测试直接查询当前测试进程的 IOKit 电源断言，不启动应用界面、不依赖外部网络。
断言验证不能替代实际熄屏后的 Wi-Fi/VPN 连续性验证。

## 实现

| 文件 | 职责 |
| --- | --- |
| `src/main.m` | 原生 AppKit 菜单栏界面、时长选择、状态显示 |
| `src/SleepHold.m` | IOKit 电源断言管理、系统超时释放 |
| `resources/Info.plist` | 应用元数据 |
| `tests/SleepHoldTests.m` | 保活行为验证 |

## 卸载

从菜单退出应用后删除 `.app` 即可，无后台服务或系统设置要恢复。

## 临时命令行替代

无需安装应用，也可在终端运行以下命令保活两小时；提前结束按 Control+C。

```bash
caffeinate -i -t 7200
```

## 参考

- [IOPMAssertionCreateWithDescription](https://developer.apple.com/documentation/iokit/1557078-iopmassertioncreatewithdescripti)
- [Apple IOPMLib.h 源码及睡眠断言说明](https://github.com/opensource-apple/IOKitUser/blob/master/pwr_mgt.subproj/IOPMLib.h)
