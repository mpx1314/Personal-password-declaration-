import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../controllers/password_controller.dart';
import '../../models/password_entry.dart';
import '../../utils/password_helper.dart';
import '../common/password_strength_indicator.dart';
import '../common/password_generator_dialog.dart';

class AddPasswordDialog extends StatefulWidget {
  final PasswordEntry? entry; // 如果提供，则为编辑模式

  const AddPasswordDialog({
    super.key,
    this.entry,
  });

  @override
  State<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends State<AddPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();

  bool _obscurePassword = true;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _initializeForEdit();
    }
  }

  void _initializeForEdit() {
    final entry = widget.entry!;
    _titleController.text = entry.title;
    _usernameController.text = entry.username;
    _passwordController.text = entry.password;
    _websiteController.text = entry.website ?? '';
    _notesController.text = entry.notes ?? '';
    _tags = List.from(entry.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? '编辑密码条目' : '添加密码条目',
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
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '标题 *',
                    hintText: '例如：Google账号',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入标题';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名/邮箱 *',
                    hintText: '输入用户名或邮箱地址',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码 *',
                    hintText: '输入密码',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _togglePasswordVisibility,
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                        IconButton(
                          onPressed: _showPasswordGenerator,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                PasswordStrengthIndicator(password: _passwordController.text),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: '网站',
                    hintText: 'https://example.com',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    hintText: '添加备注信息',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildTagsSection(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _savePassword,
                        child: Text(isEditing ? '更新' : '保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: '添加标签',
                  hintText: '输入标签名称',
                ),
                onFieldSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showPasswordGenerator() async {
    final generatedPassword = await showDialog<String>(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );

    if (generatedPassword != null && generatedPassword.isNotEmpty) {
      _passwordController.text = generatedPassword;
      setState(() {});
    }
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
    }
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final passwordController = context.read<PasswordController>();

    // 检查重复标题
    if (passwordController.hasDuplicateTitle(
          _titleController.text,
          excludeId: widget.entry?.id,
        )) {
      _showError('已存在相同标题的密码条目');
      return;
    }

    try {
      final entry = PasswordEntry(
        id: widget.entry?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        tags: _tags,
      );

      if (widget.entry != null) {
        await passwordController.updatePasswordEntry(entry);
        _showSuccess('密码条目更新成功');
      } else {
        await passwordController.addPasswordEntry(entry);
        _showSuccess('密码条目添加成功');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('保存失败：${e.toString()}');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}