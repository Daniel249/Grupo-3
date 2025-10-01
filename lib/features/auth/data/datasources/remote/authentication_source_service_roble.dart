import 'dart:convert';

//import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;
//import 'package:axios/axios.dart' as axios;

//import '../../../../../core/i_local_preferences.dart';
import '../../../domain/models/authentication_user.dart';
import 'i_authentication_source.dart';

class AuthenticationSourceServiceRoble implements IAuthenticationSource {
  final http.Client httpClient;
  String token = '';
  String refreshtoken = '';
  // daniel's       'https://roble-api.openlab.uninorte.edu.co/auth/movil_grupo_3_27b270426b';
  // roble's        'https://roble-api.openlab.uninorte.edu.co/auth/grupo3_e9c5902986'
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/grupo_4_2532247339';

  AuthenticationSourceServiceRoble({http.Client? client})
    : httpClient = client ?? http.Client();

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
      token = data['accessToken'];
      refreshtoken = data['refreshToken'];
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
    if (token == '') {
      logError("No token found, cannot log out.");
      return Future.error('No token found');
    }

    final response = await httpClient.post(
      Uri.parse("$baseUrl/logout"),
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      token = '';
      refreshtoken = '';
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
    if (refreshtoken == '') {
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
      token = newToken;
      logInfo("Token refreshed successfully");
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "refreshToken endpoint got error code ${response.statusCode} $errorMessage for refreshToken: $refreshToken",
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
    if (token == '') {
      logError("No token found, cannot verify.");
      return Future.value(false);
    }
    //logInfo("Verifying token: $token");
    final response = await httpClient.get(
      Uri.parse("$baseUrl/verify-token"),
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );
    logInfo(response.statusCode);
    if (response.statusCode == 200) {
      logInfo("Token is valid");
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "verifyToken endpoint got error code ${response.statusCode} $errorMessage for token: $token",
      );
      return Future.value(false);
    }
  }
}
