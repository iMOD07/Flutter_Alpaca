import 'package:flutter/material.dart';
import 'package:flutter_alpaca/ui/alpaca_account_view.dart';
import 'package:flutter_alpaca/ui/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env (locally during development)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // ignore if .env not found
  }

  // Load API keys
  const String defaultKeyId = String.fromEnvironment(
    'ALPACA_KEY_ID',
    defaultValue: 'REPLACE_ME',
  );
  const String defaultSecret = String.fromEnvironment(
    'ALPACA_SECRET',
    defaultValue: 'REPLACE_ME',
  );
  const String defaultBaseUrl = String.fromEnvironment(
    'ALPACA_BASE_URL',
    defaultValue: 'https://paper-api.alpaca.markets/v2',
  );

  final String kAlpacaKeyId = dotenv.env['ALPACA_KEY_ID'] ?? defaultKeyId;
  final String kAlpacaSecret = dotenv.env['ALPACA_SECRET'] ?? defaultSecret;
  final String kAlpacaBaseUrl = dotenv.env['ALPACA_BASE_URL'] ?? defaultBaseUrl;

  // Load App Password
  final String appPassword = dotenv.env['APP_PASSWORD'] ?? "1234";

  runApp(
    MyApp(
      keyId: kAlpacaKeyId,
      secret: kAlpacaSecret,
      baseUrl: kAlpacaBaseUrl,
      appPassword: appPassword,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String keyId;
  final String secret;
  final String baseUrl;
  final String appPassword;

  const MyApp({
    super.key,
    required this.keyId,
    required this.secret,
    required this.baseUrl,
    required this.appPassword,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpaca Account',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(
        keyId: keyId,
        secret: secret,
        baseUrl: baseUrl,
        appPassword: appPassword,
      ),

      // home: AlpacaAccountView(keyId: keyId, secret: secret, baseUrl: baseUrl),
    );
  }
}
