# Logan 日志解析工具 - Flutter 桌面端

基于 Flutter 开发的 Logan 日志解析工具，用于解析和查看美团 Logan 日志框架生成的加密日志文件。

## 项目背景

公司移动端日志采用的是美团技术团队开源的日志工具 Logan。移动端提供日志上传功能，日志上传上来的是加密后的文件，需要本地对日志进行解密，才能查看到具体日志记录的内容。

## 功能特性

- ✅ **日志文件解析**：支持 Logan 加密日志文件的解析和解密
- ✅ **智能搜索**：提供日志内容的快速搜索功能
- ✅ **类型筛选**：支持按日志类型（调试、提示、错误、警告）进行筛选
- ✅ **详情查看**：点击日志条目查看详细的线程信息和完整内容
- ✅ **JSON 导出**：自动生成 JSON 格式的解析结果文件，保存至用户文档目录
- ✅ **数据持久化**：自动保存解析结果，重启应用后恢复上次的工作状态
- ✅ **解析历史**：记录所有解析过的文件历史，便于快速重新打开和管理
- ✅ **文件管理**：在 macOS 上支持"在 Finder 中显示"功能，直接打开文件位置
- ✅ **美观界面**：现代化的桌面端 UI 设计，支持深色主题
- ✅ **跨平台**：支持 macOS、Windows、Linux 桌面平台
- ✅ **加载动画**：优雅的加载状态指示器，提升用户体验

## 技术架构

- **框架**：Flutter 3.x - 跨平台 UI 框架
- **状态管理**：flutter_riverpod - 响应式状态管理
- **数据序列化**：json_annotation + json_serializable + build_runner - 自动代码生成
- **加密解密**：pointycastle + crypto - 加密算法库
- **文件操作**：file_picker - 跨平台文件选择器
- **路径管理**：path + path_provider - 路径处理和目录获取
- **数据存储**：shared_preferences - 本地数据持久化
- **文件压缩**：archive - 压缩文件处理

## 项目结构

```
├── lib/
│   ├── main.dart                           # 应用入口
│   ├── models/                             # 数据模型
│   │   ├── logan_log_item.dart            # Logan 日志条目模型
│   │   └── app_state.dart                 # 应用状态定义
│   ├── services/                           # 业务服务层
│   │   ├── logan_parser_service.dart      # Logan 解析服务
│   │   ├── history_storage_service.dart   # 历史记录存储服务
│   │   └── logan_data_storage_service.dart # 日志数据持久化服务
│   ├── providers/                          # 状态管理
│   │   └── logan_provider.dart            # Logan 相关 Provider
│   ├── pages/                              # 页面组件
│   │   ├── home_page.dart                 # 主页面
│   │   ├── log_decode_page.dart           # 日志解析页面
│   │   └── parse_history_page.dart        # 解析历史页面
│   ├── widgets/                            # UI 组件
│   │   ├── common_widgets.dart            # 通用组件
│   │   ├── sidebar_menu.dart              # 侧边菜单
│   │   └── log_item_widget.dart           # 日志条目组件
│   └── theme/                              # 主题配置
│       └── app_theme.dart                 # 应用主题
├── pubspec.yaml                            # 项目配置文件
├── CHANGELOG.md                            # 更新日志
└── README.md                               # 项目说明文档
```

## 开始使用

### 环境要求

- Flutter SDK >= 3.7.2
- Dart SDK >= 3.7.2
- macOS 10.14+ / Windows 10+ / Linux

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd flutter_logan_parser
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成代码**
   ```bash
   dart run build_runner build
   ```

4. **运行应用**
   ```bash
   # macOS
   flutter run -d macos
   
   # Windows
   flutter run -d windows
   
   # Linux
   flutter run -d linux
   ```

### 使用说明

1. **选择日志文件**：点击右下角的"+"按钮，选择需要解析的 Logan 日志文件
2. **等待解析**：系统将自动解析和解密日志文件内容
3. **搜索日志**：在搜索框中输入关键词快速查找相关日志
4. **筛选日志**：使用下拉菜单按日志类型进行筛选
5. **查看详情**：点击日志条目在右侧面板查看详细信息
6. **导出结果**：解析完成后会自动在用户文档目录生成 JSON 格式的结果文件
7. **管理历史**：通过解析历史页面查看和管理之前解析过的文件

### JSON 文件位置

解析结果文件保存在以下位置：
- **macOS**: `~/Documents/log/原文件名_parsed_时间戳.json`
- **Windows**: `Documents/log/原文件名_parsed_时间戳.json`  
- **Linux**: `~/Documents/log/原文件名_parsed_时间戳.json`

## 开发指南

### 代码规范

1. **状态管理**：使用 flutter_riverpod 进行状态管理
2. **数据处理**：使用 json_annotation 处理 JSON 序列化
3. **UI 设计**：遵循 Material Design 3 设计规范
4. **注释要求**：所有公共方法和类都需要添加中文注释
5. **错误处理**：完善的异常捕获和用户友好的错误提示
6. **文件操作**：使用 path_provider 获取系统目录，确保跨平台兼容性

### 构建发布

```bash
# 构建 macOS 应用
flutter build macos --release

# 构建 Windows 应用
flutter build windows --release

# 构建 Linux 应用
flutter build linux --release
```

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 致谢

- [美团 Logan](https://github.com/Meituan-Dianping/Logan) - 原始日志框架
- [Flutter](https://flutter.dev/) - 跨平台 UI 框架
- [Riverpod](https://riverpod.dev/) - 状态管理库

---

如有问题或建议，请提交 Issue 或联系开发者。
