# 快速开始指南

## 🚀 立即运行

### 前置条件
- 安装 [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10.0+)
- 安装 Android Studio 或 VS Code
- 配置 Android 开发环境

### 运行步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/personal-password-declaration.git
   cd personal-password-declaration
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **连接设备或启动模拟器**
   ```bash
   # 查看可用设备
   flutter devices

   # 启动模拟器（如果需要）
   flutter emulators
   flutter emulators --launch <emulator_id>
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

### 快速测试

如果您想快速体验应用功能：

1. **首次使用**：选择"跳过"认证，直接进入主界面
2. **添加密码**：点击右下角的"+"按钮添加测试密码
3. **搜索测试**：在搜索框输入关键词测试搜索功能
4. **设置认证**：在设置中选择认证方式提高安全性

## 📱 核心功能体验

### 1. 添加密码条目
- 标题：如"Gmail账号"
- 用户名：your-email@gmail.com
- 密码：使用密码生成器创建强密码
- 网站：https://gmail.com
- 标签：邮箱,工作

### 2. 搜索功能
- 支持按标题搜索
- 支持按网站搜索
- 支持按标签搜索
- 实时显示搜索结果

### 3. 密码管理
- 点击密码条目查看详情
- 一键复制用户名和密码
- 查看密码强度指示
- 编辑或删除密码条目

### 4. 安全设置
- 设置主密码认证
- 配置手势密码
- 启用生物识别
- 导出/导入数据备份

## 🔧 开发者指南

### 项目结构概览
```
lib/
├── main.dart              # 应用入口
├── controllers/           # 状态管理
├── models/               # 数据模型
├── services/             # 数据服务
├── views/                # 页面组件
├── widgets/              # 可复用组件
├── utils/                # 工具函数
└── theme/                # 主题配置
```

### 常用命令
```bash
# 格式化代码
dart format .

# 静态分析
flutter analyze

# 运行测试
flutter test

# 构建APK
flutter build apk --release
```

## 🐛 常见问题

### Q: 构建时出现依赖冲突
A: 运行 `flutter clean` 然后 `flutter pub get`

### Q: 模拟器运行慢
A: 在 Android Studio 中开启硬件加速

### Q: 生物识别功能不工作
A: 确保设备已设置指纹/面部识别

### Q: 导入导出功能异常
A: 检查文件权限，确保应用有存储访问权限


祝您使用愉快！🎉