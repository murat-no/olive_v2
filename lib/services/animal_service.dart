import 'dart:convert';
import 'package:olive_v2/models/page_request.dart';
import 'package:olive_v2/models/animal.dart';
import 'package:olive_v2/models/backend_response.dart';
import 'package:olive_v2/models/value_option.dart';
import 'package:olive_v2/models/paging_result_payload.dart';
import 'package:olive_v2/services/auth_http_client.dart'; // ✨ YENİ: AuthHttpClient'ı import et ✨


class AnimalService {
  // ✨ AuthHttpClient instance'ı kullanacağız ✨
  final AuthHttpClient _authHttpClient;

  // Constructor'da AuthHttpClient'ı alabiliriz (dependency injection)
  // veya burada doğrudan bir instance oluşturabiliriz.
  AnimalService({AuthHttpClient? authHttpClient})
      : _authHttpClient = authHttpClient ?? AuthHttpClient(); // Default instance eğer null gelirse


  // ✨ KALDIRILDI: _authenticatedPost, _authenticatedGet, _authenticatedDelete metotları artık burada değil.
  // Bu metotlar artık AuthHttpClient içinde. ✨


  // Hayvan listesini çekme metodu (AuthHttpClient'ı kullanacak)
  Future<PagingResultPayload<Animal>?> fetchAnimals(PageRequest payload) async {
    print('DEBUG: AnimalService.fetchAnimals çağrıldı, payload: ${jsonEncode(payload.toJson())}');
    // _authenticatedPost yerine _authHttpClient.post kullan
    final jsonResponse = await _authHttpClient.post('/api/admin/Animals', payload.toJson());
    print('DEBUG: AnimalService.fetchAnimals - JSON yanıtı alındı.');
    
    final backendResponse = BackendResponse<Animal>.fromJson(
      jsonResponse,
      (Object? json) => Animal.fromJson(json as Map<String, dynamic>),
    );
    print('DEBUG: AnimalService.fetchAnimals - BackendResponse parse edildi.');

    if (backendResponse.pagingResult == null) {
        print('DEBUG: AnimalService.fetchAnimals - pagingResult null geldi.');
        throw Exception(backendResponse.pagingResult?.message ?? 'API\'den pagingResult alanı gelmedi veya boş.');
    }
    if (backendResponse.pagingResult!.error) {
        print('DEBUG: AnimalService.fetchAnimals - PagingResult hata döndürdü: ${backendResponse.pagingResult!.message}');
        throw Exception(backendResponse.pagingResult!.message);
    }
    print('DEBUG: AnimalService.fetchAnimals - PagingResult başarıyla parse edildi. RowCount: ${backendResponse.pagingResult!.rowCount}, Data Length: ${backendResponse.pagingResult!.data?.length}');
    return backendResponse.pagingResult;
  }

  // Hayvan Ekleme veya Güncelleme Metodu (AuthHttpClient'ı kullanacak)
  Future<Animal?> saveOrUpdateAnimal(Animal animalData) async {
    final isAdding = (animalData.id == null || animalData.id!.isEmpty || animalData.id == '0');
    final endpoint = isAdding ? '/api/admin/edit-Animal/0' : '/api/admin/edit-Animal/${animalData.id}';
    final Map<String, dynamic> payload = animalData.toJson();

    print('DEBUG: AnimalService saveOrUpdateAnimal - Payload : : ${const JsonEncoder.withIndent('  ').convert(animalData.toJson())}' );

    // _authenticatedPost yerine _authHttpClient.post kullan
    final jsonResponse = await _authHttpClient.post(endpoint, payload);
    
    final backendResponse = BackendResponse<Animal>.fromJson(
      jsonResponse,
      (Object? json) => Animal.fromJson(json as Map<String, dynamic>),
    );
    if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) {
      throw Exception(backendResponse.pagingResult?.message ?? 'Kaydetme/güncelleme sırasında bilinmeyen bir hata oluştu.');
    }

