#!/bin/bash

# Logan 日志解析工具 - macOS 分发包构建脚本
# 作者: Flutter Logan Parser Team
# 日期: $(date +%Y-%m-%d)

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 构建选项
SKIP_SIGNING=false

# 项目信息
PROJECT_NAME="flutter_logan_parser"
APP_NAME="日志解析器"
VERSION=$(grep "version:" pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
BUILD_NUMBER=$(grep "version:" pubspec.yaml | cut -d'+' -f2)

# 路径定义
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
MACOS_BUILD_DIR="$BUILD_DIR/macos/Build/Products/Release"
DIST_DIR="$PROJECT_ROOT/dist"
DMG_DIR="$DIST_DIR/dmg"
APP_PATH="$MACOS_BUILD_DIR/$APP_NAME.app"
DMG_NAME="${APP_NAME}_v${VERSION}_${BUILD_NUMBER}_macOS.dmg"

# 打印信息函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_info "检查构建依赖..."
    
    # 检查 Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter 未安装或不在 PATH 中"
        exit 1
    fi
    
    # 检查 Xcode
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode 未安装或不在 PATH 中"
        exit 1
    fi
    
    # 检查 create-dmg (可选)
    if ! command -v create-dmg &> /dev/null; then
        print_warning "create-dmg 未安装，将使用 hdiutil 创建 DMG"
        print_warning "推荐安装 create-dmg: brew install create-dmg"
    fi
    
    print_success "依赖检查完成"
}

# 清理构建目录
clean_build() {
    print_info "清理构建目录..."
    
    cd "$PROJECT_ROOT"
    
    # 清理 Flutter 构建缓存
    flutter clean
    
    # 删除旧的构建文件
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    
    # 删除旧的分发目录
    if [ -d "$DIST_DIR" ]; then
        rm -rf "$DIST_DIR"
    fi
    
    print_success "构建目录清理完成"
}

# 获取依赖
get_dependencies() {
    print_info "获取项目依赖..."
    
    cd "$PROJECT_ROOT"
    flutter pub get
    
    # 如果有代码生成，运行 build_runner
    if grep -q "build_runner" pubspec.yaml; then
        print_info "运行代码生成..."
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    print_success "依赖获取完成"
}

# 构建 macOS 应用
build_macos_app() {
    print_info "构建 macOS 应用..."
    
    cd "$PROJECT_ROOT"
    
    # 构建 Release 版本
    flutter build macos --release
    
    if [ ! -d "$APP_PATH" ]; then
        print_error "应用构建失败，未找到 $APP_PATH"
        exit 1
    fi
    
    print_success "macOS 应用构建完成"
}

# 代码签名 (可选)
sign_app() {
    if [ "$SKIP_SIGNING" = true ]; then
        print_info "跳过代码签名（使用 --no-sign 选项）"
        return 0
    fi
    
    print_info "检查代码签名..."
    
    # 检查是否有可用的开发者证书
    CERT_NAME=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | cut -d'"' -f2)
    
    if [ -z "$CERT_NAME" ]; then
        print_warning "未找到 Developer ID Application 证书，跳过代码签名"
        print_info "应用将作为未签名版本分发"
        return 0
    fi
    
    print_info "使用证书: $CERT_NAME"
    print_info "对应用进行代码签名..."
    
    # 签名应用
    codesign --force --verify --verbose --sign "$CERT_NAME" "$APP_PATH"
    
    # 验证签名
    if codesign --verify --verbose "$APP_PATH" > /dev/null 2>&1; then
        print_success "代码签名完成"
    else
        print_warning "代码签名验证失败，但构建将继续"
    fi
}

# 创建 DMG 分发包
create_dmg() {
    print_info "创建 DMG 分发包..."
    
    # 创建分发目录
    mkdir -p "$DMG_DIR"
    
    # 复制应用到临时目录
    cp -R "$APP_PATH" "$DMG_DIR/"
    
    # 创建 Applications 链接
    ln -sf /Applications "$DMG_DIR/Applications"
    
    # 如果有 create-dmg，使用它创建更美观的 DMG
    if command -v create-dmg &> /dev/null; then
        print_info "使用 create-dmg 创建 DMG..."
        
        # 检查是否存在应用图标
        ICON_PATH="$APP_PATH/Contents/Resources/AppIcon.icns"
        ICON_OPTION=""
        if [ -f "$ICON_PATH" ]; then
            ICON_OPTION="--volicon $ICON_PATH"
        fi
        
        create-dmg \
            --volname "$APP_NAME" \
            $ICON_OPTION \
            --window-pos 200 120 \
            --window-size 800 450 \
            --icon-size 100 \
            --icon "$APP_NAME.app" 200 190 \
            --hide-extension "$APP_NAME.app" \
            --app-drop-link 600 185 \
            --hdiutil-quiet \
            "$DIST_DIR/$DMG_NAME" \
            "$DMG_DIR"
    else
        print_info "使用 hdiutil 创建 DMG..."
        
        # 使用 hdiutil 创建 DMG
        hdiutil create -srcfolder "$DMG_DIR" -volname "$APP_NAME" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDBZ "$DIST_DIR/$DMG_NAME"
    fi
    
    if [ -f "$DIST_DIR/$DMG_NAME" ]; then
        print_success "DMG 创建完成: $DIST_DIR/$DMG_NAME"
    else
        print_error "DMG 创建失败"
        exit 1
    fi
}

