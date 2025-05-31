// lib/stores/animal_store.dart

import 'package:mobx/mobx.dart';
import 'package:olive_v2/models/animal.dart';
import 'package:olive_v2/models/page_request.dart';
import 'package:olive_v2/models/paging_result_payload.dart';
import 'package:olive_v2/services/animal_service.dart';
import 'package:olive_v2/stores/base_store.dart';
import 'dart:async';

part 'animal_store.g.dart';

class AnimalStore = _AnimalStore with _$AnimalStore;

abstract class _AnimalStore extends BaseStore with Store {
  final AnimalService _animalService = AnimalService();
  Timer? _debounce;

  @observable
  ObservableList<Animal> animals = ObservableList<Animal>();

  @observable
  String searchQuery = '';

  @action
  void setSearchQuery(String query) {
    if (searchQuery == query) return;
    searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      print('DEBUG: Debounced search query: $searchQuery');
      fetchAnimals(query: searchQuery, page: 1);
    });
  }

  @action
  Future<void> fetchAnimals({String? query, int? page, int? rows}) async {
    final effectiveQuery = query ?? searchQuery;
    final effectivePage = page ?? currentPage;
    final effectiveRows = rows ?? rowsPerPage;

    if (effectiveQuery != searchQuery) searchQuery = effectiveQuery;
    if (effectivePage != currentPage) this.currentPage = effectivePage;
    if (effectiveRows != rowsPerPage) this.rowsPerPage = effectiveRows;

    // ✨ ÖNEMLİ DEĞİŞİKLİK BURADA ✨
    final pagingResult = await execute<PagingResultPayload<Animal>>(
      () async {
        final pageRequest = PageRequest(
          currentPage: this.currentPage,
          rowsPerPage: this.rowsPerPage,
          lang: 'tr',
          debug: false,
          queryCriteria: effectiveQuery.isNotEmpty ? {'FULLTEXT': effectiveQuery} : null,
        );
        
        // _animalService.fetchAnimals PagingResultPayload<Animal>? döndürüyor.
        // Eğer null dönerse, bir Exception fırlatıyoruz, böylece execute'un catch bloğu bunu yakalar.
        final result = await _animalService.fetchAnimals(pageRequest);
        if (result == null) {
          throw Exception('API\'den boş veya geçersiz hayvan listesi yanıtı alındı.');
        }
        return result; // Non-nullable bir değer döndürdüğümüzü garanti ediyoruz.
      },
      customErrorMessage: 'Hayvan listesi çekilirken bir hata oluştu.',
      onError: (error) {
        runInAction(() {
          animals = ObservableList();
          this.totalRowCount = 0;
          this.currentPage = 1;
        });
      },
      showLoading: true,
      clearErrorOnStart: true,
    );

    runInAction(() {
      if (pagingResult != null) {
        animals = ObservableList.of(pagingResult.data ?? []);
        this.totalRowCount = pagingResult.rowCount ?? 0;
        this.currentPage = pagingResult.currentPage ?? this.currentPage;
        this.rowsPerPage = pagingResult.pageSize ?? this.rowsPerPage;
        print('DEBUG: ${this.totalRowCount} toplam kayıttan ${animals.length} hayvan yüklendi (Sayfa: ${this.currentPage}).');
      }
      // Eğer pagingResult null ise (yani execute içinde bir hata fırlatıldıysa),
      // onError callback'i zaten çalışmış ve hata mesajı set edilmiştir.
    });
  }

  @action
  Future<bool> deleteAnimal(String animalId) async {
    final success = await execute<bool>(
      () async {
        return await _animalService.deleteAnimal(animalId);
      },
      customErrorMessage: 'Hayvan silinirken bir hata oluştu.',
      showLoading: true,
      clearErrorOnStart: true,
    );

    if (success == true) {
      await fetchAnimals(query: searchQuery, page: currentPage);
      print('DEBUG: Hayvan başarıyla silindi ve liste yenilendi.');
      return true;
    }
    return false;
  }

  @override
  @action
  void setCurrentPage(int page) {
    super.setCurrentPage(page);
    fetchAnimals(query: searchQuery, page: currentPage);
  }

  @override
  @action
  void setRowsPerPage(int rows) {
    super.setRowsPerPage(rows);
    fetchAnimals(query: searchQuery, page: currentPage, rows: rowsPerPage);
  }

  @action
  void disposeDebounce() {
    _debounce?.cancel();
    print('DEBUG: AnimalStore debounce timer iptal edildi.');
  }
}