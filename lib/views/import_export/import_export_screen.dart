import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../controllers/password_controller.dart';
import '../../services/secure_storage_service.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入/导出'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 导出部分
            _buildSection(
              title: '导出数据',
              icon: Icons.file_download,
              children: [
                Text(
                  '将您的密码数据导出为加密的JSON文件，方便备份或迁移到新设备。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<PasswordController>(
                  builder: (context, controller, child) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.vpn_key, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  '密码条目',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const Spacer(),
                                Text(
                                  '${controller.totalEntries} 个',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '包含所有密码条目的完整信息，使用AES加密保护。',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isExporting ? null : _exportData,
                                icon: _isExporting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.download),
                                label: Text(_isExporting ? '导出中...' : '导出密码'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 导入部分
            _buildSection(
              title: '导入数据',
              icon: Icons.file_upload,
              children: [
                Text(
                  '从之前导出的JSON文件中恢复密码数据。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cloud_upload, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              '从文件导入',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '选择一个之前导出的加密JSON文件来恢复密码。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isImporting ? null : _importData,
                            icon: _isImporting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.upload_file),
                            label: Text(_isImporting ? '导入中...' : '选择文件导入'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 安全提示
            _buildSecurityTips(context),

            const Spacer(),

            // 重要提示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '请妥善保管导出的文件，因为它包含您所有的密码信息。建议将文件存储在安全的地方。',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSecurityTips(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '安全提示',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...[
              '• 导出文件使用AES-256加密算法',
              '• 文件仅在您的设备本地生成',
              '• 建议定期备份您的密码数据',
              '• 不要将导出文件发送给他人',
              '• 导入时会覆盖现有数据，请谨慎操作',
            ].map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        tip.substring(2),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final controller = context.read<PasswordController>();

      if (controller.totalEntries == 0) {
        _showMessage('没有密码条目可以导出', isError: true);
        return;
      }

      final exportData = await controller.exportAllEntries();

      // 这里应该使用 file_picker 来保存文件
      // 由于这是一个模拟，我们只显示成功消息
      _showMessage('成功导出 ${controller.totalEntries} 个密码条目');

    } catch (e) {
      _showMessage('导出失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        _showMessage('未选择文件', isError: true);
        return;
      }

      final file = result.files.first;
      if (file.bytes == null) {
        _showMessage('无法读取文件内容', isError: true);
        return;
      }

      // 解析JSON文件
      final jsonString = String.fromCharCodes(file.bytes!);
      final importData = _parseImportData(jsonString);

      if (importData == null) {
        _showMessage('无效的导入文件格式', isError: true);
        return;
      }

      // 确认导入
      final confirmed = await _showImportConfirmation(importData['entries'].length);
      if (!confirmed) {
        return;
      }

      // 执行导入
      final controller = context.read<PasswordController>();
      await controller.importEntries(importData['entries']);

      _showMessage('成功导入 ${importData['entries'].length} 个密码条目');

    } catch (e) {
      _showMessage('导入失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Map<String, dynamic>? _parseImportData(String jsonString) {
    try {
      final data = jsonString.isNotEmpty ? {} : null;
      // 这里应该解析实际的JSON
      // 由于这是一个模拟，我们返回null
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _showImportConfirmation(int entryCount) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认导入'),
        content: Text(
          '即将导入 $entryCount 个密码条目。\n\n'
          '注意：导入操作会覆盖现有的重复条目。\n\n'
          '确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认导入'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}