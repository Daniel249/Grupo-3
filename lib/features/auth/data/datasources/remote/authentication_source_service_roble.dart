import 'dart:convert';

//import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;
//import 'package:axios/axios.dart' as axios;
import 'package:shared_preferences/shared_preferences.dart';
//import '../../../../../core/i_local_preferences.dart';
import '../../../domain/models/authentication_user.dart';
import 'i_authentication_source.dart';

class AuthenticationSourceServiceRoble implements IAuthenticationSource {
  final http.Client httpClient;
  // daniel's       'https://roble-api.openlab.uninorte.edu.co/auth/movil_grupo_3_27b270426b';
  // roble's        'https://roble-api.openlab.uninorte.edu.co/auth/grupo3_e9c5902986'
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/grupo3_e9c5902986';

  AuthenticationSourceServiceRoble({http.Client? client})
    : httpClient = client ?? http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> _saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  @override
  Future<bool> login(AuthenticationUser user) async {
    String email = user.email;
    String password = user.password;
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"email": email, "password": password}),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      logInfo(response.body);
      final data = jsonDecode(response.body);
      final token = data['accessToken'];
      final refreshtoken = data['refreshToken'];

      // Save tokens to SharedPreferences
      await _saveTokens(token, refreshtoken);

      logInfo(
        "Token: $token"
        "\nRefresh Token: $refreshtoken",
      );
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError(
        "Login endpoint got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error('Error $errorMessage');
    }
  }

  @override
  Future<bool> signUp(AuthenticationUser user) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup-direct"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": user.name,
        "name": user.name,
        "password": user.password,
      }),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      logInfo(response.body);
      final data = jsonDecode(response.body);
      final token = data['accessToken'];
      final refreshtoken = data['refreshToken'];

      // Save tokens to SharedPreferences
      await _saveTokens(token, refreshtoken);

      logInfo(
        "SignUp successful - Token: $token"
        "\nRefresh Token: $refreshtoken",
      );
      return Future.value(true);
    } else {
      logError(response.body);
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError(
        "signUp endpoint got error code ${response.statusCode} - $errorMessage",
      );
      return Future.error('Error $errorMessage');
    }
  }

  @override
  Future<bool> logOut() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      logError("No token found, cannot log out.");
      return Future.error('No token found');
    }

    final response = await httpClient.post(
      Uri.parse("$baseUrl/logout"),
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      // Clear tokens from SharedPreferences
      await _clearTokens();
      logInfo("Logged out successfully");
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "logout endpoint got error code ${response.statusCode} $errorMessage for token: $token",
      );
      return Future.error('Error code $errorMessage');
    }
  }

  @override
  Future<bool> validate(String email, String validationCode) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/verify-email"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": email, // Assuming validationCode is the email
        "code": validationCode,
      }),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "verifyEmail endpoint got error code ${response.statusCode} $errorMessage for email: $email",
      );
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> refreshToken() async {
    final refreshtoken = await _getRefreshToken();
    if (refreshtoken == null || refreshtoken.isEmpty) {
      logError("No refresh token found, cannot refresh.");
      return Future.error('No refresh token found');
    }

    final response = await http.post(
      Uri.parse("$baseUrl/refresh-token"),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'refreshToken': refreshtoken}),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final newToken = data['accessToken'];

      // Save new token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', newToken);

      logInfo("Token refreshed successfully");
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "refreshToken endpoint got error code ${response.statusCode} $errorMessage for refreshToken: $refreshtoken",
      );
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/forgot-password"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"email": email}),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "forgotPassword endpoint got error code ${response.statusCode} $errorMessage for email: $email",
      );
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  ) async {
    return Future.value(true);
  }

  @override
  Future<bool> verifyToken() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      logError("No token found, cannot verify.");
      return Future.value(false);
    }

    // First, try to verify the current token
    final response = await httpClient.get(
      Uri.parse("$baseUrl/verify-token"),
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );

    logInfo(response.statusCode);
    if (response.statusCode == 200) {
      logInfo("Token is valid");
      return Future.value(true);
    } else {
      logInfo("Token verification failed, attempting to refresh token");

      // Token verification failed, try to refresh using baseUrl
      final refreshtoken = await _getRefreshToken();
      if (refreshtoken == null || refreshtoken.isEmpty) {
        logError("No refresh token found, cannot refresh.");
        return Future.value(false);
      }

      final refreshResponse = await http.post(
        Uri.parse("$baseUrl/refresh-token"),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshtoken}),
      );

      logInfo(refreshResponse.statusCode);
      if (refreshResponse.statusCode == 201) {
        final data = jsonDecode(refreshResponse.body);
        final newToken = data['accessToken'];

        // Save new token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', newToken);

        logInfo("Token refreshed successfully, verification passed");
        return Future.value(true);
      } else {
        final Map<String, dynamic> errorBody = json.decode(
          refreshResponse.body,
        );
        final String errorMessage = errorBody['message'];
        logError(
          "Token refresh failed with error code ${refreshResponse.statusCode}: $errorMessage",
        );
        return Future.value(false);
      }
    }
  }
}
