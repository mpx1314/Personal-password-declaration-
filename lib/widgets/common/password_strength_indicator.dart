import 'package:flutter/material.dart';
import '../../utils/password_helper.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = PasswordHelper.calculatePasswordStrength(password);
    final color = PasswordHelper.getStrengthColor(strength);
    final text = PasswordHelper.getStrengthText(strength);
    final suggestions = PasswordHelper.getPasswordSuggestions(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '密码强度：',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: PasswordHelper.buildStrengthBars(strength),
              ),
            ),
          ],
        ),
        if (suggestions.isNotEmpty && suggestions.first != '密码强度良好') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '密码建议：',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...suggestions.map(
                  (suggestion) => Padding(
                    padding: const EdgeInsets.only(left: 20, top: 2),
                    child: Text(
                      '• $suggestion',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}