    if (backendResponse.pagingResult!.data != null && backendResponse.pagingResult!.data!.isNotEmpty) {
      print('DEBUG: AnimalService - Hayvan başarıyla kaydedildi/güncellendi.');
      return backendResponse.pagingResult!.data!.first;
    } else {
      print('DEBUG: AnimalService - Kaydetme/Güncelleme başarılı ancak kaydedilen obje yanıt dönmedi.');
      return null;
    }
  }

  // Hayvan silme metodu (AuthHttpClient'ı kullanacak)
  Future<bool> deleteAnimal(String animalId) async {
    if (animalId.isEmpty || animalId == '0') {
      throw Exception('Silinecek hayvan ID\'si geçersiz.');
    }
    final endpoint = '/api/admin/delete-Animal/$animalId';
    print('DEBUG: AnimalService deleteAnimal - İstek gönderiliyor: $endpoint');
    try {
      // _authenticatedDelete yerine _authHttpClient.delete kullan
      final jsonResponse = await _authHttpClient.delete(endpoint);
      final backendResponse = BackendResponse<dynamic>.fromJson(jsonResponse, (Object? json) => null,);
      if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) {
        throw Exception(backendResponse.pagingResult?.message ?? 'Silme sırasında bilinmeyen bir hata oluştu.');
      }
      print('DEBUG: AnimalService - Hayvan başarıyla silindi: ID $animalId');
      return true;
    } catch (e) {
      print('DEBUG: AnimalService deleteAnimal - Hata: ${e.toString()}');
      rethrow;
    }
  }

  // Değer Listelerini Çekme Metotları (AuthHttpClient'ı kullanacak)
  Future<List<ValueOption>?> getValueList(String type) async {
    final endpoint = '/api/admin/definitions/$type';
    print('DEBUG: AnimalService: Değer listesi çekiliyor: $endpoint');
    try {
      // _authenticatedGet yerine _authHttpClient.get kullan
      final jsonResponse = await _authHttpClient.get(endpoint);
      final backendResponse = BackendResponse<ValueOption>.fromJson(
        jsonResponse,
        (Object? json) => ValueOption.fromJson(json as Map<String, dynamic>),
      );
      if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) {
        throw Exception(backendResponse.pagingResult?.message ?? 'Değer listesi çekilirken bilinmeyen bir hata oluştu.');
      }
      print('DEBUG: AnimalService: Değer listesi başarıyla çekildi ($type).');
      return backendResponse.pagingResult!.data;
    } catch (e) {
      throw Exception('Değer listesi çekme hatası ($type): ${e.toString()}');
    }
  }

   // Bağımlı Değer Listesini Çekme Metodu (AuthHttpClient'ı kullanacak)
  Future<List<ValueOption>?> getDependentValueList(String type, String subtypeId) async {
    if (subtypeId.isEmpty || subtypeId == '0') { return null; }
    final endpoint = '/api/admin/definitions/$type/$subtypeId';
     print('DEBUG: AnimalService: Bağımlı değer listesi çekiliyor: $endpoint');
    try {
      // _authenticatedGet yerine _authHttpClient.get kullan
        final jsonResponse = await _authHttpClient.get(endpoint);
        final backendResponse = BackendResponse<ValueOption>.fromJson(
          jsonResponse,
          (Object? json) => ValueOption.fromJson(json as Map<String, dynamic>),
        );
        if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) {
          throw Exception(backendResponse.pagingResult?.message ?? 'Bağımlı değer listesi çekilirken bilinmeyen bir hata oluştu.');
        }
        print('DEBUG: AnimalService: Bağımlı değer listesi başarıyla çekildi ($type/$subtypeId).');
        return backendResponse.pagingResult!.data;
    } catch (e) { throw Exception('Bağımlı değer listesi çekme hatası ($type/$subtypeId): ${e.toString()}'); }
  }
}