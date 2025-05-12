import 'package:mobx/mobx.dart';
import 'package:olive_v2/models/animal.dart';
import 'package:olive_v2/models/value_option.dart';
import 'package:olive_v2/services/animal_service.dart';
import 'package:collection/collection.dart';
//import 'package:intl/intl.dart';


part 'add_edit_animal_store.g.dart';

class AddEditAnimalStore = _AddEditAnimalStore with _$AddEditAnimalStore;

abstract class _AddEditAnimalStore with Store {
  final AnimalService _animalService = AnimalService();

  // Form alanlarına karşılık gelen Observable değişkenler
  @observable String? id;
  @observable String? name;
  @observable String? alternateName;
  @observable String? passportNumber;
  @observable String? family;
  @observable String? familyKey;
  @observable String? race;
  @observable String? raceKey;
  @observable String? breed;
  @observable String? breedKey;
  @observable String? bloodGroup;
  @observable String? sex;
  @observable String? sexKey;
  @observable String? trackingMethodDisp;
  @observable String? trackingMethod;
  @observable String? color;
  @observable String? colorDisp;
  @observable String? birthDate;
  @observable String? markings;
  @observable String? exceptions;
  @observable String? trackingID;
  @observable String? tracerLocation;
  @observable String? owner;
  @observable String? ownerId;
  @observable DateTime? createdAt;
  @observable int? createdBy;
  @observable DateTime? updatedAt;
  @observable int? updatedBy;

  // Observable Durumlar
  @observable bool isLoading = false;
  @observable String? errorMessage;
  @observable bool isValueListsLoading = false;
  @observable String? valueListsErrorMessage;
  @observable bool isInitializing = false;


  // Observable Listeler
  @observable ObservableList<ValueOption> familyList = ObservableList<ValueOption>();
  @observable ObservableList<ValueOption> raceList = ObservableList<ValueOption>();
  @observable ObservableList<ValueOption> breedList = ObservableList<ValueOption>();
  @observable ObservableList<ValueOption> sexList = ObservableList<ValueOption>();
  @observable ObservableList<ValueOption> trackingMethodList = ObservableList<ValueOption>();


  // Observable Seçili Değerler
  @observable ValueOption? selectedFamilyOption;
  @observable ValueOption? selectedRaceOption;
  @observable ValueOption? selectedBreedOption;
  @observable ValueOption? selectedSexOption;
  @observable ValueOption? selectedTrackingMethodOption;


  // ✨ Aksiyonlar ✨

  // Initialization metodu
  @action
  Future<void> initialize(Animal? animalToEdit) async { /* ... aynı kod ... */
    isInitializing = true; errorMessage = null; valueListsErrorMessage = null;
    try { resetForm(); await fetchValueLists(); if (animalToEdit != null) { loadAnimalForEdit(animalToEdit); await setInitialDropdownSelections(); } }
    catch (e) { errorMessage = e.toString(); print('DEBUG: AddEditStore Initialization Error: $e'); }
    finally { isInitializing = false; }
  }


  // ✨ Yüklü hayvan verisine göre Dropdown başlangıç seçimlerini set et (Case-Insensitive Karşılaştırma) ✨
  @action
  Future<void> setInitialDropdownSelections() async {
      print('DEBUG: setInitialDropdownSelections çağrıldı.');

      // Family Dropdown için başlangıç seçimi (Case-insensitive karşılaştırma)
      selectedFamilyOption = familyList.firstWhereOrNull((opt) => opt.id?.toLowerCase() == familyKey?.toLowerCase());
      print('DEBUG: Initial Family Selection: ${selectedFamilyOption?.value ?? "Yok"} (Key: ${familyKey})');

      // Eğer Family set edilebildiyse, Race listesini çek ve Race Dropdown başlangıç seçimini yap
      if (selectedFamilyOption?.id != null && selectedFamilyOption!.id!.isNotEmpty) {
         await fetchRaces(selectedFamilyOption!.id!); // Bağımlı Race listesini çek

         // Race Dropdown için başlangıç seçimi (Case-insensitive karşılaştırma)
         selectedRaceOption = raceList.firstWhereOrNull((opt) => opt.id?.toLowerCase() == raceKey?.toLowerCase());
         print('DEBUG: Initial Race Selection: ${selectedRaceOption?.value ?? "Yok"} (Key: ${raceKey})');
      } else {
         raceList = ObservableList();
         selectedRaceOption = null;
         print('DEBUG: Family seçilemedi veya boş, Race listesi temizlendi.');
      }

      // Diğer Dropdown'lar için başlangıç seçimleri (Case-insensitive karşılaştırma)
      selectedBreedOption = breedList.firstWhereOrNull((opt) => opt.id?.toLowerCase() == breedKey?.toLowerCase());
      print('DEBUG: Initial Breed Selection: ${selectedBreedOption?.value ?? "Yok"} (Key: ${breedKey})');

      selectedSexOption = sexList.firstWhereOrNull((opt) => opt.id?.toLowerCase() == sexKey?.toLowerCase());
      print('DEBUG: Initial Sex Selection: ${selectedSexOption?.value ?? "Yok"} (Key: ${sexKey})');

      // TrackingMethod (Key alanı trackingMethod olarak adlandırılmış) (Case-insensitive karşılaştırma)
      selectedTrackingMethodOption = trackingMethodList.firstWhereOrNull((opt) => opt.id?.toLowerCase() == trackingMethod?.toLowerCase());
      print('DEBUG: Initial TrackingMethod Selection: ${selectedTrackingMethodOption?.value ?? "Yok"} (Key: ${trackingMethod})');

      // TODO: Eğer color, colorDisp alanları için de dropdown varsa, onların da başlangıç seçimleri burada yapılmalı.
  }


