import 'package:flutter/material.dart';
import 'package:flutter_alpaca/ui/login_screen.dart';
import '../models/alpaca_creds.dart';
import 'alpaca_account_view.dart';
import 'clock_market_status.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.creds,
    this.isOnAccount = false,
    this.isOnClock = false,
  });

  final AlpacaCreds creds;
  final bool isOnAccount;
  final bool isOnClock;

  static const kPrimary = Color(0xFF5A72A0);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: kPrimary),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Alpaca Account'),
            onTap: () {
              Navigator.pop(context);
              if (isOnAccount) return; // You are here

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => AlpacaAccountView(
                    keyId: creds.keyId,
                    secret: creds.secret,
                    baseUrl: creds.baseUrl,
                  ),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text("Market Clock"),
            onTap: () {
              Navigator.pop(context);
              if (isOnClock) return;

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ClockMarketStatus(creds: creds),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              "Log out",
              style: TextStyle(color: Color.fromARGB(255, 240, 0, 0)),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context); // Close Drawer
                Navigator.pushAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const LoginScreen(),
                    transitionsBuilder: (_, a, __, child) =>
                        FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
