// ignore: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../api/alpaca_api.dart';

// Activates mouse/trackpad dragging on the web
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class AlpacaAccountView extends StatefulWidget {
  final String keyId;
  final String secret;
  final String baseUrl;

  const AlpacaAccountView({
    super.key,
    required this.keyId,
    required this.secret,
    this.baseUrl = 'https://paper-api.alpaca.markets/v2',
  });

  @override
  State<AlpacaAccountView> createState() => _AlpacaAccountViewState();
}

class _AlpacaAccountViewState extends State<AlpacaAccountView> {
  late Future<Map<String, dynamic>> _future;
  late AlpacaApi _api;

  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    _api = AlpacaApi(
      baseUrl: widget.baseUrl,
      keyId: widget.keyId,
      secret: widget.secret,
    );
    _future = _api.getAccount();
  }

  String _s(Map<String, dynamic> m, String k) => m[k]?.toString() ?? '-';

  String _mask(String v) {
    final t = v.trim();
    if (t.isEmpty) return '(empty)';
    if (t.length <= 6) return '*** (${t.length})';
    return '${t.substring(0, 3)}***${t.substring(t.length - 3)} (${t.length})';
  }

  // Pull/Update without any await inside setState (Important)
  Future<void> _handlePullToRefresh() async {
    print('🔄 Refresh started: calling getAccount()');

    final f = _api.getAccount(); // 1 Start the request
    if (mounted) {
      setState(() {
        _future = f; // 2 Synchronize the FutureBuilder event
      });
    }

    try {
      final result = await f; // 3 Wait for the same Future outside setState
      print('✅ getAccount() finished: $result');

      if (!mounted) return;
      setState(() {
        _lastRefresh = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Refresh failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      // Important for the web
      behavior: AppScrollBehavior(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Debug panel (safe; masked)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.04),
                  ),
                  child: Text(
                    'DEBUG — baseUrl:\n${widget.baseUrl}\n'
                    'keyId: ${_mask(widget.keyId)}\n'
                    'secret: ${_mask(widget.secret)}\n'
                    '${_lastRefresh != null ? 'Last refresh:\n'
                              'Date: ${_lastRefresh.toString().split(' ').first}\n'
                              'Time: ${_lastRefresh.toString().split(' ').last.split('.').first}' : ''}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    final msg = snap.error.toString();
                    return SingleChildScrollView(
                      child: Text(
                        'Error: ${msg.length > 500 ? msg.substring(0, 500) + '…' : msg}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final data = snap.data!;
                  final id = _s(data, 'id');
                  final accountNumber = _s(data, 'account_number');
                  final status = _s(data, 'status');
                  final cryptoStatus = _s(data, 'crypto_status');
                  final currency = _s(data, 'currency');
                  final optionsApprovedLevel = _s(
                    data,
                    'options_approved_level',
                  );
                  final optionsTradingLevel = _s(data, 'options_trading_level');
                  final buyingPower = _s(data, 'buying_power');
                  final regtBuyingPower = _s(data, 'regt_buying_power');
                  final daytradingBuyingPower = _s(
                    data,
                    'daytrading_buying_power',
                  );
                  final effectiveBuyingPower = _s(
                    data,
                    'effective_buying_power',
                  );
                  final nonMarginableBuyingPower = _s(
                    data,
                    'non_marginable_buying_power',
                  );
                  final optionsBuyingPower = _s(data, 'options_buying_power');
                  final bodDtbp = _s(data, 'bod_dtbp');
                  final cash = _s(data, 'cash');
                  final portfolioValue = _s(data, 'portfolio_value');
                  final equity = _s(data, 'equity');
                  final lastEquity = _s(data, 'last_equity');
                  final sma = _s(data, 'sma');
                  final longMarketValue = _s(data, 'long_market_value');
                  final shortMarketValue = _s(data, 'short_market_value');
                  final positionMarketValue = _s(data, 'position_market_value');
                  final initialMargin = _s(data, 'initial_margin');
                  final maintenanceMargin = _s(data, 'maintenance_margin');
                  final lastMaintenanceMargin = _s(
                    data,
                    'last_maintenance_margin',
                  );
                  final patternDayTrader = _s(data, 'pattern_day_trader');
                  final tradingBlocked = _s(data, 'trading_blocked');
                  final transfersBlocked = _s(data, 'transfers_blocked');
                  final accountBlocked = _s(data, 'account_blocked');
                  final tradeSuspendedByUser = _s(
                    data,
                    'trade_suspended_by_user',
                  );
                  final createdAt = _s(data, 'created_at');
                  final multiplier = _s(data, 'multiplier');
                  final shortingEnabled = _s(data, 'shorting_enabled');
                  final daytradeCount = _s(data, 'daytrade_count');
                  final balanceAsOf = _s(data, 'balance_asof');
                  final cryptoTier = _s(data, 'crypto_tier');
                  final accruedFees = _s(data, 'accrued_fees');
                  final intradayAdjustments = _s(data, 'intraday_adjustments');
                  final pendingRegTafFees = _s(data, 'pending_reg_taf_fees');

                  return RefreshIndicator(
                    key: _refreshKey,
                    onRefresh: _handlePullToRefresh,
                    child: ListView(
                      primary: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: $id'),
                                Text('Account Number: $accountNumber'),
                                Text('Status: $status'),
                                Text('Crypto Status: $cryptoStatus'),
                                Text('Currency: $currency'),
                                Text(
                                  'Options Approved Level: $optionsApprovedLevel',
                                ),
                                Text(
                                  'Options Trading Level: $optionsTradingLevel',
                                ),
                                Text('Buying Power: $buyingPower'),
                                Text('RegT Buying Power: $regtBuyingPower'),
                                Text(
                                  'Daytrading Buying Power: $daytradingBuyingPower',
                                ),
                                Text(
                                  'Effective Buying Power: $effectiveBuyingPower',
                                ),
                                Text(
                                  'Non-Marginable Buying Power: $nonMarginableBuyingPower',
                                ),
                                Text(
                                  'Options Buying Power: $optionsBuyingPower',
                                ),
                                Text('BOD DTBP: $bodDtbp'),
                                Text('Cash: $cash'),
                                Text('Accrued Fees: $accruedFees'),
                                Text('Portfolio Value: $portfolioValue'),
                                Text('Pattern Day Trader: $patternDayTrader'),
                                Text('Trading Blocked: $tradingBlocked'),
                                Text('Transfers Blocked: $transfersBlocked'),
                                Text('Account Blocked: $accountBlocked'),
                                Text('Created At: $createdAt'),
                                Text(
                                  'Trade Suspended By User: $tradeSuspendedByUser',
                                ),
                                Text('Multiplier: $multiplier'),
                                Text('Shorting Enabled: $shortingEnabled'),
                                Text('Equity: $equity'),
                                Text('Last Equity: $lastEquity'),
                                Text('Long Market Value: $longMarketValue'),
                                Text('Short Market Value: $shortMarketValue'),
                                Text(
                                  'Position Market Value: $positionMarketValue',
                                ),
                                Text('Initial Margin: $initialMargin'),
                                Text('Maintenance Margin: $maintenanceMargin'),
                                Text(
                                  'Last Maintenance Margin: $lastMaintenanceMargin',
                                ),
                                Text('SMA: $sma'),
                                Text('Daytrade Count: $daytradeCount'),
                                Text('Balance As Of: $balanceAsOf'),
                                Text('Crypto Tier: $cryptoTier'),
                                Text(
                                  'Intraday Adjustments: $intradayAdjustments',
                                ),
                                Text(
                                  'Pending Reg TAF Fees: $pendingRegTafFees',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            /* Button (optional) to enable programmatic web drag
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _refreshKey.currentState
                        ?.show(); // Shows the cursor and calls onRefresh
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ), */
          ],
        ),
      ),
    );
  }
}
