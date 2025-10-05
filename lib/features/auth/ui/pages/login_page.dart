import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/authentication_controller.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  AuthenticationController authenticationController = Get.find();

  bool _saveCredentials = false;

  @override
  void initState() {
    super.initState();
    _checkTokenAndLoadCredentials();
  }

  Future<void> _checkTokenAndLoadCredentials() async {
    try {
      // First verify token
      final tokenValid = await authenticationController.verifyToken();
      if (tokenValid) {
        // If token is valid, check for saved email
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('user_email');
        if (savedEmail != null && savedEmail.isNotEmpty) {
          // Token is valid and email exists, return the email
          Navigator.of(context).pop(savedEmail);
          return;
        }
      }
    } catch (e) {
      logError('Token verification failed: $e');
    }

    // If token verification fails or no email found, load saved credentials for manual login
    await _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email') ?? '';
      final savedPassword = prefs.getString('saved_password') ?? '';
      controllerEmail.text = savedEmail;
      controllerPassword.text = savedPassword;
      _saveCredentials = savedEmail.isNotEmpty && savedPassword.isNotEmpty;
    } catch (e) {
      controllerEmail.text = '';
      controllerPassword.text = '';
    }
    setState(() {});
  }

  Future<void> _saveCredentialsToPrefs(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
  }

  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }

  Future<void> _saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<bool> _login(theEmail, thePassword) async {
    logInfo('_login $theEmail $thePassword');
    try {
      final result = await authenticationController.login(
        theEmail,
        thePassword,
      );
      if (result) {
        // Save user email before returning
        await _saveUserEmail(theEmail);

        if (_saveCredentials) {
          await _saveCredentialsToPrefs(theEmail, thePassword);
        } else {
          await _clearSavedCredentials();
        }
      }
      return result;
    } catch (err) {
      Get.snackbar(
        "Login",
        err.toString(),
        icon: const Icon(Icons.person, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login to access your account",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: controllerEmail,
                    decoration: const InputDecoration(
                      labelText: "Email address",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return "Enter email";
                      } else if (!value.contains('@')) {
                        return "Enter valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controllerPassword,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    obscureText: true,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return "Enter password";
                      } else if (value.length < 6) {
                        return "Password should have at least 6 characters";
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final form = _formKey.currentState;
                      form!.save();
                      if (_formKey.currentState!.validate()) {
                        final success = await _login(
                          controllerEmail.text,
                          controllerPassword.text,
                        );
                        if (success) {
                          Navigator.of(context).pop(controllerEmail.text);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _saveCredentials,
                        onChanged: (value) {
                          setState(() {
                            _saveCredentials = value ?? false;
                          });
                        },
                      ),
                      const Text("Recordar usuario y contraseña"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            final form = _formKey.currentState;
                            form!.save();
                            if (_formKey.currentState!.validate()) {
                              final success = await _login(
                                controllerEmail.text,
                                controllerPassword.text,
                              );
                              if (success) {
                                Navigator.of(context).pop(controllerEmail.text);
                              }
                            }
                          },
                          child: const Text("Login"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text("Create account"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
