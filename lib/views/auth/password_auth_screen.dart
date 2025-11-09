import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';

class PasswordAuthScreen extends StatefulWidget {
  const PasswordAuthScreen({super.key});

  @override
  State<PasswordAuthScreen> createState() => _PasswordAuthScreenState();
}

class _PasswordAuthScreenState extends State<PasswordAuthScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              Text(
                '验证身份',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                '请输入主密码以继续',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return Column(
                    children: [
                      if (authController.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authController.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofocus: true,
                        onSubmitted: (_) => _verifyPassword(),
                        decoration: InputDecoration(
                          labelText: '主密码',
                          hintText: '输入您的密码',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: _verifyPassword,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('验证'),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text(
                  '忘记密码？',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authController = context.read<AuthController>();
    final success = await authController.verifyMasterPassword(_passwordController.text);

    setState(() {
      _isLoading = false;
    });

    if (!success) {
      _passwordController.clear();
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('忘记密码'),
        content: const Text(
          '很抱歉，忘记密码将无法恢复您的数据。\n\n'
          '如果您忘记密码，唯一的解决方案是清除所有数据并重新设置应用。\n'
          '这将删除所有已保存的密码信息。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetApp();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('重置应用'),
          ),
        ],
      ),
    );
  }

  void _resetApp() async {
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('应用已重置，请重新设置'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}