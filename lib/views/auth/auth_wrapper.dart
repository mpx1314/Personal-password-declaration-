import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../auth/auth_setup_screen.dart';
import '../auth/biometric_auth_screen.dart';
import '../auth/password_auth_screen.dart';
import '../auth/pattern_auth_screen.dart';
import '../home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 如果用户未认证
        if (!authController.isAuthenticated) {
          // 需要设置认证
          if (authController.needsAuthSetup()) {
            return const AuthSetupScreen();
          }

          // 根据认证类型显示不同的认证界面
          switch (authController.currentAuthType) {
            case AuthType.password:
              return const PasswordAuthScreen();
            case AuthType.pattern:
              return const PatternAuthScreen();
            case AuthType.biometric:
              return const BiometricAuthScreen();
            default:
              return const AuthSetupScreen();
          }
        }

        // 用户已认证，显示主界面
        return const HomeScreen();
      },
    );
  }
}