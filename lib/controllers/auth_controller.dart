import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../services/secure_storage_service.dart';

class AuthController with ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  AuthType _currentAuthType = AuthType.none;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthType get currentAuthType => _currentAuthType;

  // 初始化认证状态
  Future<void> init() async {
    await _loadAuthType();
    await _checkAuthenticationStatus();
  }

  // 加载认证类型
  Future<void> _loadAuthType() async {
    try {
      _currentAuthType = await SecureStorageService.getAuthType();
      notifyListeners();
    } catch (e) {
      debugPrint('加载认证类型失败: $e');
    }
  }

  // 检查认证状态
  Future<void> _checkAuthenticationStatus() async {
    if (_currentAuthType == AuthType.none) {
      _isAuthenticated = true;
      notifyListeners();
      return;
    }

    // 对于其他认证类型，用户需要手动认证
    _isAuthenticated = false;
    notifyListeners();
  }

  // 设置认证类型
  Future<bool> setAuthType(AuthType type) async {
    try {
      await SecureStorageService.setAuthType(type);
      _currentAuthType = type;

      if (type == AuthType.none) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('设置认证类型失败: $e');
      return false;
    }
  }

  // 设置主密码
  Future<bool> setMasterPassword(String password) async {
    try {
      if (password.length < 4) {
        _setError('密码长度至少为4位');
        return false;
      }

      await SecureStorageService.setMasterPassword(password);
      await setAuthType(AuthType.password);
      _clearError();
      return true;
    } catch (e) {
      _setError('设置主密码失败: $e');
      return false;
    }
  }

  // 验证主密码
  Future<bool> verifyMasterPassword(String password) async {
    try {
      _setLoading(true);
      _clearError();

      final isValid = await SecureStorageService.verifyMasterPassword(password);

      if (isValid) {
        _isAuthenticated = true;
        notifyListeners();
      } else {
        _setError('密码错误');
      }

      return isValid;
    } catch (e) {
      _setError('验证密码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 设置手势密码
  Future<bool> setPattern(String pattern) async {
    try {
      if (pattern.length < 4) {
        _setError('手势密码至少连接4个点');
        return false;
      }

      await SecureStorageService.setPattern(pattern);
      await setAuthType(AuthType.pattern);
      _clearError();
      return true;
    } catch (e) {
      _setError('设置手势密码失败: $e');
      return false;
    }
  }

  // 验证手势密码
  Future<bool> verifyPattern(String pattern) async {
    try {
      _setLoading(true);
      _clearError();

      final isValid = await SecureStorageService.verifyPattern(pattern);

      if (isValid) {
        _isAuthenticated = true;
        notifyListeners();
      } else {
        _setError('手势密码错误');
      }

      return isValid;
    } catch (e) {
      _setError('验证手势密码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 检查生物识别支持
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      debugPrint('检查生物识别支持失败: $e');
      return false;
    }
  }

  // 启用生物识别
  Future<bool> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        _setError('设备不支持生物识别');
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: '请验证生物识别以启用',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await SecureStorageService.setBiometricEnabled(true);
        await setAuthType(AuthType.biometric);
        _isAuthenticated = true;
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError('生物识别验证失败');
        return false;
      }
    } catch (e) {
      _setError('启用生物识别失败: $e');
      return false;
    }
  }

  // 生物识别认证
  Future<bool> authenticateWithBiometric() async {
    try {
      _setLoading(true);
      _clearError();

      final isBiometricEnabled = await SecureStorageService.isBiometricEnabled();
      if (!isBiometricEnabled) {
        _setError('生物识别未启用');
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: '请验证生物识别以登录',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _isAuthenticated = true;
        notifyListeners();
      } else {
        _setError('生物识别验证失败');
      }

      return authenticated;
    } catch (e) {
      _setError('生物识别认证失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 登出
  Future<void> logout() async {
    _isAuthenticated = false;
    _clearError();
    notifyListeners();
  }

  // 检查是否需要设置认证
  bool needsAuthSetup() {
    return _currentAuthType == AuthType.none;
  }

  // 清除所有认证数据
  Future<bool> clearAllAuthData() async {
    try {
      await SecureStorageService.clearAll();
      _currentAuthType = AuthType.none;
      _isAuthenticated = true; // 无认证模式
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('清除认证数据失败: $e');
      return false;
    }
  }

  // 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('获取生物识别类型失败: $e');
      return [];
    }
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}