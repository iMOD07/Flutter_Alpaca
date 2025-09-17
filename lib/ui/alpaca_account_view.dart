// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../api/alpaca_api.dart';

// ================= Setting up scroll behavior for the web =================
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

// ================= Home Page =================
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

  static const kPrimary = Color(0xFF5A72A0);

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

  // Pull-to-refresh (المهم: لا await داخل setState)
  Future<void> _handlePullToRefresh() async {
    print('🔄 Refresh started: calling getAccount()');
    final f = _api.getAccount();
    if (mounted) {
      setState(() {
        _future = f;
      });
    }
    try {
      final result = await f;
      print('✅ getAccount() finished: $result');
      if (!mounted) return;
      setState(() => _lastRefresh = DateTime.now());
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
      behavior: AppScrollBehavior(),
      child: LayoutBuilder(
        builder: (context, cons) {
          final w = cons.maxWidth;
          final isMobile = w < 600;
          final isTablet = w >= 600 && w < 1024;
          final cols = isMobile ? 1 : (isTablet ? 2 : 3);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Alpaca Account'),
              centerTitle: true,
              backgroundColor: kPrimary,
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DebugBadge(
                        baseUrl: widget.baseUrl,
                        keyIdMasked: _mask(widget.keyId),
                        secretMasked: _mask(widget.secret),
                        lastRefresh: _lastRefresh,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: _future,
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snap.hasError) {
                              final msg = snap.error.toString();
                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SelectableText(
                                    'Error: ${msg.length > 600 ? msg.substring(0, 600) + '…' : msg}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            }

                            final data = snap.data!;
                            String g(String k) => _s(data, k);

                            final metrics = <_Metric>[
                              _Metric('Portfolio Value', g('portfolio_value')),
                              _Metric('Equity', g('equity')),
                              _Metric('Cash', g('cash')),
                              _Metric('Buying Power', g('buying_power')),
                              _Metric('RegT BP', g('regt_buying_power')),
                              _Metric('SMA', g('sma')),
                            ];

                            final flags = <_Flag>[
                              _Flag(
                                'Pattern Day Trader',
                                g('pattern_day_trader') == 'true',
                              ),
                              _Flag(
                                'Trading Blocked',
                                g('trading_blocked') == 'true',
                              ),
                              _Flag(
                                'Transfers Blocked',
                                g('transfers_blocked') == 'true',
                              ),
                              _Flag(
                                'Account Blocked',
                                g('account_blocked') == 'true',
                              ),
                              _Flag(
                                'Shorting Enabled',
                                g('shorting_enabled') == 'true',
                              ),
                              _Flag('Crypto Tier ${g('crypto_tier')}', true),
                            ];

                            return RefreshIndicator(
                              key: _refreshKey,
                              onRefresh: _handlePullToRefresh,
                              child: CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: _SectionCard(
                                      title: 'Summary',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _InfoRow(
                                            'Account #',
                                            g('account_number'),
                                          ),
                                          _InfoRow(
                                            'Status',
                                            '${g('status')} / ${g('crypto_status')}',
                                          ),
                                          _InfoRow('Currency', g('currency')),
                                          _InfoRow(
                                            'Created At',
                                            g('created_at'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 12),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _SectionTitle('Key Metrics'),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8,
                                      left: 2,
                                      right: 2,
                                    ),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: cols,
                                            mainAxisSpacing: 8,
                                            crossAxisSpacing: 8,
                                            childAspectRatio: isMobile
                                                ? 2.6
                                                : 2.8,
                                          ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, i) =>
                                            _MetricCard(m: metrics[i]),
                                        childCount: metrics.length,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _SectionTitle('Flags'),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _SectionCard(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: flags
                                            .map((f) => _FlagChip(flag: f))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _SectionTitle('Details'),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _SectionCard(
                                      child: _DetailsGrid(
                                        cols: cols,
                                        items: [
                                          _InfoRow.kv(
                                            'Options Approved Level',
                                            g('options_approved_level'),
                                          ),
                                          _InfoRow.kv(
                                            'Options Trading Level',
                                            g('options_trading_level'),
                                          ),
                                          _InfoRow.kv(
                                            'Effective BP',
                                            g('effective_buying_power'),
                                          ),
                                          _InfoRow.kv(
                                            'Non-Marginable BP',
                                            g('non_marginable_buying_power'),
                                          ),
                                          _InfoRow.kv(
                                            'Options BP',
                                            g('options_buying_power'),
                                          ),
                                          _InfoRow.kv(
                                            'BOD DTBP',
                                            g('bod_dtbp'),
                                          ),
                                          _InfoRow.kv(
                                            'Long Mkt Value',
                                            g('long_market_value'),
                                          ),
                                          _InfoRow.kv(
                                            'Short Mkt Value',
                                            g('short_market_value'),
                                          ),
                                          _InfoRow.kv(
                                            'Position Mkt Value',
                                            g('position_market_value'),
                                          ),
                                          _InfoRow.kv(
                                            'Initial Margin',
                                            g('initial_margin'),
                                          ),
                                          _InfoRow.kv(
                                            'Maintenance Margin',
                                            g('maintenance_margin'),
                                          ),
                                          _InfoRow.kv(
                                            'Last Maint. Margin',
                                            g('last_maintenance_margin'),
                                          ),
                                          _InfoRow.kv(
                                            'Daytrade Count',
                                            g('daytrade_count'),
                                          ),
                                          _InfoRow.kv(
                                            'Balance As Of',
                                            g('balance_asof'),
                                          ),
                                          _InfoRow.kv(
                                            'Accrued Fees',
                                            g('accrued_fees'),
                                          ),
                                          _InfoRow.kv(
                                            'Intraday Adjustments',
                                            g('intraday_adjustments'),
                                          ),
                                          _InfoRow.kv(
                                            'Pending Reg TAF Fees',
                                            g('pending_reg_taf_fees'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _SectionCard(
                                      title: 'All fields (JSON)',
                                      margin: const EdgeInsets.only(
                                        top: 12,
                                        bottom: 24,
                                      ),
                                      child: ExpansionTile(
                                        title: const Text('Show raw JSON'),
                                        children: [
                                          SelectableText(
                                            const JsonEncoder.withIndent(
                                              '  ',
                                            ).convert(data),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 24),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Additional Refresh button suitable for web/desktop
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                            ),
                            onPressed: () => _refreshKey.currentState?.show(),
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Refresh',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= Help widgets =================

class _DebugBadge extends StatelessWidget {
  final String baseUrl, keyIdMasked, secretMasked;
  final DateTime? lastRefresh;
  const _DebugBadge({
    required this.baseUrl,
    required this.keyIdMasked,
    required this.secretMasked,
    this.lastRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final ts = lastRefresh != null
        ? 'Last refresh:\nDate: ${lastRefresh!.toString().split(' ').first}\n'
              'Time: ${lastRefresh!.toString().split(' ').last.split('.').first}'
        : 'Last refresh: —';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SelectableText(
        'DEBUG — baseUrl:\n$baseUrl\nkeyId: $keyIdMasked\nsecret: $secretMasked\n$ts',
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: _AlpacaAccountViewState.kPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  const _SectionCard({this.title, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      elevation: 0.8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _Metric {
  final String label, value;
  _Metric(this.label, this.value);
}

class _MetricCard extends StatelessWidget {
  final _Metric m;
  const _MetricCard({required this.m});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.6,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              m.label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            SelectableText(
              m.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _Flag {
  final String text;
  final bool on;
  _Flag(this.text, this.on);
}

class _FlagChip extends StatelessWidget {
  final _Flag flag;
  const _FlagChip({required this.flag});

  @override
  Widget build(BuildContext context) {
    final Color bg = flag.on
        ? _AlpacaAccountViewState.kPrimary
        : Colors.grey.shade200;
    final Color fg = flag.on ? Colors.white : Colors.black87;
    return Chip(
      label: Text(flag.text, style: TextStyle(color: fg)),
      backgroundColor: bg,
      side: flag.on ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String k, v;
  const _InfoRow(this.k, this.v);

  static _InfoRow kv(String k, String v) => _InfoRow(k, v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 8),
          Expanded(child: SelectableText(v)),
        ],
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  final int cols;
  final List<_InfoRow> items;
  const _DetailsGrid({required this.cols, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
        childAspectRatio: 3.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => items[i],
    );
  }
}
// ================= End of Help widgets =================