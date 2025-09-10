import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
//import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
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
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final content = await rootBundle.loadString('assets/save_user.txt');
      final lines = content.split('\n');
      if (lines.length >= 2) {
        controllerEmail.text = lines[0].trim();
        controllerPassword.text = lines[1].trim();
      }
    } catch (e) {
      // Si hay error, deja los campos vacíos
    }
    setState(() {});
  }

  Future<void> _saveCredentialsToFile(String email, String password) async {
    final file = File('save_user.txt');
    await file.writeAsString('$email\n$password');
  }

  Future<bool> _login(theEmail, thePassword) async {
    logInfo('_login $theEmail $thePassword');
    try {
      final result = await authenticationController.login(
        theEmail,
        thePassword,
      );
      if (result && _saveCredentials) {
        await _saveCredentialsToFile(theEmail, thePassword);
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
                  CheckboxListTile(
                    title: const Text("Recordar usuario y contraseña"),
                    value: _saveCredentials,
                    onChanged: (value) {
                      setState(() {
                        _saveCredentials = value ?? false;
                      });
                    },
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
