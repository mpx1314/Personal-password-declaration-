import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../services/secure_storage_service.dart';
import 'password_auth_screen.dart';
import 'pattern_auth_screen.dart';

class AuthSetupScreen extends StatefulWidget {
  const AuthSetupScreen({super.key});

  @override
  State<AuthSetupScreen> createState() => _AuthSetupScreenState();
}

class _AuthSetupScreenState extends State<AuthSetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                Icons.lock,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                '欢迎使用个人密码管理',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '选择一种认证方式来保护您的密码',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildAuthOptions(),
              const SizedBox(height: 20),
              _buildPasswordForm(),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOptions() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Column(
          children: [
            _buildAuthOption(
              context,
              AuthType.password,
              Icons.password,
              '密码认证',
              '使用传统密码进行身份验证',
              authController.currentAuthType == AuthType.password,
              () {
                // 密码认证是默认选项，不需要额外操作
              },
            ),
            const SizedBox(height: 12),
            _buildAuthOption(
              context,
              AuthType.pattern,
              Icons.pattern,
              '手势密码',
              '绘制图案进行身份验证',
              authController.currentAuthType == AuthType.pattern,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatternAuthScreen(
                      isSetup: true,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildBiometricOption(context),
          ],
        );
      },
    );
  }

  Widget _buildAuthOption(
    BuildContext context,
    AuthType type,
    IconData icon,
    String title,
    String description,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricOption(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return FutureBuilder<bool>(
          future: authController.isBiometricAvailable(),
          builder: (context, snapshot) {
            final isAvailable = snapshot.data ?? false;

            if (!isAvailable) {
              return const SizedBox.shrink();
            }

            return _buildAuthOption(
              context,
              AuthType.biometric,
              Icons.fingerprint,
              '生物识别',
              '使用指纹或面部识别进行验证',
              authController.currentAuthType == AuthType.biometric,
              () async {
                final success = await authController.enableBiometric();
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('生物识别启用成功'),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordForm() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.currentAuthType != AuthType.password) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '设置主密码',
                hintText: '至少4位字符',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                if (value.length < 4) {
                  return '密码长度至少为4位';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认密码',
                hintText: '再次输入密码',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请确认密码';
                }
                if (value != _passwordController.text) {
                  return '两次输入的密码不一致';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.currentAuthType == AuthType.none) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  authController.setAuthType(AuthType.none);
                },
                child: const Text('跳过'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeSetup,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('完成设置'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeSetup() async {
    final authController = context.read<AuthController>();

    if (authController.currentAuthType == AuthType.password) {
      if (_passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入密码')),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('两次输入的密码不一致')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final success = await authController.setMasterPassword(_passwordController.text);

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('认证设置完成')),
        );
      }
    } else if (authController.currentAuthType == AuthType.biometric ||
        authController.currentAuthType == AuthType.pattern) {
      // 生物识别和手势密码已经在对应的界面中处理
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('认证设置完成')),
      );
    }
  }
}