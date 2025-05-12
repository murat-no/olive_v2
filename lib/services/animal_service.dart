import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Token okumak için
import 'package:olive_v2/models/page_request.dart'; // PageRequest modelini import et
import 'package:olive_v2/models/animal.dart'; // Animal modelini import et
// PagingResultPayload modelini import et
import 'package:olive_v2/models/backend_response.dart'; // BackendResponse modelini import et
import 'package:olive_v2/models/value_option.dart'; // ValueOption modelini import et
import 'package:olive_v2/config/app_config.dart'; // Base URL için


class AnimalService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Kimliği doğrulanmış POST API çağrısı için temel metod (Ham Map döndüren)
  Future<Map<String, dynamic>> _authenticatedPost(String endpoint, Map<String, dynamic> body) async { /* ... aynı kod ... */
    final url = Uri.parse('$kBaseUrl$endpoint');
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) { throw Exception('Kimlik doğrulama tokenı bulunamadı. Lütfen giriş yapın.'); }
    try {
         final response = await http.post(url, headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token', }, body: jsonEncode(body), );
         final responseBody = utf8.decode(response.bodyBytes); final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
          if (response.statusCode != 200) { /* ... hata fırlatma ... */ } return jsonResponse;
    } catch (e) { rethrow; }
  }

  // Kimliği doğrulanmış GET API çağrısı için temel metod (Ham Map döndüren)
   Future<Map<String, dynamic>> _authenticatedGet(String endpoint) async { /* ... aynı kod ... */
     final url = Uri.parse('$kBaseUrl$endpoint');
     final token = await _secureStorage.read(key: 'jwt_token');
     if (token == null) { throw Exception('Kimlik doğrulama tokenı bulunamadı. Lütfen giriş yapın.'); }
     try {
         final response = await http.get(url, headers: { 'Accept': 'application/json', 'Authorization': 'Bearer $token', }, );
         final responseBody = utf8.decode(response.bodyBytes); final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
          if (response.statusCode != 200) { /* ... hata fırlatma ... */ } return jsonResponse;
     } catch (e) { rethrow; }
   }


  // Hayvan listesini çekme metodu (Aynı kalacak)
  Future<List<Animal>?> fetchAnimals(PageRequest payload) async { /* ... aynı kod ... */
    final jsonResponse = await _authenticatedPost('/api/admin/Animals', payload.toJson());
    final backendResponse = BackendResponse<Animal>.fromJson(jsonResponse, (Object? json) => Animal.fromJson(json as Map<String, dynamic>));
    if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) { throw Exception(backendResponse.pagingResult!.message); }
    return backendResponse.pagingResult!.data;
  }

  // Hayvan Ekleme veya Güncelleme Metodu (Aynı kalacak)
  Future<Animal?> saveOrUpdateAnimal(Animal animalData) async { /* ... aynı kod ... */
     final isAdding = (animalData.id == null || animalData.id!.isEmpty || animalData.id == '0');
     final endpoint = isAdding ? '/api/admin/edit-Animal/0' : '/api/admin/edit-Animal/${animalData.id}';
     final Map<String, dynamic> payload = animalData.toJson();

     print('saveOrUpdateAnimal  payload : : ${const JsonEncoder.withIndent('  ').convert(animalData.toJson())}' );

     final jsonResponse = await _authenticatedPost(endpoint, payload);
     
     final backendResponse = BackendResponse<Animal>.fromJson(jsonResponse, (Object? json) => Animal.fromJson(json as Map<String, dynamic>));
     if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) { throw Exception(backendResponse.pagingResult!.message); }

     if (backendResponse.pagingResult!.data != null && backendResponse.pagingResult!.data!.isNotEmpty) {
       print('DEBUG: Hayvan başarıyla kaydedildi/güncellendi.');
       return backendResponse.pagingResult!.data!.first;
     } else {
       print('DEBUG: Kaydetme/Güncelleme başarılı ancak kaydedilen obje yanıt dönmedi.');
       return null;
     }
  }

  // TODO: Hayvan silme metodu

  // Değer Listelerini Çekme Metotları (Endpoint isimleri güncellendi)
  Future<List<ValueOption>?> getValueList(String type) async { /* ... aynı kod ... */
    final endpoint = '/api/admin/definitions/$type'; // /definitions/{type} endpoint'i
    print('DEBUG: Değer listesi çekiliyor: $endpoint');
    try { /* ... GET çağrısı ve parsing ... */
        final jsonResponse = await _authenticatedGet(endpoint);
        final backendResponse = BackendResponse<ValueOption>.fromJson(jsonResponse, (Object? json) => ValueOption.fromJson(json as Map<String, dynamic>));
        if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) { throw Exception(backendResponse.pagingResult!.message); }
        print('DEBUG: Değer listesi başarıyla çekildi ($type).');
        return backendResponse.pagingResult!.data;
    } catch (e) { 
        throw Exception('Değer listesi çekme hatası ($type): ${e.toString()}'); 
    }
  }

   // Bağımlı Değer Listesini Çekme Metodu (Aynı kalacak)
  Future<List<ValueOption>?> getDependentValueList(String type, String subtypeId) async { /* ... aynı kod ... */
    if (subtypeId.isEmpty || subtypeId == '0') { return null; }
    final endpoint = '/api/admin/definitions/$type/$subtypeId';
     print('DEBUG: Bağımlı değer listesi çekiliyor: $endpoint');
    try { /* ... GET çağrısı ve parsing ... */
        final jsonResponse = await _authenticatedGet(endpoint);
        final backendResponse = BackendResponse<ValueOption>.fromJson(jsonResponse, (Object? json) => ValueOption.fromJson(json as Map<String, dynamic>));
        if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) { throw Exception(backendResponse.pagingResult!.message); }
        print('DEBUG: Bağımlı değer listesi başarıyla çekildi ($type/$subtypeId).');
        return backendResponse.pagingResult!.data;
    } catch (e) { throw Exception('Bağımlı değer listesi çekme hatası ($type/$subtypeId): ${e.toString()}'); }
  }
}