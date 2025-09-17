import 'package:flutter/material.dart';
import 'package:flutter_alpaca/ui/alpaca_account_view.dart';

class LoginScreen extends StatefulWidget {
  final String keyId;
  final String secret;
  final String baseUrl;
  final String appPassword;

  const LoginScreen({
    super.key,
    required this.keyId,
    required this.secret,
    required this.baseUrl,
    required this.appPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() {
    if (_passwordController.text == widget.appPassword) {
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
        _errorMessage = "The password is incorrect, Please try again";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFF),
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: Color(0xFFF1F1F1),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Container(
                height: 350,
                width: 500,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://res.cloudinary.com/drzpjbr87/image/upload/v1758097853/logo-1_elfffc.png",
                      height: 125,
                    ),
                    Text(
                      "Welcome back",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(223, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Enter your password to access and track your account.\n"
                      "We never store your password. Your access is verified securely.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text("Login"),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "© 2025 Mohammed SH. All rights reserved.",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
