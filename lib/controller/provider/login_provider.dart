import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_service.dart';

class LoginProv with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  disposeController() {
    emailController.clear();
    passwordController.clear();
  }

  onSignInButtonPress(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      showSnakBar('Enter All Fields');
      return ;
    }
    final msg = await context.read<AuthService>().signIn(email, password);
    disposeController();

    if (msg == '') {
      return;
    }
    showSnakBar(msg);

  }

  showSnakBar(String msg) {
    ScaffoldMessenger.of(scaffoldKey.currentContext!).hideCurrentSnackBar();
    ScaffoldMessenger.of(scaffoldKey.currentContext!)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
