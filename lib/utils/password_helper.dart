import 'package:flutter/services.dart';
import 'dart:math';

enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
  veryStrong,
}

class PasswordHelper {
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  // 计算密码强度
  static PasswordStrength calculatePasswordStrength(String password) {
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;

    // 长度评分
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // 字符类型评分
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // 转换为强度等级
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.good;
    if (score <= 6) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  // 获取强度颜色
  static Color getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return const Color(0xFFD32F2F); // Red
      case PasswordStrength.fair:
        return const Color(0xFFFF9800); // Orange
      case PasswordStrength.good:
        return const Color(0xFFFFC107); // Amber
      case PasswordStrength.strong:
        return const Color(0xFF4CAF50); // Green
      case PasswordStrength.veryStrong:
        return const Color(0xFF2E7D32); // Dark Green
    }
  }

  // 获取强度文本
  static String getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return '弱';
      case PasswordStrength.fair:
        return '一般';
      case PasswordStrength.good:
        return '良好';
      case PasswordStrength.strong:
        return '强';
      case PasswordStrength.veryStrong:
        return '很强';
    }
  }

  // 生成随机密码
  static String generateRandomPassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSpecial = true,
    bool excludeSimilar = true,
  }) {
    String chars = _lowercase;
    if (includeUppercase) chars += _uppercase;
    if (includeNumbers) chars += _numbers;
    if (includeSpecial) chars += _special;

    if (excludeSimilar) {
      final similar = 'ilLoO0';
      chars = chars.replaceAll(RegExp('[$similar]'), '');
    }

    final random = Random.secure();
    final password = StringBuffer();

    for (int i = 0; i < length; i++) {
      password.write(chars[random.nextInt(chars.length)]);
    }

    return password.toString();
  }

  // 生成易记密码
  static String generateMemorablePassword({
    int wordCount = 3,
    String separator = '-',
    bool capitalize = true,
    bool includeNumber = true,
  }) {
    final words = [
      'apple', 'banana', 'orange', 'grape', 'lemon', 'peach', 'berry', 'melon',
      'happy', 'sunny', 'bright', 'light', 'sweet', 'fresh', 'clean', 'clear',
      'mountain', 'ocean', 'forest', 'river', 'cloud', 'star', 'moon', 'sun',
      'coffee', 'tea', 'water', 'juice', 'milk', 'bread', 'cheese', 'butter',
      'dog', 'cat', 'bird', 'fish', 'bear', 'lion', 'tiger', 'wolf',
    ];

    final random = Random.secure();
    final selectedWords = <String>[];

    for (int i = 0; i < wordCount; i++) {
      final word = words[random.nextInt(words.length)];
      selectedWords.add(capitalize ? _capitalize(word) : word);
    }

    String password = selectedWords.join(separator);

    if (includeNumber) {
      password += random.nextInt(100).toString();
    }

    return password;
  }

  // 检查密码是否已泄露（简单模拟）
  static bool isPasswordCommon(String password) {
    final commonPasswords = [
      '123456', 'password', '123456789', '12345678', '12345', '1234567',
      '1234567890', '1234', 'qwerty', 'abc123', '111111', 'password123',
      'admin', 'letmein', 'welcome', 'monkey', '1234567890', 'qwertyuiop',
    ];

    return commonPasswords.contains(password.toLowerCase());
  }

  // 获取密码建议
  static List<String> getPasswordSuggestions(String password) {
    final suggestions = <String>[];

    if (password.length < 12) {
      suggestions.add('建议密码长度至少12位');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      suggestions.add('建议包含大写字母');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      suggestions.add('建议包含数字');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      suggestions.add('建议包含特殊字符');
    }

    if (isPasswordCommon(password)) {
      suggestions.add('避免使用常见密码');
    }

    if (suggestions.isEmpty) {
      suggestions.add('密码强度良好');
    }

    return suggestions;
  }

  // 复制到剪贴板
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // 检查密码是否匹配
  static bool doPasswordsMatch(String password1, String password2) {
    return password1 == password2;
  }

  // 验证密码格式
  static bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  // 首字母大写
  static String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }

  // 生成密码强度条
  static List<Widget> buildStrengthBars(PasswordStrength strength) {
    final colors = _getStrengthBarColors(strength);
    return List.generate(5, (index) {
      return Container(
        margin: const EdgeInsets.only(right: 4),
        width: 30,
        height: 4,
        decoration: BoxDecoration(
          color: index < colors.length ? colors[index] : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      );
    });
  }

  static List<Color> _getStrengthBarColors(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return [const Color(0xFFD32F2F)];
      case PasswordStrength.fair:
        return [const Color(0xFFFF9800)];
      case PasswordStrength.good:
        return [const Color(0xFFFFC107), const Color(0xFFFFC107)];
      case PasswordStrength.strong:
        return [const Color(0xFF4CAF50), const Color(0xFF4CAF50), const Color(0xFF4CAF50)];
      case PasswordStrength.veryStrong:
        return [const Color(0xFF2E7D32), const Color(0xFF2E7D32), const Color(0xFF2E7D32), const Color(0xFF2E7D32)];
    }
  }
}