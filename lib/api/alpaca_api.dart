import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AlpacaApi {
  final Dio _dio;

  AlpacaApi({
    Dio? dio,
    required String baseUrl,
    required String keyId,
    required String secret,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               headers: {
                 'APCA-API-KEY-ID': keyId.trim(),
                 'APCA-API-SECRET-KEY': secret.trim(),
                 'Accept': 'application/json',
               },
               connectTimeout: const Duration(seconds: 12),
               receiveTimeout: const Duration(seconds: 12),
               // allow reading body even if status is not 2xx
               validateStatus: (s) => true,
             ),
           ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('[Dio] -> GET ${options.baseUrl}${options.path}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint('[Dio] <- ${response.statusCode}');
            handler.next(response);
          },
          onError: (e, handler) {
            debugPrint('[Dio][Error] $e');
            handler.next(e);
          },
        ),
      );
    }
  }

  /// GET /account
  Future<Map<String, dynamic>> getAccount() async {
    // ignore: avoid_print
    print('[AlpacaApi] baseUrl=' + _dio.options.baseUrl);

    final res = await _dio.get('/account');
    final code = res.statusCode ?? 0;

    if (code == 200) {
      if (res.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(res.data);
      }
      // Some environments may decode as List<int>/String; try parse
      try {
        return Map<String, dynamic>.from(res.data);
      } catch (_) {
        throw Exception(
          'HTTP 200 but unexpected body type: ${res.data.runtimeType}',
        );
      }
    }

    // extract message if present
    String detail = 'no body';
    final body = res.data;
    if (body is Map && body['message'] != null) {
      detail = body['message'].toString();
    } else if (body != null) {
      detail = body.toString();
    }
    throw Exception('HTTP ' + code.toString() + ': ' + detail);
  }
}
