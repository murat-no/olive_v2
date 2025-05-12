import 'package:mobx/mobx.dart';
import 'package:olive_v2/models/animal.dart';
import 'package:olive_v2/models/page_request.dart';
// import 'package:olive_v2/models/paging_result.dart'; // Eski model
// import 'package:olive_v2/models/paging_result_payload.dart'; // Yeni payload modelini import edebiliriz
import 'package:olive_v2/services/animal_service.dart';

part 'animal_store.g.dart';

class AnimalStore = _AnimalStore with _$AnimalStore;

abstract class _AnimalStore with Store {
  final AnimalService _animalService = AnimalService();

  @observable
  ObservableList<Animal> animals = ObservableList<Animal>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  @observable
  int totalRowCount = 0; // PagingResult'tan gelecek

  @observable
  int currentPage = 1; // PageRequest'te gönderiliyor, PagingResult'ta teyit edilebilir

  @observable
  int rowsPerPage = 20; // PageRequest'te gönderiliyor, PagingResult'ta teyit edilebilir


  @action
  Future<void> fetchAnimals({String? query, int? page, int? rows}) async {
    final currentQuery = query ?? searchQuery;
    final targetPage = page ?? currentPage;
    final targetRows = rows ?? rowsPerPage;

    if (query != null || animals.isEmpty) {
       currentPage = 1;
    } else {
       currentPage = targetPage;
    }
    rowsPerPage = targetRows;
    searchQuery = currentQuery;

    isLoading = true;
    errorMessage = null;

    try {
      final pageRequest = PageRequest(
        currentPage: currentPage,
        rowsPerPage: rowsPerPage,
        lang: 'tr',
        queryCriteria: currentQuery.isNotEmpty
            ? {'FULLTEXT': currentQuery}
            : null,
      );

      // ✨ AnimalService'den List<Animal>? al ✨
      final fetchedAnimals = await _animalService.fetchAnimals(pageRequest);

      // ✨ Gelen listeyi kullan (null olabilir) ✨
      animals = ObservableList.of(fetchedAnimals ?? []); // fetchedAnimals null ise boş liste kullan

      // ✨ Sayfalama bilgileri artık buradan gelmiyor, bu alanlar güncellenmeyecek ✨
      // totalRowCount = pagingResult.rowCount ?? 0;
      // currentPage = pagingResult.currentPage ?? currentPage;
      // rowsPerPage = pagingResult.pageSize ?? rowsPerPage;

      print('DEBUG: ${animals.length} hayvan yüklendi.'); // Toplam kayıt sayısı bilgisi artık yok

    } catch (e) {
      errorMessage = e.toString();
      print('DEBUG: fetchAnimals Aksiyonunda Hata: $errorMessage');
      animals = ObservableList();
       totalRowCount = 0;
    } finally {
       isLoading = false;
    }
  }

  // TODO: Diğer aksiyonlar
}