  // Değer Listelerini Çekme Aksiyonu (Aynı kalacak)
  @action
  Future<void> fetchValueLists() async { /* ... aynı kod ... */
     if (familyList.isNotEmpty) { return; }
     isValueListsLoading = true; valueListsErrorMessage = null;
     try {
       final results = await Future.wait([
          _animalService.getValueList('FAMILY'),
          _animalService.getValueList('SEX'),
          _animalService.getValueList('BREED_TYPE'),
          _animalService.getValueList('TRACKING_METHODS'),
       ]);
       runInAction(() {
          familyList = ObservableList.of(results[0] ?? []);
          sexList = ObservableList.of(results[1] ?? []);
          breedList = ObservableList.of(results[2] ?? []);
          trackingMethodList = ObservableList.of(results[3] ?? []);
       });
       print('DEBUG: Temel değer listeleri çekildi: ${familyList.length} Family, ${sexList.length} Sex, ${breedList.length} BreedType, ${trackingMethodList.length} TrackingMethods.');
     } catch (e) {
       valueListsErrorMessage = e.toString(); print('DEBUG: Değer listeleri çekme sırasında hata: $valueListsErrorMessage');
       runInAction(() { familyList = ObservableList(); sexList = ObservableList(); breedList = ObservableList(); trackingMethodList = ObservableList(); });
     } finally { isValueListsLoading = false; }
   }

   // Bağımlı Değer Listesini Çekme Aksiyonu (Endpoint isimleri güncellendi - Aynı kalacak)
   @action
   Future<void> fetchRaces(String familyId) async { /* ... aynı kod ... */
      runInAction(() { raceList = ObservableList(); selectedRaceOption = null; race = null; raceKey = null; });
      if (familyId.isNotEmpty && familyId != '0') { valueListsErrorMessage = null; try {
           final fetchedRaces = await _animalService.getDependentValueList('Race', familyId);
           runInAction(() { raceList = ObservableList.of(fetchedRaces ?? []); });
            print('DEBUG: Bağımlı Race listesi çekildi (${raceList.length} kayıt) Family ID: $familyId.');
         } catch (e) {
            valueListsErrorMessage = e.toString(); print('DEBUG: Bağımlı Race listesi çekme sırasında hata (Race/$familyId): $valueListsErrorMessage');
             runInAction(() { raceList = ObservableList(); });
         } finally { /* ... finally ... */ }
      }
   }


  // Düzenleme için hayvan verisini store'a yükleyen aksiyon (Aynı kalacak)
  @action
  void loadAnimalForEdit(Animal animal) { /* ... observable değişkenleri set etme ... */
     runInAction(() {
       id = animal.id; 
       name = animal.name; 
       alternateName = animal.alternateName;
       passportNumber = animal.passportNumber; 
       family = animal.family; 
       familyKey = animal.familyKey;
       race = animal.race; 
       raceKey = animal.raceKey; 
       breed = animal.breed; 
       breedKey = animal.breedKey;
       bloodGroup = animal.bloodGroup;
       sex = animal.sex; 
       sexKey = animal.sexKey; trackingMethodDisp = animal.trackingMethodDisp; trackingMethod = animal.trackingMethod;
       color = animal.color; colorDisp = animal.colorDisp; birthDate = animal.birthDate;
       markings = animal.markings; exceptions = animal.exceptions; trackingID = animal.trackingID;
       tracerLocation = animal.tracerLocation; owner = animal.owner; ownerId = animal.ownerId;
       createdAt = animal.createdAt; createdBy = animal.createdBy; updatedAt = animal.updatedAt; updatedBy = animal.updatedBy;
        errorMessage = null; isLoading = false;
     });
  }

  // Ekleme modu için formu resetleyen aksiyon (Aynı kalacak)
  @action
  void resetForm() { /* ... observable değişkenleri null set etme ... */
     runInAction(() {
       id = null; name = null; alternateName = null; passportNumber = null;
       family = null; familyKey = null; race = null; raceKey = null;
       breed = null; breedKey = null;
       bloodGroup = null;
       sex = null; sexKey = null; trackingMethodDisp = null; trackingMethod = null;
       color = null; colorDisp = null; birthDate = null;
       markings = null; exceptions = null; trackingID = null; tracerLocation = null;
       owner = null; ownerId = null; createdAt = null; createdBy = null;
       updatedAt = null; updatedBy = null;

       selectedFamilyOption = null; selectedRaceOption = null; selectedBreedOption = null;
       selectedSexOption = null; selectedTrackingMethodOption = null;

        errorMessage = null; isLoading = false; isValueListsLoading = false; valueListsErrorMessage = null;
     });
  }


