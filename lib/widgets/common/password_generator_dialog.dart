import 'package:flutter/material.dart';
import '../../utils/password_helper.dart';

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() => _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSpecial = true;
  bool _excludeSimilar = false;
  bool _isMemorableMode = false;

  final _memorableWordCount = 3.0;
  String _separator = '-';
  bool _capitalize = true;
  bool _includeNumber = true;

  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.vpn_key,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '密码生成器',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildGeneratedPassword(),
              const SizedBox(height: 20),
              _buildModeToggle(),
              const SizedBox(height: 20),
              if (_isMemorableMode) ...[
                _buildMemorableOptions(),
              ] else ...[
                _buildRandomOptions(),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _generatePassword,
                      child: const Text('重新生成'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _usePassword,
                      child: const Text('使用密码'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedPassword() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '生成的密码',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _generatedPassword,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy),
                tooltip: '复制',
              ),
            ],
          ),
          const SizedBox(height: 8),
          PasswordStrengthIndicator(password: _generatedPassword),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '密码类型',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMemorableMode = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isMemorableMode
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '随机密码',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_isMemorableMode
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMemorableMode = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isMemorableMode
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '易记密码',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isMemorableMode
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRandomOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '随机密码选项',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Text(
          '密码长度: ${_length.toInt()}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Slider(
          value: _length,
          min: 6,
          max: 32,
          divisions: 26,
          onChanged: (value) {
            setState(() {
              _length = value;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('包含大写字母'),
          value: _includeUppercase,
          onChanged: (value) {
            setState(() {
              _includeUppercase = value ?? true;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('包含数字'),
          value: _includeNumbers,
          onChanged: (value) {
            setState(() {
              _includeNumbers = value ?? true;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('包含特殊字符'),
          value: _includeSpecial,
          onChanged: (value) {
            setState(() {
              _includeSpecial = value ?? true;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('排除相似字符 (i, l, L, o, 0, O)'),
          value: _excludeSimilar,
          onChanged: (value) {
            setState(() {
              _excludeSimilar = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMemorableOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '易记密码选项',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Text(
          '单词数量: ${_memorableWordCount.toInt()}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Slider(
          value: _memorableWordCount,
          min: 2,
          max: 6,
          divisions: 4,
          onChanged: (value) {
            setState(() {
              _memorableWordCount = value;
            });
          },
        ),
        const SizedBox(height: 12),
        Text(
          '分隔符',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: _separator,
                items: const [
                  DropdownMenuItem(value: '-', child: Text('-')),
                  DropdownMenuItem(value: '_', child: Text('_')),
                  DropdownMenuItem(value: '.', child: Text('.')),
                  DropdownMenuItem(value: ' ', child: Text('空格')),
                  DropdownMenuItem(value: '', child: Text('无分隔符')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _separator = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('首字母大写'),
          value: _capitalize,
          onChanged: (value) {
            setState(() {
              _capitalize = value ?? true;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('包含数字'),
          value: _includeNumber,
          onChanged: (value) {
            setState(() {
              _includeNumber = value ?? true;
            });
          },
        ),
      ],
    );
  }

  void _generatePassword() {
    setState(() {
      if (_isMemorableMode) {
        _generatedPassword = PasswordHelper.generateMemorablePassword(
          wordCount: _memorableWordCount.toInt(),
          separator: _separator,
          capitalize: _capitalize,
          includeNumber: _includeNumber,
        );
      } else {
        _generatedPassword = PasswordHelper.generateRandomPassword(
          length: _length.toInt(),
          includeUppercase: _includeUppercase,
          includeNumbers: _includeNumbers,
          includeSpecial: _includeSpecial,
          excludeSimilar: _excludeSimilar,
        );
      }
    });
  }

  void _copyToClipboard() {
    PasswordHelper.copyToClipboard(_generatedPassword);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('密码已复制到剪贴板')),
    );
  }

  void _usePassword() {
    Navigator.pop(context, _generatedPassword);
  }
}