# 生成构建信息
generate_build_info() {
    print_info "生成构建信息..."
    
    BUILD_INFO_FILE="$DIST_DIR/build_info.txt"
    
    # 检查是否已签名
    SIGNATURE_STATUS="未签名"
    if [ "$SKIP_SIGNING" = false ]; then
        if codesign --verify --verbose "$APP_PATH" > /dev/null 2>&1; then
            SIGNATURE_STATUS="已签名"
        fi
    fi
    
    cat > "$BUILD_INFO_FILE" << EOF
Logan 日志解析工具 - macOS 分发包构建信息
==========================================

应用名称: $APP_NAME
版本号: $VERSION
构建号: $BUILD_NUMBER
构建时间: $(date)
构建机器: $(hostname)
系统版本: $(sw_vers -productName) $(sw_vers -productVersion)
Flutter 版本: $(flutter --version | head -1)
Dart 版本: $(dart --version | head -1)
签名状态: $SIGNATURE_STATUS

分发包信息:
-----------
DMG 文件: $DMG_NAME
文件大小: $(du -h "$DIST_DIR/$DMG_NAME" | cut -f1)
SHA256: $(shasum -a 256 "$DIST_DIR/$DMG_NAME" | cut -d' ' -f1)

安装说明:
---------
1. 双击 DMG 文件打开
2. 将 $APP_NAME.app 拖拽到 Applications 文件夹
3. 在 Applications 文件夹中找到应用并运行

注意事项（未签名应用）:
---------------------
- 首次运行时，系统会显示安全提示，这是正常现象
- 解决方法：
  1. 双击应用时如果显示"无法打开"，点击"取消"
  2. 前往 系统偏好设置 > 安全性与隐私 > 通用
  3. 在底部会看到被阻止的应用信息，点击"仍要打开"
  4. 再次确认"打开"即可正常使用
- 或者使用命令行方式：
  sudo xattr -rd com.apple.quarantine /Applications/$APP_NAME.app
EOF
    
    print_success "构建信息已保存到: $BUILD_INFO_FILE"
}

# 主函数
main() {
    if [ "$SKIP_SIGNING" = true ]; then
        print_info "开始构建 Logan 日志解析工具 macOS 分发包（无签名版本）..."
    else
        print_info "开始构建 Logan 日志解析工具 macOS 分发包..."
    fi
    print_info "版本: $VERSION ($BUILD_NUMBER)"
    
    # 检查依赖
    check_dependencies
    
    # 清理构建目录
    clean_build
    
    # 获取依赖
    get_dependencies
    
    # 构建应用
    build_macos_app
    
    # 代码签名
    sign_app
    
    # 创建 DMG
    create_dmg
    
    # 生成构建信息
    generate_build_info
    
    # 清理临时文件
    rm -rf "$DMG_DIR"
    
    print_success "构建完成！"
    print_info "分发包位置: $DIST_DIR/$DMG_NAME"
    print_info "构建信息: $DIST_DIR/build_info.txt"
    
    if [ "$SKIP_SIGNING" = true ] || ! codesign --verify --verbose "$APP_PATH" > /dev/null 2>&1; then
        print_warning "注意：这是未签名的应用，用户首次运行时需要在系统设置中允许"
    fi
}

# 处理命令行参数
case "${1:-}" in
    --clean-only)
        clean_build
        exit 0
        ;;
    --no-sign)
        SKIP_SIGNING=true
        main
        ;;
    --help|-h)
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  --clean-only    仅清理构建目录"
        echo "  --no-sign       跳过代码签名，生成未签名的分发包"
        echo "  --help, -h      显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  $0              # 完整构建流程（如有证书会自动签名）"
        echo "  $0 --no-sign    # 构建无签名分发包"
        echo "  $0 --clean-only # 仅清理构建目录"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "未知参数: $1"
        print_info "使用 $0 --help 查看帮助信息"
        exit 1
        ;;
esac 