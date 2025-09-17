import 'package:flutter/material.dart';
import '../models/alpaca_creds.dart';
import 'app_drawer.dart';

class ClockMarketStatus extends StatelessWidget {
  const ClockMarketStatus({super.key, required this.creds});
  final AlpacaCreds creds;

  static const kPrimary = Color(0xFF5A72A0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock and Market Status'),
        centerTitle: true,
        backgroundColor: kPrimary,
      ),
      drawer: AppDrawer(creds: creds, isOnClock: true),
      body: const Center(
        child: Text("ClockMarketStatus Page", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
