// lib/services/auth_http_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:olive_v2/config/app_config.dart';
import 'package:olive_v2/models/backend_response.dart'; // BackendResponse modelini import et
import 'package:olive_v2/models/paging_result_payload.dart'; // PagingResultPayload modelini import et

// Ortak kimlik doğrulamalı HTTP isteklerini yöneten bir sınıf
class AuthHttpClient {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _baseUrl = kBaseUrl; // Base URL'yi doğrudan app_config'dan al

  // Genel HTTP isteği gönderen ve yanıtı işleyen yardımcı metod
  // requestCallback: http.get, http.post, http.delete gibi asenkron bir HTTP isteği döndüren fonksiyon
  Future<Map<String, dynamic>> _sendAuthenticatedRequest(
    Future<http.Response> Function(Uri url, Map<String, String> headers, dynamic body) requestCallback,
    String endpoint, {
    dynamic body,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final token = await _secureStorage.read(key: 'jwt_token');

    if (token == null) {
      throw Exception('Kimlik doğrulama tokenı bulunamadı. Lütfen giriş yapın.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('DEBUG: AuthHttpClient - İstek gönderiliyor: $url');
    if (body != null) {
      // body'yi JSON olarak encode edip print et
      try {
        print('DEBUG: AuthHttpClient - İstek Body: ${const JsonEncoder.withIndent('  ').convert(body)}');
      } catch (e) {
        print('DEBUG: AuthHttpClient - İstek Body (encode hatası): $body');
      }
    }

    try {
      final http.Response response;
      if (body != null) {
        // Body içeren istekler için (POST, PUT)
        response = await requestCallback(url, headers, jsonEncode(body)); // Body'yi JSON string olarak gönder
      } else {
        // Body içermeyen istekler için (GET, DELETE)
        response = await requestCallback(url, headers, null); // Body null geçilir
      }
      
      final responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      print('DEBUG: AuthHttpClient - Yanıt Status Code: ${response.statusCode}');
      //print('DEBUG: AuthHttpClient - Yanıt Body: ${const JsonEncoder.withIndent('  ').convert(jsonResponse)}');

      if (response.statusCode != 200) {
        // Backend'den gelen hata mesajını pagingResult içinde arama
        if (jsonResponse.containsKey('pagingResult') && jsonResponse['pagingResult'] != null) {
            try {
                final PagingResultPayload<dynamic> errorPayload = PagingResultPayload.fromJson(jsonResponse['pagingResult'], (json) => null);
                if (errorPayload.error && errorPayload.message != null && errorPayload.message!.isNotEmpty) {
                    throw Exception(errorPayload.message); // Backend'in spesifik mesajını fırlat
                }
            } catch (parseError) {
                print('WARNING: AuthHttpClient - Failed to parse errorPayload from pagingResult: $parseError');
            }
        }
        // Eğer pagingResult'ta spesifik bir hata mesajı yoksa veya parse edilemiyorsa genel hata
        throw Exception('API çağrısı başarısız oldu: ${response.statusCode}');
      }
      return jsonResponse;
    } catch (e) {
      print('DEBUG: AuthHttpClient - Hata: ${e.toString()}');
      rethrow; // Hatayı çağıran fonksiyona fırlat
    }
  }

  // POST isteği
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    return _sendAuthenticatedRequest(
      (url, headers, requestBody) => http.post(url, headers: headers, body: requestBody), // http.post'a zaten encode edilmiş string gidecek
      endpoint,
      body: body,
    );
  }

  // GET isteği
  Future<Map<String, dynamic>> get(String endpoint) async {
    return _sendAuthenticatedRequest(
      (url, headers, _) => http.get(url, headers: headers),
      endpoint,
    );
  }

  // DELETE isteği
  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _sendAuthenticatedRequest(
      (url, headers, _) => http.delete(url, headers: headers),
      endpoint,
    );
  }
}