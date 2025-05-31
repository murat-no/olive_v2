// lib/services/location_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:olive_v2/config/app_config.dart';
import 'package:olive_v2/models/value_option.dart';
import 'package:olive_v2/models/backend_response.dart';
import 'package:olive_v2/models/paging_result_payload.dart';
import 'package:olive_v2/models/page_request.dart'; // PageRequest için import

class LocationService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // AUTHENTICATED POST (mevcut owner_service'den kopyalanabilir)
  Future<Map<String, dynamic>> _authenticatedPost(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$kBaseUrl$endpoint');
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) { throw Exception('Kimlik doğrulama tokenı bulunamadı. Lütfen giriş yapın.'); }
    print('DEBUG: LocationService authenticatedPost - İstek gönderiliyor: $url');
    print('DEBUG: LocationService authenticatedPost - İstek Body: ${jsonEncode(body)}');
    try {
      final response = await http.post(url, headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token', }, body: jsonEncode(body), );
      final responseBody = utf8.decode(response.bodyBytes); final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      print('DEBUG: LocationService authenticatedPost - Yanıt Status Code: ${response.statusCode}');
      //print('DEBUG: LocationService authenticatedPost - Yanıt Body: ${const JsonEncoder.withIndent('  ').convert(jsonResponse)}');
      if (response.statusCode != 200) {
        if (jsonResponse.containsKey('pagingResult') && jsonResponse['pagingResult'] != null) { final PagingResultPayload<dynamic> errorPayload = PagingResultPayload.fromJson(jsonResponse['pagingResult'], (json) => null); if (errorPayload.error && errorPayload.message != null) { throw Exception(errorPayload.message); }}
        throw Exception('API çağrısı başarısız oldu: ${response.statusCode}');
      }
      return jsonResponse;
    } catch (e) { print('DEBUG: LocationService authenticatedPost - Hata: ${e.toString()}'); rethrow; }
  }

  // AUTHENTICATED GET (şu an lokasyon için kullanılmayacak ama genel olsun diye bırakabiliriz)
  Future<Map<String, dynamic>> _authenticatedGet(String endpoint) async {
     final url = Uri.parse('$kBaseUrl$endpoint');
     final token = await _secureStorage.read(key: 'jwt_token');
     if (token == null) { throw Exception('Kimlik doğrulama tokenı bulunamadı. Lütfen giriş yapın.'); }
     print('DEBUG: LocationService authenticatedGet - İstek gönderiliyor: $url');
     try {
         final response = await http.get(url, headers: { 'Accept': 'application/json', 'Authorization': 'Bearer $token', }, );
         final responseBody = utf8.decode(response.bodyBytes); final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
         print('DEBUG: LocationService authenticatedGet - Yanıt Status Code: ${response.statusCode}');
         print('DEBUG: LocationService authenticatedGet - Yanıt Body: ${const JsonEncoder.withIndent('  ').convert(jsonResponse)}');
          if (response.statusCode != 200) {
              if (jsonResponse.containsKey('pagingResult') && jsonResponse['pagingResult'] != null) {
                final PagingResultPayload<dynamic> errorPayload = PagingResultPayload.fromJson(jsonResponse['pagingResult'], (json) => null);
                if (errorPayload.error && errorPayload.message != null) {
                    throw Exception(errorPayload.message);
                }
            }
            throw Exception('API çağrısı başarısız oldu: ${response.statusCode}');
          }
          return jsonResponse;
     } catch (e) { print('DEBUG: LocationService authenticatedGet - Hata: ${e.toString()}'); rethrow; }
   }


  // ✨ YENİ: Lokasyon listelerini PageRequest ile POST ederek çekme metodu ✨
  // Endpoint: /locations/{type}/{parentKey} (POST isteği ve body olarak PageRequest alacak)
  Future<List<ValueOption>?> fetchLocations(String type, {required String parentKey, PageRequest? pageRequest}) async {
    // parentKey'in zorunlu olduğunu belirtiyoruz.
    if (parentKey.isEmpty || parentKey == '0') {
      print('DEBUG: LocationService: Parent key boş veya geçersiz ($parentKey), lokasyon listesi çekilmiyor. Type: $type');
      return null;
    }

    // Endpoint formatı: /locations/{type}/{subtype}
    final endpoint = '/api/admin/locations/$type/$parentKey';
    
    // PageRequest null ise varsayılan bir PageRequest oluştur
    final effectivePageRequest = pageRequest ?? PageRequest(
      currentPage: 1, // Varsayılan sayfa
      rowsPerPage: 100, // Varsayılan satır sayısı (tüm lokasyonlar için yeterince büyük olsun)
      lang: 'tr',
      debug: false,
      // queryCriteria: // Lokasyonlar için özel arama kriterleri eklenebilir.
    );

    print('DEBUG: LocationService: Lokasyon listesi çekiliyor (POST): $endpoint');
    print('DEBUG: LocationService: İstek Payload (PageRequest): ${effectivePageRequest.toJson()}');

    try {
        final jsonResponse = await _authenticatedPost(endpoint, effectivePageRequest.toJson()); // POST isteği gönder
        final backendResponse = BackendResponse<ValueOption>.fromJson(jsonResponse, (Object? json) => ValueOption.fromJson(json as Map<String, dynamic>));
        if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) {
            throw Exception(backendResponse.pagingResult?.message ?? 'Lokasyon listesi çekilirken bilinmeyen bir hata oluştu.');
        }
        print('DEBUG: LocationService: Lokasyon listesi başarıyla çekildi ($type/$parentKey).');
        return backendResponse.pagingResult!.data;
    } catch (e) {
        throw Exception('Lokasyon listesi çekme hatası ($type/$parentKey): ${e.toString()}');
    }
  }
}