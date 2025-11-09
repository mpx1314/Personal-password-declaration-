import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainItemAccessibility.first_unlock_this_device,
    ),
  );

  static const String _masterPasswordKey = 'master_password';
  static const String _authTypeKey = 'auth_type';
  static const String _patternKey = 'pattern_password';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _encryptionKeyKey = 'encryption_key';

  static Future<void> init() async {
    // 确保存储初始化
    await _storage.readAll();
  }

  // 主密码相关
  static Future<void> setMasterPassword(String password) async {
    final hashedPassword = _hashPassword(password);
    await _storage.write(key: _masterPasswordKey, value: hashedPassword);
  }

  static Future<String?> getMasterPassword() async {
    return await _storage.read(key: _masterPasswordKey);
  }

  static Future<bool> hasMasterPassword() async {
    final password = await getMasterPassword();
    return password != null && password.isNotEmpty;
  }

  static Future<bool> verifyMasterPassword(String password) async {
    final storedPassword = await getMasterPassword();
    if (storedPassword == null) return false;
    return _hashPassword(password) == storedPassword;
  }

  // 认证类型相关
  static Future<void> setAuthType(AuthType type) async {
    await _storage.write(key: _authTypeKey, value: type.name);
  }

  static Future<AuthType> getAuthType() async {
    final typeString = await _storage.read(key: _authTypeKey);
    return AuthType.values.firstWhere(
      (type) => type.name == typeString,
      orElse: () => AuthType.none,
    );
  }

  // 手势密码相关
  static Future<void> setPattern(String pattern) async {
    await _storage.write(key: _patternKey, value: pattern);
  }

  static Future<String?> getPattern() async {
    return await _storage.read(key: _patternKey);
  }

  static Future<bool> verifyPattern(String pattern) async {
    final storedPattern = await getPattern();
    return storedPattern == pattern;
  }

  // 生物识别相关
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  // 加密密钥相关
  static Future<String> getEncryptionKey() async {
    String? key = await _storage.read(key: _encryptionKeyKey);
    if (key == null || key.isEmpty) {
      key = _generateSecureKey();
      await _storage.write(key: _encryptionKeyKey, value: key);
    }
    return key;
  }

  // 清除所有数据
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // 工具方法
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String _generateSecureKey() {
    final bytes = utf8.encode('personal_password_manager_${DateTime.now().millisecondsSinceEpoch}');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 加密数据
  static String encryptData(String data, String key) {
    // 这里使用简单的XOR加密，实际应用中应该使用更强的加密算法
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encryptedBytes = <int>[];

    for (int i = 0; i < dataBytes.length; i++) {
      encryptedBytes.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encryptedBytes);
  }

  // 解密数据
  static String decryptData(String encryptedData, String key) {
    final encryptedBytes = base64.decode(encryptedData);
    final keyBytes = utf8.encode(key);
    final decryptedBytes = <int>[];

    for (int i = 0; i < encryptedBytes.length; i++) {
      decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decryptedBytes);
  }
}

enum AuthType {
  none,
  password,
  pattern,
  biometric,
}