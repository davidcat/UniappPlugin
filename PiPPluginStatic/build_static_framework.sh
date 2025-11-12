#!/bin/bash

# Build script for PiPPlugin Static Framework
# 基于 HBuilder-Hello 中的 PiPPlugin 源码构建静态 Framework

set -e  # 遇到错误立即退出

# ==================== 配置参数 ====================
FRAMEWORK_NAME="PiPPlugin"
FRAMEWORK_VERSION="1.0.0"
FRAMEWORK_DIR="build/${FRAMEWORK_NAME}.framework"
SOURCE_DIR="../HBuilder-Hello/HBuilder-Hello/PiPPlugin"
SDK_DIR="../SDK"

# 支持的架构（iOS 15.0+ 只支持 64位架构）
ARCHS=("arm64" "x86_64")  # arm64: 真机, x86_64: 模拟器
SDKS=("iphoneos" "iphonesimulator")  # 对应的 SDK

# 最低 iOS 版本（根据代码要求 iOS 15.0+）
MIN_VERSION="15.0"

# ==================== 检查依赖 ====================
echo "检查依赖..."

# 检查源文件目录
if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 源文件目录不存在: $SOURCE_DIR"
    exit 1
fi

# 检查 SDK 目录
if [ ! -d "$SDK_DIR" ]; then
    echo "错误: SDK 目录不存在: $SDK_DIR"
    exit 1
fi

# 检查必要的源文件
if [ ! -f "$SOURCE_DIR/PictureInPictureModule.m" ] || [ ! -f "$SOURCE_DIR/PictureInPictureModule.h" ]; then
    echo "错误: 找不到 PictureInPictureModule 源文件"
    exit 1
fi

if [ ! -f "$SOURCE_DIR/PiPPluginProxy.m" ] || [ ! -f "$SOURCE_DIR/PiPPluginProxy.h" ]; then
    echo "错误: 找不到 PiPPluginProxy 源文件"
    exit 1
fi

if [ ! -f "$SOURCE_DIR/PiPPlugin.h" ]; then
    echo "错误: 找不到 PiPPlugin.h 头文件"
    exit 1
fi

# 检查视频资源文件
if [ ! -f "$SOURCE_DIR/floating_video_9_16.mp4" ] || [ ! -f "$SOURCE_DIR/floating_video_16_9.mp4" ]; then
    echo "警告: 视频资源文件不存在，但继续构建..."
fi

# ==================== 清理之前的构建 ====================
echo "清理之前的构建..."
rm -rf build
mkdir -p "${FRAMEWORK_DIR}/Headers"
mkdir -p "${FRAMEWORK_DIR}/Modules"
mkdir -p "build/resources"  # 资源文件目录（与插件示例结构一致）

# ==================== 复制头文件 ====================
echo "复制头文件..."
cp "$SOURCE_DIR/PictureInPictureModule.h" "${FRAMEWORK_DIR}/Headers/"
cp "$SOURCE_DIR/PiPPlugin.h" "${FRAMEWORK_DIR}/Headers/"
cp "$SOURCE_DIR/PiPPluginProxy.h" "${FRAMEWORK_DIR}/Headers/"

# 检查是否所有头文件都已复制
if [ ! -f "${FRAMEWORK_DIR}/Headers/PictureInPictureModule.h" ] || \
   [ ! -f "${FRAMEWORK_DIR}/Headers/PiPPlugin.h" ] || \
   [ ! -f "${FRAMEWORK_DIR}/Headers/PiPPluginProxy.h" ]; then
    echo "错误: 头文件复制失败"
    exit 1
fi

# 更新 PiPPlugin.h (umbrella header) 以包含 PiPPluginProxy.h
if [ -f "${FRAMEWORK_DIR}/Headers/PiPPlugin.h" ]; then
    # 检查是否已经包含 PiPPluginProxy.h
    if ! grep -q "PiPPluginProxy.h" "${FRAMEWORK_DIR}/Headers/PiPPlugin.h"; then
        # 在 PictureInPictureModule.h 导入后添加 PiPPluginProxy.h
        sed -i '' '/#import <PiPPlugin\/PictureInPictureModule.h>/a\
#import <PiPPlugin/PiPPluginProxy.h>
' "${FRAMEWORK_DIR}/Headers/PiPPlugin.h"
    fi
fi

# ==================== 复制资源文件 ====================
echo "复制资源文件..."
if [ -f "$SOURCE_DIR/floating_video_9_16.mp4" ]; then
    cp "$SOURCE_DIR/floating_video_9_16.mp4" "build/resources/"
fi
if [ -f "$SOURCE_DIR/floating_video_16_9.mp4" ]; then
    cp "$SOURCE_DIR/floating_video_16_9.mp4" "build/resources/"
fi

