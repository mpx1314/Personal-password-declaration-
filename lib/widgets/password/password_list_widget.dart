import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/password_entry.dart';
import '../../widgets/password/password_entry_card.dart';
import '../../utils/password_helper.dart';

class PasswordListWidget extends StatelessWidget {
  final List<PasswordEntry> entries;
  final String searchQuery;

  const PasswordListWidget({
    super.key,
    required this.entries,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('没有找到密码条目'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return PasswordEntryCard(
          entry: entry,
          searchQuery: searchQuery,
          onTap: () => _showEntryDetails(context, entry),
          onCopyPassword: () => _copyPasswordToClipboard(context, entry),
          onCopyUsername: () => _copyUsernameToClipboard(context, entry),
          onOpenWebsite: entry.website != null ? () => _openWebsite(context, entry.website!) : null,
        );
      },
    );
  }

  void _showEntryDetails(BuildContext context, PasswordEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PasswordEntryBottomSheet(entry: entry),
    );
  }

  void _copyPasswordToClipboard(BuildContext context, PasswordEntry entry) async {
    await PasswordHelper.copyToClipboard(entry.password);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('密码已复制到剪贴板')),
    );
  }

  void _copyUsernameToClipboard(BuildContext context, PasswordEntry entry) async {
    await PasswordHelper.copyToClipboard(entry.username);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户名已复制到剪贴板')),
    );
  }

  void _openWebsite(BuildContext context, String website) async {
    final url = _formatUrl(website);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法打开网站: $website')),
      );
    }
  }

  String _formatUrl(String website) {
    if (website.startsWith('http://') || website.startsWith('https://')) {
      return website;
    }
    return 'https://$website';
  }
}

class PasswordEntryBottomSheet extends StatelessWidget {
  final PasswordEntry entry;

  const PasswordEntryBottomSheet({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                entry.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              if (entry.username.isNotEmpty) ...[
                _buildDetailRow(
                  context,
                  '用户名',
                  entry.username,
                  Icons.person,
                  () => _copyToClipboard(context, entry.username, '用户名'),
                ),
                const SizedBox(height: 12),
              ],
              _buildDetailRow(
                context,
                '密码',
                '•' * 8,
                Icons.lock,
                () => _copyToClipboard(context, entry.password, '密码'),
                isPassword: true,
              ),
              if (entry.website != null && entry.website!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  '网站',
                  entry.website!,
                  Icons.language,
                  () => _openWebsite(context, entry.website!),
                ),
              ],
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  '备注',
                  entry.notes!,
                  Icons.note,
                  null,
                ),
              ],
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTagsRow(context),
              ],
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                '创建时间',
                _formatDate(entry.createdAt),
                Icons.schedule,
                null,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                '更新时间',
                _formatDate(entry.updatedAt),
                Icons.update,
                null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback? onTap, {
    bool isPassword = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isPassword ? '•' * 8 : value,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.copy,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.tag, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '标签',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: entry.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) async {
    await PasswordHelper.copyToClipboard(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label已复制到剪贴板')),
    );
    Navigator.pop(context);
  }

  void _openWebsite(BuildContext context, String website) async {
    final url = website.startsWith('http') ? website : 'https://$website';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法打开网站: $website')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}