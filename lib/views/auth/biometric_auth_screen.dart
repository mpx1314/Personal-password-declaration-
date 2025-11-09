import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometric();
    });
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
              // 生物识别图标
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return FutureBuilder<List<String>>(
                    future: _getAvailableBiometricsText(authController),
                    builder: (context, snapshot) {
                      final biometricType = snapshot.data?.first ?? 'biometric';
                      IconData icon = _getBiometricIcon(biometricType);

                      return Icon(
                        icon,
                        size: 120,
                        color: _getStatusColor(authController),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // 标题
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  String title = '生物识别验证';
                  if (authController.errorMessage != null) {
                    title = '验证失败';
                  }

                  return Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: _getStatusColor(authController),
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),

              const SizedBox(height: 16),

              // 描述文本
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  String message = '请使用您的生物识别信息进行验证';
                  if (authController.errorMessage != null) {
                    message = authController.errorMessage!;
                  }

                  return Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: authController.errorMessage != null
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),

              const SizedBox(height: 40),

              // 生物识别类型显示
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return FutureBuilder<List<String>>(
                    future: _getAvailableBiometricsText(authController),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.security,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '支持${snapshot.data!.join('、')}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),

              const SizedBox(height: 40),

              // 操作按钮
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    if (authController.errorMessage != null) {
                      return Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _authenticateWithBiometric,
                            icon: const Icon(Icons.refresh),
                            label: const Text('重新验证'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _showAlternativeAuthDialog,
                            child: const Text('使用其他方式验证'),
                          ),
                        ],
                      );
                    }

                    return ElevatedButton.icon(
                      onPressed: _authenticateWithBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('开始验证'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 20),

              // 提示文本
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  if (authController.errorMessage != null) {
                    return TextButton(
                      onPressed: _showHelpDialog,
                      child: Text(
                        '遇到问题？',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AuthController authController) {
    if (authController.errorMessage != null) {
      return Colors.red;
    }
    return Theme.of(context).primaryColor;
  }

  IconData _getBiometricIcon(String biometricType) {
    switch (biometricType.toLowerCase()) {
      case 'fingerprint':
      case '指纹':
        return Icons.fingerprint;
      case 'face':
      case '面部识别':
        return Icons.face;
      case 'iris':
      case '虹膜':
        return Icons.visibility;
      default:
        return Icons.security;
    }
  }

  Future<List<String>> _getAvailableBiometricsText(AuthController authController) async {
    try {
      final availableBiometrics = await authController.getAvailableBiometrics();
      return availableBiometrics.map((biometric) {
        switch (biometric) {
          case BiometricType.fingerprint:
            return '指纹识别';
          case BiometricType.face:
            return '面部识别';
          case BiometricType.iris:
            return '虹膜识别';
          case BiometricType.strong:
            return '强生物识别';
          case BiometricType.weak:
            return '弱生物识别';
        }
      }).toList();
    } catch (e) {
      return ['生物识别'];
    }
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
    });

    final authController = context.read<AuthController>();
    final success = await authController.authenticateWithBiometric();

    setState(() {
      _isLoading = false;
    });

    if (!success && mounted) {
      // 验证失败，显示错误信息
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && authController.errorMessage != null) {
          // 这里可以清除错误信息，让用户重新尝试
        }
      });
    }
  }

  void _showAlternativeAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择其他验证方式'),
        content: const Text(
          '您可以使用其他方式验证身份，或者重置应用数据。\n'
          '重置应用将删除所有数据。',
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生物识别帮助'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('如果生物识别失败，请尝试以下方法：'),
            SizedBox(height: 12),
            Text('• 确保您的指纹或面部已注册到系统中'),
            Text('• 清洁指纹传感器或摄像头'),
            Text('• 尝试使用不同的手指或角度'),
            Text('• 检查设备设置中的生物识别功能'),
            Text('• 如果仍然无法使用，请重置应用'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
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