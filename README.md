# 个人密码管理 (Personal Password Manager)

一个功能强大、隐私安全的本地化密码管理应用，基于Flutter开发的Android应用。

## 📱 功能特性

### 🔐 安全认证
- **多种认证方式**：支持密码认证、手势密码、生物识别
- **本地加密存储**：所有数据在设备本地加密存储，不上传云端
- **AES加密**：使用强大的加密算法保护您的密码安全

### 💾 密码管理
- **添加密码**：快速添加密码条目，支持标题、用户名、密码、网站、备注和标签
- **智能搜索**：根据标题、网站、标签快速搜索密码条目
- **密码强度检测**：实时显示密码强度，提供安全建议
- **密码生成器**：内置随机密码和易记密码生成器

### 📤 数据管理
- **数据导出**：导出加密的JSON文件，方便备份和迁移
- **数据导入**：从备份文件恢复密码数据
- **统计信息**：查看密码数量、标签使用情况等统计

### 🎨 用户体验
- **Material Design 3**：采用现代化的Material Design设计语言
- **深色模式**：支持系统深色模式
- **响应式设计**：适配不同屏幕尺寸
- **直观操作**：简洁易用的用户界面

## 🏗️ 技术架构

### 核心技术栈
- **Flutter 3.10+**：跨平台移动开发框架
- **Provider**：状态管理
- **SQLite**：本地数据库存储
- **Flutter Secure Storage**：安全存储敏感信息

### 主要依赖库
```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI相关
  cupertino_icons: ^1.0.6
  flutter_screenutil: ^5.9.0
  google_fonts: ^6.1.0

  # 安全和加密
  flutter_secure_storage: ^9.0.0
  encrypt: ^5.0.1
  crypto: ^3.0.3

  # 本地存储
  sqflite: ^2.3.0
  path: ^1.8.3

  # 生物识别认证
  local_auth: ^2.1.6

  # 手势密码
  pattern_lock: ^2.0.2

  # 文件操作
  file_picker: ^6.1.1
  path_provider: ^2.1.1

  # 状态管理
  provider: ^6.1.1

  # 工具类
  uuid: ^4.2.1
  intl: ^0.18.1

  # 权限管理
  permission_handler: ^11.0.1
```

## 📁 项目结构

```
lib/
├── controllers/           # 控制器层
│   ├── auth_controller.dart      # 认证控制器
│   └── password_controller.dart  # 密码控制器
├── models/               # 数据模型
│   └── password_entry.dart       # 密码条目模型
├── services/             # 服务层
│   ├── database_service.dart     # 数据库服务
│   └── secure_storage_service.dart # 安全存储服务
├── utils/                # 工具类
│   └── password_helper.dart      # 密码辅助工具
├── views/                # 页面
│   ├── auth/             # 认证相关页面
│   ├── home/             # 主页面
│   ├── settings/         # 设置页面
│   └── import_export/    # 导入导出页面
├── widgets/              # 组件
│   ├── add/              # 添加相关组件
│   ├── common/           # 通用组件
│   ├── password/         # 密码相关组件
│   └── search/           # 搜索相关组件
├── theme/                # 主题
│   └── app_theme.dart    # 应用主题
└── main.dart             # 入口文件
```

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.10.0+
- Dart SDK 3.0.0+
- Android SDK (Android开发)
- Android Studio / VS Code

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/personal-password-declaration.git
   cd personal-password-declaration
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **检查环境**
   ```bash
   flutter doctor
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

### 构建APK
```bash
# 构建Debug版本
flutter build apk --debug

# 构建Release版本
flutter build apk --release
```

## 🔧 开发指南

### 代码规范
- 遵循Dart官方代码规范
- 使用`flutter_lints`进行代码检查
- 组件采用函数式编程风格
- 使用Provider进行状态管理

### 添加新功能
1. 在`models/`中定义数据模型
2. 在`services/`中实现业务逻辑
3. 在`controllers/`中添加状态管理
4. 在`views/`中创建用户界面
5. 在`widgets/`中创建可复用组件

### 安全注意事项
- 所有密码使用AES-256加密
- 敏感信息存储在Flutter Secure Storage中
- 数据库操作使用参数化查询防止SQL注入
- 生物识别认证使用系统原生API

## 📱 使用说明

### 首次使用
1. 打开应用，选择认证方式
2. 设置主密码/手势密码/生物识别
3. 开始添加密码条目

### 添加密码
1. 点击主页的"+"按钮
2. 填写密码信息（标题、用户名、密码等）
3. 可以添加标签和备注
4. 点击保存

### 搜索密码
1. 在搜索框中输入关键词
2. 应用会实时显示匹配的密码条目
3. 支持按标题、网站、标签搜索

### 导入导出
1. 在设置中选择"导入/导出"
2. 导出：选择保存位置，生成加密文件
3. 导入：选择备份文件，确认导入

## 🔒 安全特性

### 数据加密
- 使用AES-256加密算法
- 每个设备使用唯一加密密钥
- 密码在存储前自动加密

### 认证方式
- **密码认证**：传统主密码方式
- **手势密码**：9点图案认证
- **生物识别**：指纹/面部识别

### 隐私保护
- 所有数据存储在本地设备
- 不收集用户个人信息
- 不上传数据到任何服务器
- 开源代码，透明可审计

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 贡献方式
- 提交Issue报告问题
- 提交Pull Request改进代码
- 完善文档和翻译
- 分享使用建议

### 开发流程
1. Fork项目
2. 创建功能分支
3. 提交代码
4. 创建Pull Request
5. 等待代码审查

### 代码提交规范
```
feat: 新功能
fix: 修复问题
docs: 文档更新
style: 代码格式调整
refactor: 代码重构
test: 测试相关
chore: 构建工具或辅助工具的变动
```

## 📄 许可证

本项目采用MIT许可证，详见[LICENSE](LICENSE)文件。

⭐ 如果这个项目对您有帮助，请给一个Star！