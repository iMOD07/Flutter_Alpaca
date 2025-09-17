class AlpacaCreds {
  final String keyId;
  final String secret;
  final String baseUrl;
  const AlpacaCreds({
    required this.keyId,
    required this.secret,
    this.baseUrl = 'https://paper-api.alpaca.markets/v2',
  });
}
