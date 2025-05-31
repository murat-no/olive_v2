import 'dart:convert';

import 'package:olive_v2/models/owner.dart';
import 'package:olive_v2/models/page_request.dart';
import 'package:olive_v2/models/backend_response.dart';
import 'package:olive_v2/models/paging_result_payload.dart';
import 'package:olive_v2/services/auth_http_client.dart'; 


class OwnerService {
  // ✨ AuthHttpClient instance'ı kullanacağız ✨
  final AuthHttpClient _authHttpClient;

  // Constructor'da AuthHttpClient'ı alabiliriz (dependency injection)
  OwnerService({AuthHttpClient? authHttpClient})
      : _authHttpClient = authHttpClient ?? AuthHttpClient(); // Default instance eğer null gelirse


  // ✨ KALDIRILDI: _authenticatedPost, _authenticatedGet, _authenticatedDelete metotları artık burada değil.
  // Bu metotlar artık AuthHttpClient içinde. ✨


  // Sahip listesini çekme metodu (AuthHttpClient'ı kullanacak)
  Future<PagingResultPayload<Owner>?> fetchOwners(PageRequest payload) async {
    print('DEBUG: OwnerService.fetchOwners çağrıldı, payload: ${jsonEncode(payload.toJson())}');
    // _authenticatedPost yerine _authHttpClient.post kullan
    final jsonResponse = await _authHttpClient.post('/api/admin/Owners', payload.toJson());
    print('DEBUG: OwnerService.fetchOwners - JSON yanıtı alındı.');
    
    final backendResponse = BackendResponse<Owner>.fromJson(
      jsonResponse,
      (Object? json) => Owner.fromJson(json as Map<String, dynamic>),
    );
    print('DEBUG: OwnerService.fetchOwners - BackendResponse parse edildi.');

    if (backendResponse.pagingResult == null) {
        print('DEBUG: OwnerService.fetchOwners - pagingResult null geldi.');
        throw Exception(backendResponse.pagingResult?.message ?? 'API\'den pagingResult alanı gelmedi veya boş.');
    }
    if (backendResponse.pagingResult!.error) {
        print('DEBUG: OwnerService.fetchOwners - PagingResult hata döndürdü: ${backendResponse.pagingResult!.message}');
        throw Exception(backendResponse.pagingResult!.message);
    }
    print('DEBUG: OwnerService.fetchOwners - PagingResult başarıyla parse edildi. RowCount: ${backendResponse.pagingResult!.rowCount}, Data Length: ${backendResponse.pagingResult!.data?.length}');
    return backendResponse.pagingResult;
  }

  // Sahip ekleme veya güncelleme metodu (AuthHttpClient'ı kullanacak)
  Future<Owner?> saveOrUpdateOwner(Owner ownerData) async {
    final isAdding = (ownerData.id == null || ownerData.id!.isEmpty || ownerData.id == '0');
    final endpoint = isAdding ? '/api/admin/edit-Owner/0' : '/api/admin/edit-Owner/${ownerData.id}';
    final Map<String, dynamic> payload = ownerData.toJson();

    //print('DEBUG: OwnerService saveOrUpdateOwner - Payload : : ${const JsonEncoder.withIndent('  ').convert(ownerData.toJson())}' );

    // _authenticatedPost yerine _authHttpClient.post kullan
    final jsonResponse = await _authHttpClient.post(endpoint, payload);
    
    final backendResponse = BackendResponse<Owner>.fromJson(
      jsonResponse,
      (Object? json) => Owner.fromJson(json as Map<String, dynamic>),
    );
    if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) {
      throw Exception(backendResponse.pagingResult?.message ?? 'Sahip kaydetme/güncelleme sırasında bilinmeyen bir hata oluştu.');
    }

    if (backendResponse.pagingResult!.data != null && backendResponse.pagingResult!.data!.isNotEmpty) {
      print('DEBUG: OwnerService - Sahip başarıyla kaydedildi/güncellendi.');
      return backendResponse.pagingResult!.data!.first;
    } else {
      print('DEBUG: OwnerService - Kaydetme/Güncelleme başarılı ancak kaydedilen obje yanıt dönmedi.');
      return null;
    }
  }

  // Sahip silme metodu (AuthHttpClient'ı kullanacak)
  Future<bool> deleteOwner(String ownerId) async {
    if (ownerId.isEmpty || ownerId == '0') {
      throw Exception('Silinecek sahip ID\'si geçersiz.');
    }
    final endpoint = '/api/admin/delete-Owner/$ownerId';
    print('DEBUG: OwnerService deleteOwner - İstek gönderiliyor: $endpoint');
    try {
      // _authenticatedDelete yerine _authHttpClient.delete kullan
      final jsonResponse = await _authHttpClient.delete(endpoint);
      final backendResponse = BackendResponse<dynamic>.fromJson(jsonResponse, (Object? json) => null,);
      if (backendResponse.pagingResult == null || backendResponse.pagingResult!.error) {
        throw Exception(backendResponse.pagingResult?.message ?? 'Silme sırasında bilinmeyen bir hata oluştu.');
      }
      print('DEBUG: OwnerService - Sahip başarıyla silindi: ID $ownerId');
      return true;
    } catch (e) {
      print('DEBUG: OwnerService deleteOwner - Hata: ${e.toString()}');
      rethrow;
    }
  }

  // Lokasyon değer listelerini çekme metotları (OwnerService'den LocationService'e taşınacak)
  // Bu metotlar artık LocationService'te bulunacak.
  /*
  Future<List<ValueOption>?> fetchLocationList(String type) async {
    // ...
  }
  Future<List<ValueOption>?> fetchDependentLocationList(String type, String parentKey) async {
    // ...
  }
  */
}