  // Kaydetme Aksiyonu (Aynı kalacak)
  @action
  Future<bool> saveAnimal() async { /* ... aynı kod ... */
    isLoading = true; errorMessage = null;
    try {
       String? birthDateForBackend = birthDate;
       print('DEBUG: Doğum tarihi backend için hazırlanıyor: $birthDateForBackend');
       final animalToSave = Animal(
        id: id, name: name, alternateName: alternateName, passportNumber: passportNumber,
        familyKey: selectedFamilyOption?.id ?? familyKey,
        raceKey: selectedRaceOption?.id ?? raceKey,
        breedKey: selectedBreedOption?.id ?? breedKey,
        bloodGroup: bloodGroup,
        sexKey: selectedSexOption?.id ?? sexKey,
        trackingMethod: selectedTrackingMethodOption?.id ?? trackingMethod,
        color: color, colorDisp: colorDisp,
        birthDate: birthDateForBackend,
        markings: markings, exceptions: exceptions,
        trackingID: trackingID, tracerLocation: tracerLocation,
        ownerId: ownerId,
        createdAt: null, createdBy: null, updatedAt: null, updatedBy: null,
      );
       print('DEBUG: saveAnimal - Oluşturulan Animal objesi (toJson sonrası): ${animalToSave.toJson()}');
      final savedAnimal = await _animalService.saveOrUpdateAnimal(animalToSave);
       runInAction(() {
         if (savedAnimal != null) {
            id = savedAnimal.id; name = savedAnimal.name; alternateName = savedAnimal.alternateName;
            passportNumber = savedAnimal.passportNumber; family = savedAnimal.family; familyKey = savedAnimal.familyKey;
            race = savedAnimal.race; raceKey = savedAnimal.raceKey; breed = savedAnimal.breed; breedKey = savedAnimal.breedKey;
            bloodGroup = savedAnimal.bloodGroup;
            sex = savedAnimal.sex; sexKey = savedAnimal.sexKey; trackingMethodDisp = savedAnimal.trackingMethodDisp; trackingMethod = savedAnimal.trackingMethod;
            color = savedAnimal.color; colorDisp = savedAnimal.colorDisp; birthDate = savedAnimal.birthDate;
            markings = savedAnimal.markings; exceptions = savedAnimal.exceptions; trackingID = savedAnimal.trackingID;
            tracerLocation = savedAnimal.tracerLocation; owner = savedAnimal.owner; ownerId = savedAnimal.ownerId;
            createdAt = savedAnimal.createdAt; createdBy = savedAnimal.createdBy;
            updatedAt = savedAnimal.updatedAt; updatedBy = savedAnimal.updatedBy;
             setInitialDropdownSelections();
            print('DEBUG: Hayvan başarıyla kaydedildi/güncellendi (Store güncellendi).');
         } else {
           errorMessage = 'Kaydetme işlemi başarılı ancak kaydedilen hayvan bilgisi yanıtta dönmedi.';
           print('DEBUG: Kaydetme Başarılı (Objesiz Yanıt): $errorMessage');
         }
       });
      isLoading = false; return savedAnimal != null;
    } catch (e) {
      errorMessage = e.toString(); print('DEBUG: saveAnimal Aksiyonunda Hata: $errorMessage');
      isLoading = false; return false;
    }
  }

  // Aksiyonlar: Dropdown seçimlerini yönetme (Aynı kalacak)
  @action void setFamily(ValueOption? option) { runInAction(() { selectedFamilyOption = option; family = option?.value; familyKey = option?.id; }); fetchRaces(option?.id ?? ''); }
  @action void setRace(ValueOption? option) { runInAction(() { selectedRaceOption = option; race = option?.value; raceKey = option?.id; }); }
  @action void setBreed(ValueOption? option) { runInAction(() { selectedBreedOption = option; breed = option?.value; breedKey = option?.id; }); }
  @action void setSex(ValueOption? option) { runInAction(() { selectedSexOption = option; sex = option?.value; sexKey = option?.id; }); }
  @action void setTrackingMethod(ValueOption? option) { runInAction(() { selectedTrackingMethodOption = option; trackingMethodDisp = option?.value; trackingMethod = option?.id; }); }

  // TODO: Form validasyon mantığı
}

extension ValueOptionListExtension on List<ValueOption> {
  ValueOption? firstWhereId(String? id) {
    if (id == null || id.isEmpty) return null;
    // ✨ Case-insensitive karşılaştırma için toLowerCase() kullanıldı ✨
    return firstWhereOrNull((option) => option.id?.toLowerCase() == id.toLowerCase());
  }
}