import 'package:flutter/material.dart';
import '../../models/password_entry.dart';
import '../../utils/password_helper.dart';

class PasswordEntryCard extends StatelessWidget {
  final PasswordEntry entry;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onCopyPassword;
  final VoidCallback onCopyUsername;
  final VoidCallback? onOpenWebsite;

  const PasswordEntryCard({
    super.key,
    required this.entry,
    required this.searchQuery,
    required this.onTap,
    required this.onCopyPassword,
    required this.onCopyUsername,
    this.onOpenWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _highlightText(entry.title, searchQuery),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.website != null && entry.website!.isNotEmpty)
                    IconButton(
                      onPressed: onOpenWebsite,
                      icon: const Icon(Icons.language),
                      iconSize: 20,
                    ),
                ],
              ),
              if (entry.username.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _highlightText(entry.username, searchQuery),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: onCopyUsername,
                      icon: const Icon(Icons.copy, size: 18),
                      iconSize: 18,
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '•' * 8,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onCopyPassword,
                    icon: const Icon(Icons.copy, size: 18),
                    iconSize: 18,
                    splashRadius: 20,
                  ),
                ],
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTags(context),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '更新于 ${_formatDate(entry.updatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  _buildStrengthIndicator(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: entry.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStrengthIndicator(BuildContext context) {
    final strength = PasswordHelper.calculatePasswordStrength(entry.password);
    final color = PasswordHelper.getStrengthColor(strength);
    final text = PasswordHelper.getStrengthText(strength);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          _getStrengthIcon(strength),
          size: 14,
          color: color,
        ),
      ],
    );
  }

  IconData _getStrengthIcon(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Icons.sentiment_very_dissatisfied;
      case PasswordStrength.fair:
        return Icons.sentiment_dissatisfied;
      case PasswordStrength.good:
        return Icons.sentiment_neutral;
      case PasswordStrength.strong:
        return Icons.sentiment_satisfied;
      case PasswordStrength.veryStrong:
        return Icons.sentiment_very_satisfied;
    }
  }

  String _highlightText(String text, String query) {
    if (query.isEmpty) return text;

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) return text;

    final before = text.substring(0, index);
    final match = text.substring(index, index + query.length);
    final after = text.substring(index + query.length);

    return '$before$match$after';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return '刚刚';
        }
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }
}