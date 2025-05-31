// lib/stores/owner_store.dart

import 'package:mobx/mobx.dart';
import 'package:olive_v2/models/owner.dart'; // Owner modelini import et
import 'package:olive_v2/models/page_request.dart'; // PageRequest modelini import et
import 'package:olive_v2/models/paging_result_payload.dart'; // PagingResultPayload modelini import et
import 'package:olive_v2/services/owner_service.dart'; // OwnerService'i import et
import 'package:olive_v2/stores/base_store.dart'; // BaseStore'u import et
import 'dart:async'; // Debounce için

part 'owner_store.g.dart';

class OwnerStore = _OwnerStore with _$OwnerStore;

abstract class _OwnerStore extends BaseStore with Store { // BaseStore'dan miras alıyoruz
  final OwnerService _ownerService = OwnerService();
  Timer? _debounce;

  @observable
  ObservableList<Owner> owners = ObservableList<Owner>();

  // isLoading, errorMessage, totalRowCount, currentPage, rowsPerPage
  // artık BaseStore'dan geliyor.

  @observable
  String searchQuery = ''; // Arama sorgusunu tutacak observable

  // Arama metni değiştiğinde çağrılacak ve debounce uygulayacak aksiyon
  @action
  void setSearchQuery(String query) {
    if (searchQuery == query) return; // Aynı sorgu ise işlem yapma
    searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel(); // Önceki timer'ı iptal et
    _debounce = Timer(const Duration(milliseconds: 500), () {
      print('DEBUG: OwnerStore: Debounced search query: $searchQuery');
      fetchOwners(query: searchQuery, page: 1); // Yeni sorgu ile her zaman ilk sayfadan başla
    });
  }

  // Sahipleri backend'den çekecek aksiyon
  @action
  Future<void> fetchOwners({String? query, int? page, int? rows}) async {
    final effectiveQuery = query ?? searchQuery;
    final effectivePage = page ?? currentPage;
    final effectiveRows = rows ?? rowsPerPage;

    // Eğer parametreler değiştiyse observable'ları güncelle
    if (effectiveQuery != searchQuery) searchQuery = effectiveQuery;
    if (effectivePage != currentPage) this.currentPage = effectivePage;
    if (effectiveRows != rowsPerPage) this.rowsPerPage = effectiveRows;

    // execute metodunu kullanarak hata ve yükleme durumlarını yönet
    final pagingResult = await execute<PagingResultPayload<Owner>>(
      () async {
        final pageRequest = PageRequest(
          currentPage: this.currentPage,
          rowsPerPage: this.rowsPerPage,
          lang: 'tr', 
          debug: true,
          queryCriteria: effectiveQuery.isNotEmpty
              ? {'FULLTEXT': effectiveQuery} // Fulltext arama için
              : null,
        );
        print('DEBUG: OwnerStore fetchOwners - PageRequest payload: ${pageRequest.toJson()}');
        final result = await _ownerService.fetchOwners(pageRequest);
        if (result == null) {
          throw Exception('API\'den boş veya geçersiz sahip listesi yanıtı alındı.');
        }
        return result;
      },
      customErrorMessage: 'Sahip listesi çekilirken bir hata oluştu.',
      onError: (error) { // Hata durumunda çalışacak callback
        runInAction(() {
          owners = ObservableList(); // Listeyi temizle
          this.totalRowCount = 0;
          this.currentPage = 1;
        });
      },
      showLoading: true, // Yüklenirken isLoading'i true yap
      clearErrorOnStart: true, // Başlarken errorMessage'ı temizle
    );

    runInAction(() {
      if (pagingResult != null) {
        owners = ObservableList.of(pagingResult.data ?? []); // Gelen datayı owners listesine ata
        this.totalRowCount = pagingResult.rowCount ?? 0;
        this.currentPage = pagingResult.currentPage ?? this.currentPage;
        this.rowsPerPage = pagingResult.pageSize ?? this.rowsPerPage;
        print('DEBUG: OwnerStore: ${this.totalRowCount} toplam kayıttan ${owners.length} sahip yüklendi (Sayfa: ${this.currentPage}).');
      }
    });
  }

  // Yeni sahip ekleme veya mevcut sahip güncelleme aksiyonu
  @action
  Future<Owner?> saveOrUpdateOwner(Owner ownerData) async {
    final savedOwner = await execute<Owner>(
      () async {
        final result = await _ownerService.saveOrUpdateOwner(ownerData);
        if (result == null) {
          throw Exception('Kaydetme işlemi başarılı ancak kaydedilen sahip bilgisi yanıtta dönmedi.');
        }
        return result;
      },
      customErrorMessage: 'Sahip kaydedilirken/güncellenirken bir hata oluştu.',
      showLoading: true,
      clearErrorOnStart: true,
    );

    if (savedOwner != null) {
      // Başarılı kayıttan sonra listeyi yenile (örneğin ilk sayfadan)
      await fetchOwners(query: searchQuery, page: 1); // Listeyi en güncel haliyle çek
      print('DEBUG: OwnerStore: Sahip başarıyla kaydedildi/güncellendi.');
      return savedOwner;
    }
    return null;
  }

  // Sahip silme aksiyonu
  @action
  Future<bool> deleteOwner(String ownerId) async {
    final success = await execute<bool>(
      () async {
        return await _ownerService.deleteOwner(ownerId);
      },
      customErrorMessage: 'Sahip silinirken bir hata oluştu.',
      showLoading: true,
      clearErrorOnStart: true,
    );

    if (success == true) {
      // Silme başarılıysa, listeyi yenile
      await fetchOwners(query: searchQuery, page: currentPage);
      print('DEBUG: OwnerStore: Sahip başarıyla silindi ve liste yenilendi.');
      return true;
    }
    return false;
  }

  @override // BaseStore'daki setCurrentPage'i override ediyoruz
  @action
  void setCurrentPage(int page) {
    super.setCurrentPage(page);
    fetchOwners(query: searchQuery, page: currentPage);
  }

  @override // BaseStore'daki setRowsPerPage'i override ediyoruz
  @action
  void setRowsPerPage(int rows) {
    super.setRowsPerPage(rows);
    fetchOwners(query: searchQuery, page: currentPage, rows: rowsPerPage);
  }

  // Debounce timer'ı dispose etmek için
  @action
  void disposeDebounce() {
    _debounce?.cancel();
    print('DEBUG: OwnerStore debounce timer iptal edildi.');
  }

  // TODO: Ek olarak, tek bir sahip objesi çekmek için (detay ekranı veya düzenleme için) bir metod eklenebilir.
  // Future<Owner?> fetchOwnerById(String ownerId)
}