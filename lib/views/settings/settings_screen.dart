import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/password_controller.dart';
import '../../services/secure_storage_service.dart';
import '../auth/auth_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSecuritySection(context),
          const SizedBox(height: 24),
          _buildDataSection(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
          const SizedBox(height: 24),
          _buildDangerZone(context),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return _buildSection(
          title: '安全设置',
          children: [
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('认证方式'),
              subtitle: Text(_getAuthTypeText(authController.currentAuthType)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthSetupScreen(),
                  ),
                );
              },
            ),
            if (authController.currentAuthType == AuthType.password) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.password),
                title: const Text('修改主密码'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordDialog(context),
              ),
            ],
            if (authController.currentAuthType == AuthType.pattern) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.pattern),
                title: const Text('修改手势密码'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePatternDialog(context),
              ),
            ],
            if (authController.currentAuthType == AuthType.biometric) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('生物识别设置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showBiometricSettings(context),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Consumer<PasswordController>(
      builder: (context, passwordController, child) {
        return _buildSection(
          title: '数据管理',
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('统计信息'),
              subtitle: Text('共 ${passwordController.totalEntries} 个密码条目'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStatisticsDialog(context, passwordController),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('导出数据'),
              subtitle: const Text('导出为加密的JSON文件'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _exportData(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('导入数据'),
              subtitle: const Text('从JSON文件导入密码'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _importData(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      title: '关于',
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('应用信息'),
          subtitle: const Text('个人密码管理 v1.0.0'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAboutDialog(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('隐私政策'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showPrivacyPolicy(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('帮助与支持'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showHelpDialog(context),
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return _buildSection(
      title: '危险区域',
      titleColor: Colors.red,
      children: [
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.red[700]),
          title: Text(
            '清除所有密码',
            style: TextStyle(color: Colors.red[700]),
          ),
          subtitle: const Text('删除所有密码条目'),
          onTap: () => _clearAllPasswords(context),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.restore, color: Colors.red[700]),
          title: Text(
            '重置应用',
            style: TextStyle(color: Colors.red[700]),
          ),
          subtitle: const Text('删除所有数据并恢复到初始状态'),
          onTap: () => _resetApp(context),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Color? titleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Colors.black87,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  String _getAuthTypeText(AuthType type) {
    switch (type) {
      case AuthType.none:
        return '无认证';
      case AuthType.password:
        return '密码认证';
      case AuthType.pattern:
        return '手势密码';
      case AuthType.biometric:
        return '生物识别';
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    // TODO: 实现修改密码功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('修改密码功能正在开发中')),
    );
  }

  void _showChangePatternDialog(BuildContext context) {
    // TODO: 实现修改手势密码功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('修改手势密码功能正在开发中')),
    );
  }

  void _showBiometricSettings(BuildContext context) {
    // TODO: 实现生物识别设置
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('生物识别设置功能正在开发中')),
    );
  }

  void _showStatisticsDialog(BuildContext context, PasswordController controller) {
    final tags = controller.getAllTags();
    final recentEntries = controller.getRecentEntries();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('统计信息'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('总密码数: ${controller.totalEntries}'),
              const SizedBox(height: 8),
              Text('标签数量: ${tags.length}'),
              const SizedBox(height: 8),
              if (tags.isNotEmpty) ...[
                const Text('所有标签:'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ),
              ],
              if (recentEntries.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('最近更新:'),
                ...recentEntries.take(3).map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• ${entry.title} (${_formatDate(entry.updatedAt)})'),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) async {
    try {
      final controller = context.read<PasswordController>();
      final exportData = await controller.exportAllEntries();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('导出功能正在开发中'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importData(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('导入功能正在开发中'),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '个人密码管理',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.lock, size: 48),
      children: [
        const Text('一个功能强大、隐私安全的本地化密码管理应用。'),
        const SizedBox(height: 16),
        const Text('特性：'),
        const Text('• 本地加密存储'),
        const Text('• 多种认证方式'),
        const Text('• 密码强度检测'),
        const Text('• 数据导入导出'),
        const SizedBox(height: 16),
        const Text('开源项目，欢迎贡献代码！'),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '隐私政策\n\n'
            '1. 数据收集\n'
            '本应用不会收集或传输任何个人信息。所有数据都存储在本地设备上。\n\n'
            '2. 数据存储\n'
            '您的密码和个人信息通过加密方式安全地存储在您的设备上。\n\n'
            '3. 数据安全\n'
            '我们采用行业标准的加密技术保护您的数据安全。\n\n'
            '4. 第三方服务\n'
            '本应用不使用任何第三方服务来存储或处理您的数据。\n\n'
            '5. 数据删除\n'
            '您可以随时删除应用中的所有数据。\n\n'
            '如需更多信息，请联系我们。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助与支持'),
        content: const SingleChildScrollView(
          child: Text(
            '常见问题\n\n'
            'Q: 如何添加密码？\n'
            'A: 点击主页的"+"按钮，填写密码信息。\n\n'
            'Q: 如何搜索密码？\n'
            'A: 在搜索框中输入关键词，应用会自动匹配相关条目。\n\n'
            'Q: 忘记主密码怎么办？\n'
            'A: 很抱歉，忘记密码无法恢复数据，需要重置应用。\n\n'
            'Q: 如何导出密码？\n'
            'A: 在设置中选择"导出数据"，选择保存位置。\n\n'
            'Q: 应用是否安全？\n'
            'A: 是的，所有数据都在本地加密存储，不会上传到服务器。\n\n'
            '如需更多帮助，请联系技术支持。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _clearAllPasswords(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text(
          '确定要清除所有密码条目吗？\n\n'
          '此操作不可撤销！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final controller = context.read<PasswordController>();
      await controller.clearAllPasswordEntries();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('所有密码已清除'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _resetApp(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text(
          '确定要重置应用吗？\n\n'
          '此操作将：\n'
          '• 删除所有密码数据\n'
          '• 清除所有认证设置\n'
          '• 恢复到初始状态\n\n'
          '此操作不可撤销！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authController = context.read<AuthController>();
      await authController.clearAllAuthData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('应用已重置'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}