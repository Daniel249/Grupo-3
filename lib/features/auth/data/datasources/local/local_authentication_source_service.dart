import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import '../../../domain/models/authentication_user.dart';
import '../remote/i_authentication_source.dart';

class LocalAuthenticationSourceService implements IAuthenticationSource {
  final String assetPath;

  LocalAuthenticationSourceService({this.assetPath = 'auth_users.txt'});

  Future<Map<String, String>> _loadUsers() async {
    final data = await rootBundle.loadString(assetPath);
    final lines = data.split('\n');
    final Map<String, String> users = {};
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final parts = trimmed.split('|');
      if (parts.length == 2) {
        final email = parts[0].trim();
        final password = parts[1].trim();
        users[email] = password;
      }
    }
    return users;
  }

  @override
  Future<bool> login(AuthenticationUser user) async {
    final users = await _loadUsers();
    if (users.containsKey(user.email) && users[user.email] == user.password) {
      return true;
    }
    return Future.error('Login failed');
  }

  @override
  Future<bool> signUp(AuthenticationUser user) async {
    // No soportado en local
    return Future.error('Sign up not supported in local source');
  }

  @override
  Future<bool> logOut() async => true;

  @override
  Future<bool> validate(String email, String validationCode) async => true;

  @override
  Future<bool> refreshToken() async => true;

  @override
  Future<bool> forgotPassword(String email) async => true;

  @override
  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  ) async => true;

  @override
  Future<bool> verifyToken() async => true;
}
