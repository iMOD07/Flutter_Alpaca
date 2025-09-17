import 'package:flutter/material.dart';
import 'package:flutter_alpaca/ui/clock_market_status.dart';
import 'alpaca_account_view.dart';
// ignore: duplicate_import
import 'clock_market_status.dart';
import 'package:flutter_alpaca/models/AlpacaCreds.dart';

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
              Navigator.pop(context); // أغلق الدروار
              if (isOnAccount) return; // أنت فيها بالفعل
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
            title: const Text('Market Clock'),
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
        ],
      ),
    );
  }
}
