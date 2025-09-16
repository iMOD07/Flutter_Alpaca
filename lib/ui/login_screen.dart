import 'package:flutter/material.dart';
import 'package:flutter_alpaca/ui/alpaca_account_view.dart';

class LoginScreen extends StatefulWidget {
  final String keyId;
  final String secret;
  final String baseUrl;

  const LoginScreen({
    super.key,
    required this.keyId,
    required this.secret,
    required this.baseUrl,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() {
    const correctPassword = "1234"; // غيرها باللي تبغاه

    if (_passwordController.text == correctPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AlpacaAccountView(
            keyId: widget.keyId,
            secret: widget.secret,
            baseUrl: widget.baseUrl,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = "الباسورد غير صحيح!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "ادخل الباسورد",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("دخول")),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
