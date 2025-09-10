//import 'package:f_clean_template/features/product/ui/pages/list_product_page.dart';
import 'package:f_clean_template/features/product/ui/pages/see_courses_page.dart';
import 'package:flutter/material.dart';
import 'features/product/domain/models/user.dart';
import 'features/auth/ui/pages/login_page.dart';

class Central extends StatefulWidget {
  const Central({super.key});

  @override
  State<Central> createState() => _CentralState();
}

class _CentralState extends State<Central> {
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final email = await Navigator.of(
        context,
      ).push<String>(MaterialPageRoute(builder: (_) => const LoginPage()));
      if (email != null) {
        setState(() {
          _userEmail = email;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userEmail != null) {
      final name = _userEmail!.split('@').first;
      final user = User(name: name, id: _userEmail!);
      return ListCoursePage(user: user);
    } else {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
