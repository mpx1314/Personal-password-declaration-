import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/password_controller.dart';
import '../../views/import_export/import_export_screen.dart';
import '../../views/settings/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  title: '主页',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.import_export,
                  title: '导入/导出',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImportExportScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: '设置',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.security,
                  title: '安全设置',
                  onTap: () {
                    Navigator.pop(context);
                    _showSecuritySettings(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: '关于',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<PasswordController>(
      builder: (context, passwordController, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.lock,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '个人密码管理',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '安全存储您的密码',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    '总密码数',
                    '${passwordController.totalEntries}',
                    Icons.vpn_key,
                  ),
                  _buildStatItem(
                    context,
                    '搜索结果',
                    '${passwordController.filteredEntriesCount}',
                    Icons.search,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              '退出登录',
              style: TextStyle(color: Colors.red[700]),
            ),
            onTap: () async {
              Navigator.pop(context);
              await _showLogoutDialog(context);
            },
          ),
        );
      },
    );
  }

  void _showSecuritySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安全设置'),
        content: const Text(
          '安全设置功能正在开发中，您可以在设置页面修改认证方式。',
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

  void _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await context.read<AuthController>().logout();
    }
  }
}