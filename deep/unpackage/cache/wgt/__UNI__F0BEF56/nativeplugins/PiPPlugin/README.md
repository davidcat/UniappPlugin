# PiPPlugin 插件包

## 📁 目录结构

```
PiPPlugin/
├── ios/                          # iOS 平台文件
│   ├── PiPPlugin.framework/      # Framework 文件（静态库）
│   │   ├── PiPPlugin            # 二进制文件
│   │   ├── Headers/              # 头文件
│   │   │   ├── PictureInPictureModule.h
│   │   │   ├── PiPPluginProxy.h
│   │   │   └── PiPPlugin.h
│   │   ├── Modules/              # 模块映射文件
│   │   │   └── module.modulemap
│   │   └── Info.plist            # Framework 信息
│   └── resources/                # 资源文件（打包时复制到主应用）
│       ├── floating_video_9_16.mp4
│       └── floating_video_16_9.mp4
├── index.js                      # JavaScript 接口文件
├── package.json                   # 插件配置文件
├── 使用说明.md                   # 使用说明文档
└── README.md                     # 本文件
```

## 📦 安装到 UniApp 项目

1. 将整个 `PiPPlugin` 文件夹复制到 UniApp 项目的 `nativeplugins` 目录下：

```
YourUniAppProject/
└── nativeplugins/
    └── PiPPlugin/                # 复制整个文件夹
        ├── ios/
        ├── index.js
        └── package.json
```

2. 在 `manifest.json` 中配置插件（参考 `使用说明.md`）

3. 重新制作自定义运行基座或重新打包

## ✅ 文件说明

- **ios/PiPPlugin.framework/**: iOS Framework（静态库），包含所有原生代码
- **ios/resources/**: 资源文件目录，视频文件会在打包时复制到主应用 bundle
- **index.js**: JavaScript 接口文件，提供前端调用接口
- **package.json**: 插件配置文件，定义插件元数据和 iOS 集成方式
- **使用说明.md**: 详细的使用文档和 API 说明

## 🔍 版本信息

- **版本**: 1.0.0
- **Framework 编译时间**: 2025-11-12
- **Framework 大小**: ~412KB (arm64 + x86_64)
- **最低 iOS 版本**: 15.0
- **支持的架构**: arm64 (真机), x86_64 (模拟器)

## 🎯 功能特性

- ✅ **显示/隐藏画中画窗口**：控制 PiP 窗口的显示和隐藏
- ✅ **文本内容更新**：支持更新第一行、第二行和提示文本
- ✅ **状态显示**：支持显示录音状态、内容状态、加载状态
- ✅ **自动适配方向**：自动适配设备方向（竖屏/横屏）
- ✅ **自动启动**：应用进入后台时自动启动画中画
- ✅ **权限管理**：自动处理麦克风权限请求
- ✅ **文件上传**：支持后台上传功能（单文件上传，支持 multipart/form-data）

## 📝 注意事项

1. 本插件需要 iOS 15.0 及以上版本
2. 需要在 `manifest.json` 中配置 `UIBackgroundModes` 和 `NSMicrophoneUsageDescription`
3. 使用前需要制作自定义运行基座
4. 插件使用静态 Framework，无需额外依赖

