import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/logincontroller.dart';
import '../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = context.watch<LoginController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: loginController.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                child: const Text('Login'),
                onPressed: () async {
                  loginController.setEmail("admin@gmail.com");
                  loginController.setPassword("123456");
                  final success = await loginController.login();
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MyHomePage(title: 'Home Page'),
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}