# ==================== 创建 module.modulemap ====================
echo "创建 module.modulemap..."
cat > "${FRAMEWORK_DIR}/Modules/module.modulemap" << EOF
framework module ${FRAMEWORK_NAME} {
  umbrella header "${FRAMEWORK_NAME}.h"
  export *

  module * { export * }
}
EOF

# ==================== 编译各个架构 ====================
echo "开始编译各个架构..."

OBJECT_FILES=()

for i in "${!ARCHS[@]}"; do
    ARCH="${ARCHS[$i]}"
    SDK="${SDKS[$i]}"
    
    echo "编译架构: $ARCH (SDK: $SDK)"
    
    SDK_PATH=$(xcrun -sdk $SDK --show-sdk-path)
    if [ -z "$SDK_PATH" ]; then
        echo "警告: 无法获取 $SDK SDK 路径，跳过架构 $ARCH"
        continue
    fi
    
    # 编译 PictureInPictureModule.m
    echo "  编译 PictureInPictureModule.m..."
    clang -c \
        -arch $ARCH \
        -isysroot "$SDK_PATH" \
        -I"$SDK_DIR/inc" \
        -I"$SDK_DIR/inc/DCUni" \
        -I"$SDK_DIR/inc/weexHeader" \
        -fobjc-arc \
        -fmodules \
        -miphoneos-version-min=$MIN_VERSION \
        -o "PictureInPictureModule_${ARCH}.o" \
        "$SOURCE_DIR/PictureInPictureModule.m" || {
        echo "错误: PictureInPictureModule.m 编译失败 (架构: $ARCH)"
        exit 1
    }
    
    # 编译 PiPPluginProxy.m
    echo "  编译 PiPPluginProxy.m..."
    clang -c \
        -arch $ARCH \
        -isysroot "$SDK_PATH" \
        -I"$SDK_DIR/inc" \
        -I"$SDK_DIR/inc/DCUni" \
        -I"$SDK_DIR/inc/weexHeader" \
        -fobjc-arc \
        -fmodules \
        -miphoneos-version-min=$MIN_VERSION \
        -o "PiPPluginProxy_${ARCH}.o" \
        "$SOURCE_DIR/PiPPluginProxy.m" || {
        echo "错误: PiPPluginProxy.m 编译失败 (架构: $ARCH)"
        exit 1
    }
    
    OBJECT_FILES+=("PictureInPictureModule_${ARCH}.o" "PiPPluginProxy_${ARCH}.o")
done

if [ ${#OBJECT_FILES[@]} -eq 0 ]; then
    echo "错误: 没有成功编译任何架构"
    exit 1
fi

# ==================== 创建静态库 ====================
echo "创建静态库..."
libtool -static -o "${FRAMEWORK_DIR}/${FRAMEWORK_NAME}" "${OBJECT_FILES[@]}" || {
    echo "错误: 静态库创建失败"
    exit 1
}

# ==================== 创建 Info.plist ====================
echo "创建 Info.plist..."
cat > "${FRAMEWORK_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${FRAMEWORK_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.dcloud.${FRAMEWORK_NAME}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${FRAMEWORK_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>${FRAMEWORK_VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${FRAMEWORK_VERSION}</string>
    <key>MinimumOSVersion</key>
    <string>${MIN_VERSION}</string>
    <key>NSPrincipalClass</key>
    <string></string>
</dict>
</plist>
EOF

# ==================== 清理临时文件 ====================
echo "清理临时文件..."
rm -f *.o

# ==================== 验证 Framework ====================
echo "验证 Framework 结构..."
if [ ! -f "${FRAMEWORK_DIR}/${FRAMEWORK_NAME}" ]; then
    echo "错误: Framework 二进制文件不存在"
    exit 1
fi

if [ ! -f "${FRAMEWORK_DIR}/Headers/PictureInPictureModule.h" ]; then
    echo "错误: 头文件缺失"
    exit 1
fi

if [ ! -f "${FRAMEWORK_DIR}/Modules/module.modulemap" ]; then
    echo "错误: module.modulemap 缺失"
    exit 1
fi

# 显示 Framework 信息
echo ""
echo "=========================================="
echo "Framework 构建成功！"
echo "=========================================="
echo "Framework 路径: ${FRAMEWORK_DIR}"
echo "Framework 版本: ${FRAMEWORK_VERSION}"
echo "最低 iOS 版本: ${MIN_VERSION}"
echo "支持的架构:"
lipo -info "${FRAMEWORK_DIR}/${FRAMEWORK_NAME}" 2>/dev/null || echo "  (使用 lipo 查看架构信息)"
echo ""
echo "Framework 结构:"
ls -la "${FRAMEWORK_DIR}/"
echo ""
echo "头文件:"
ls -la "${FRAMEWORK_DIR}/Headers/"
echo ""
if [ -d "build/resources" ] && [ "$(ls -A build/resources 2>/dev/null)" ]; then
    echo "资源文件:"
    ls -la "build/resources/"
fi
echo "=========================================="
