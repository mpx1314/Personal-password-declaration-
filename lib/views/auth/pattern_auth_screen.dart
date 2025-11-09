import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pattern_lock/pattern_lock.dart';

import '../../controllers/auth_controller.dart';

class PatternAuthScreen extends StatefulWidget {
  final bool isSetup; // true为设置模式，false为验证模式

  const PatternAuthScreen({
    super.key,
    this.isSetup = false,
  });

  @override
  State<PatternAuthScreen> createState() => _PatternAuthScreenState();
}

class _PatternAuthScreenState extends State<PatternAuthScreen> {
  List<int>? _selectedPattern;
  List<int>? _confirmedPattern;
  String _statusText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateStatusText();
  }

  void _updateStatusText() {
    if (widget.isSetup) {
      if (_selectedPattern == null) {
        _statusText = '请绘制您的手势密码';
      } else if (_confirmedPattern == null) {
        _statusText = '请再次绘制手势密码';
      } else {
        _statusText = '手势密码设置成功';
      }
    } else {
      _statusText = '请绘制手势密码';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (widget.isSetup)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  Expanded(
                    child: Text(
                      widget.isSetup ? '设置手势密码' : '验证手势密码',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (widget.isSetup) const SizedBox(width: 48),
                ],
              ),
            ),

            // 状态文本
            Consumer<AuthController>(
              builder: (context, authController, child) {
                String status = _statusText;

                if (!widget.isSetup && authController.errorMessage != null) {
                  status = authController.errorMessage!;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(authController).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(authController).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(authController),
                        color: _getStatusColor(authController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(authController),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // 手势密码区域
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: PatternLock(
                  selectColor: Theme.of(context).primaryColor,
                  dimension: 3,
                  onInputComplete: _onPatternComplete,
                ),
              ),
            ),

            // 操作按钮
            if (widget.isSetup) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _selectedPattern != null ? _resetPattern : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('重新绘制'),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: _showForgotPatternDialog,
                  child: Text(
                    '忘记手势密码？',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AuthController authController) {
    if (authController.errorMessage != null) {
      return Colors.red;
    }

    if (widget.isSetup) {
      if (_confirmedPattern != null) {
        return Colors.green;
      }
      return Theme.of(context).primaryColor;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  IconData _getStatusIcon(AuthController authController) {
    if (authController.errorMessage != null) {
      return Icons.error_outline;
    }

    if (widget.isSetup) {
      if (_confirmedPattern != null) {
        return Icons.check_circle;
      }
      return Icons.pattern;
    } else {
      return Icons.pattern;
    }
  }

  
  void _onPatternComplete(List<int> pattern) async {
    if (pattern.length < 4) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('手势密码至少连接4个点')),
        );
      }
      return;
    }

    if (widget.isSetup) {
      await _handleSetupPattern(pattern);
    } else {
      await _handleVerifyPattern(pattern);
    }
  }

  Future<void> _handleSetupPattern(List<int> pattern) async {
    if (_selectedPattern == null) {
      // 第一次绘制
      setState(() {
        _selectedPattern = pattern;
        _updateStatusText();
      });
    } else if (_confirmedPattern == null) {
      // 第二次绘制
      if (_listsEqual(_selectedPattern!, pattern)) {
        setState(() {
          _confirmedPattern = pattern;
          _updateStatusText();
        });

        // 保存手势密码
        final authController = context.read<AuthController>();
        final patternString = pattern.join(',');

        setState(() {
          _isLoading = true;
        });

        final success = await authController.setPattern(patternString);

        setState(() {
          _isLoading = false;
        });

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('手势密码设置成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('两次绘制的手势密码不一致')),
        );
        _resetPattern();
      }
    }
  }

  Future<void> _handleVerifyPattern(List<int> pattern) async {
    setState(() {
      _isLoading = true;
    });

    final authController = context.read<AuthController>();
    final patternString = pattern.join(',');
    final success = await authController.verifyPattern(patternString);

    setState(() {
      _isLoading = false;
    });

    if (!success && mounted) {
      // 验证失败，清除错误信息以便下次尝试
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          authController.clearError();
        }
      });
    }
  }

  void _resetPattern() {
    setState(() {
      _selectedPattern = null;
      _confirmedPattern = null;
      _updateStatusText();
    });
  }

  bool _listsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  void _showForgotPatternDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('忘记手势密码'),
        content: const Text(
          '很抱歉，忘记手势密码将无法恢复您的数据。\n\n'
          '如果您忘记手势密码，唯一的解决方案是清除所有数据并重新设置应用。\n'
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