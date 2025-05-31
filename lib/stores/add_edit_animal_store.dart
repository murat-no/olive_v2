// lib/stores/add_edit_animal_store.dart

import 'package:mobx/mobx.dart';
import 'package:olive_v2/models/animal.dart'; // Güncel Animal modelini kullanacak
import 'package:olive_v2/models/value_option.dart';
import 'package:olive_v2/services/animal_service.dart';
import 'package:olive_v2/stores/base_store.dart';
import 'package:collection/collection.dart';
import 'dart:convert'; // JsonEncoder için

part 'add_edit_animal_store.g.dart';

class AddEditAnimalStore = _AddEditAnimalStore with _$AddEditAnimalStore;

abstract class _AddEditAnimalStore extends BaseStore with Store {
  final AnimalService _animalService = AnimalService();

  @observable
  bool isValueListsLoading = false;
  @observable
  String? valueListsErrorMessage;
  @observable
  bool isInitializing = false;

  // Form alanlarına karşılık gelen Observable değişkenler (Animal modeline göre yeni adlar)
  @observable String? id;
  @observable String? name;
  @observable String? alternateName;
  @observable String? passportNumber;
  @observable String? family;
  @observable String? familyId;
  @observable String? race;
  @observable String? raceId; // <--- Burası observable kalmalı
  @observable String? breed;
  @observable String? breedId;
  @observable String? bloodGroup;
  @observable String? sex;
  @observable String? sexId;
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


  // Initialization metodu
  @action
  Future<void> initialize(Animal? animalToEdit) async {
    isInitializing = true;
    valueListsErrorMessage = null;
    super.errorMessage = null;

    try {
      if (animalToEdit == null) {
        resetForm(); // Yeni kayıt modu
      }
      await fetchValueLists(); // Her iki durumda da listeleri çek
      if (animalToEdit != null) {
        loadAnimalForEdit(animalToEdit); // Düzenleme modu
        await setInitialDropdownSelections();
      }
    } catch (e) {
      super.errorMessage = e.toString();
    } finally {
      isInitializing = false;
    }
  }


  // Yüklü hayvan verisine göre Dropdown başlangıç seçimlerini set et
  @action
  Future<void> setInitialDropdownSelections() async {
    final String? currentFamilyId = familyId;
    final String? currentRaceId = raceId;

    selectedFamilyOption = familyList.firstWhereId(currentFamilyId);
    if (selectedFamilyOption?.value != null && selectedFamilyOption!.value!.isNotEmpty) {
      await fetchRacesByValue(selectedFamilyOption!.value!);
      runInAction(() {
        selectedRaceOption = raceList.firstWhereId(currentRaceId);
      });
    } else {
      runInAction(() {
        raceList = ObservableList();
        selectedRaceOption = null;
        race = null;
        raceId = null;
      });
    }
    // Diğer dropdown atamalarını da bir runInAction içine almak daha güvenli olabilir
    runInAction(() {
      selectedBreedOption = breedList.firstWhereId(breedId);
      selectedSexOption = sexList.firstWhereId(sexId);
      selectedTrackingMethodOption = trackingMethodList.firstWhereId(trackingMethod);
    });
  }


  @action
  Future<void> fetchValueLists() async {
    if (familyList.isNotEmpty) {
      return;
    }

    isValueListsLoading = true;
    valueListsErrorMessage = null;

    final results = await execute<List<List<ValueOption>>>(
      () async {
        final List<ValueOption>? family = await _animalService.getValueList('FAMILY');
        final List<ValueOption>? sex = await _animalService.getValueList('SEX');
        final List<ValueOption>? breed = await _animalService.getValueList('BREED_TYPE');
        final List<ValueOption>? trackingMethods = await _animalService.getValueList('TRACKING_METHODS');

        return [family ?? [], sex ?? [], breed ?? [], trackingMethods ?? []];
      },
      customErrorMessage: 'Temel değer listeleri çekilirken bir hata oluştu.',
      onError: (error) {
        runInAction(() {
          valueListsErrorMessage = error;
          familyList = ObservableList();
          sexList = ObservableList();
          breedList = ObservableList();
          trackingMethodList = ObservableList();
        });
      },
      showLoading: false,
      clearErrorOnStart: false,
    );

    if (results != null) {
      runInAction(() {
        familyList = ObservableList.of(results[0]);
        sexList = ObservableList.of(results[1]);
        breedList = ObservableList.of(results[2]);
        trackingMethodList = ObservableList.of(results[3]);
      });
    }
    isValueListsLoading = false;
  }

  @action
  Future<void> fetchRacesByValue(String familyValue) async {
    runInAction(() {
      raceList = ObservableList();
      selectedRaceOption = null;
      race = null;
      raceId = null;
    });

    if (familyValue.isEmpty) {
      return;
    }

    final String backendSubtype = familyValue;

    valueListsErrorMessage = null;

    final fetchedRaces = await execute<List<ValueOption>>(
      () async {
        final result = await _animalService.getDependentValueList('RACE', backendSubtype);
        if (result == null) {
          throw Exception('Race listesi boş geldi.');
        }
        return result;
      },
      customErrorMessage: 'Bağımlı Race listesi çekilirken hata oluştu (RACE/$backendSubtype).',
      onError: (error) {
        runInAction(() {
          valueListsErrorMessage = error;
          raceList = ObservableList();
        });
      },
      showLoading: false,
      clearErrorOnStart: false,
    );

    if (fetchedRaces != null) {
      runInAction(() {
        raceList = ObservableList.of(fetchedRaces);
      });
    }
  }

@action
  void loadAnimalForEdit(Animal animal) {
    runInAction(() {
      id = animal.id;
      name = animal.name;
      alternateName = animal.alternateName;
      passportNumber = animal.passportNumber;
      family = animal.family;
      familyId = animal.familyId; // Yeni ad
      race = animal.race;
      raceId = animal.raceId; // Yeni ad
      breed = animal.breed;
      breedId = animal.breedId; // Yeni ad
      bloodGroup = animal.bloodGroup;
      sex = animal.sex;
      sexId = animal.sexId; // Yeni ad
      trackingMethodDisp = animal.trackingMethodDisp;
      trackingMethod = animal.trackingMethod;
      color = animal.color; // Yeni ad
      colorDisp = animal.colorDisp; // colorDisp hala varsa
      birthDate = animal.birthDate;
      markings = animal.markings;
      exceptions = animal.exceptions;
      trackingID = animal.trackingID;
      tracerLocation = animal.tracerLocation;
      owner = animal.owner;
      ownerId = animal.ownerId;
      createdAt = animal.createdAt;
      createdBy = animal.createdBy;
      updatedAt = animal.updatedAt;
      updatedBy = animal.updatedBy;
    });
  }

  // Ekleme modu için formu resetleyen aksiyon
  @action
  void resetForm() {
    runInAction(() {
      id = null; name = null; alternateName = null; passportNumber = null;
      family = null; familyId = null; race = null; raceId = null; // Yeni adlar
      breed = null; breedId = null; // Yeni ad
      bloodGroup = null;
      sex = null; sexId = null; trackingMethodDisp = null; trackingMethod = null; // Yeni adlar
      color = null; // Yeni ad
      colorDisp = null; // colorDisp hala varsa
      birthDate = null;
      markings = null; exceptions = null; trackingID = null; tracerLocation = null;
      owner = null; ownerId = null; createdAt = null; createdBy = null;
      updatedAt = null; updatedBy = null;

      selectedFamilyOption = null; selectedRaceOption = null; selectedBreedOption = null;
      selectedSexOption = null; selectedTrackingMethodOption = null;

      super.errorMessage = null;
      super.isLoading = false;
      isValueListsLoading = false;
      valueListsErrorMessage = null;
    });
  }

  // Kaydetme Aksiyonu
  @action
  Future<bool> saveAnimal() async {
    final animalToSave = Animal(
      id: id, name: name, alternateName: alternateName, passportNumber: passportNumber,
      familyId: selectedFamilyOption?.id ?? familyId, // Yeni ad
      raceId: selectedRaceOption?.id ?? raceId,       // Yeni ad
      breedId: selectedBreedOption?.id ?? breedId,   // Yeni ad
      bloodGroup: bloodGroup,
      sexId: selectedSexOption?.id ?? sexId,         // Yeni ad
      trackingMethod: selectedTrackingMethodOption?.id ?? trackingMethod,
      color: color, // Yeni ad
      colorDisp: colorDisp, // colorDisp hala varsa
      birthDate: birthDate,
      markings: markings, exceptions: exceptions,
      trackingID: trackingID, tracerLocation: tracerLocation,
      ownerId: ownerId,
      createdAt: null, createdBy: null, updatedAt: null, updatedBy: null,
    );

    final savedAnimal = await execute<Animal>(
      () async {
        final result = await _animalService.saveOrUpdateAnimal(animalToSave);
        if (result == null) {
          throw Exception('Kaydetme işlemi başarılı ancak kaydedilen hayvan bilgisi yanıtta dönmedi.');
        }
        return result;
      },
      customErrorMessage: 'Hayvan kaydedilirken/güncellenirken bir hata oluştu.',
      showLoading: true,
      clearErrorOnStart: true,
    );

    if (savedAnimal != null) {
      runInAction(() {
        // Backend'den dönen veriyi atama
        id = savedAnimal.id;
        name = savedAnimal.name;
        alternateName = savedAnimal.alternateName;
        passportNumber = savedAnimal.passportNumber;
        family = savedAnimal.family;
        familyId = savedAnimal.familyId; // Yeni ad
        race = savedAnimal.race;
        raceId = savedAnimal.raceId;     // Yeni ad
        breed = savedAnimal.breed;
        breedId = savedAnimal.breedId;   // Yeni ad
        bloodGroup = savedAnimal.bloodGroup;
        sex = savedAnimal.sex;
        sexId = savedAnimal.sexId;       // Yeni ad
        trackingMethodDisp = savedAnimal.trackingMethodDisp;
        trackingMethod = savedAnimal.trackingMethod;
        color = savedAnimal.color; // Yeni ad
        colorDisp = savedAnimal.colorDisp; // colorDisp hala varsa
        birthDate = savedAnimal.birthDate;
        markings = savedAnimal.markings;
        exceptions = savedAnimal.exceptions;
        trackingID = savedAnimal.trackingID;
        tracerLocation = savedAnimal.tracerLocation;
        owner = savedAnimal.owner;
        ownerId = savedAnimal.ownerId;
        createdAt = savedAnimal.createdAt;
        createdBy = savedAnimal.createdBy;
        updatedAt = savedAnimal.updatedAt;
        updatedBy = savedAnimal.updatedBy;


        setInitialDropdownSelections();
      });
      return true;
    } else {
      return false;
    }
  }

  // Aksiyonlar: Dropdown seçimlerini yönetme (Yeni adlar)
  @action
  void setFamily(ValueOption? option) {
    runInAction(() {
      selectedFamilyOption = option;
      family = option?.displayText;
      familyId = option?.id; // Yeni ad
    });
    fetchRacesByValue(option?.value ?? '');
  }

  @action
  void setRace(ValueOption? option) {
    runInAction(() {
      selectedRaceOption = option;
      race = option?.displayText;
      raceId = option?.id; // Yeni ad
    });
  }

  @action
  void setBreed(ValueOption? option) {
    runInAction(() {
      selectedBreedOption = option;
      breed = option?.displayText;
      breedId = option?.id; // Yeni ad
    });
  }

  @action
  void setSex(ValueOption? option) {
    runInAction(() {
      selectedSexOption = option;
      sex = option?.displayText;
      sexId = option?.id; // Yeni ad
    });
  }

  @action
  void setTrackingMethod(ValueOption? option) {
    runInAction(() {
      selectedTrackingMethodOption = option;
      trackingMethodDisp = option?.displayText;
      trackingMethod = option?.id;
    });
  }


  // TODO: Form validasyon mantığı
}

extension ValueOptionListExtension on List<ValueOption> {
  ValueOption? firstWhereValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final result = firstWhereOrNull((option) => option.valueLower == value.toLowerCase());
    return result;
  }

  ValueOption? firstWhereId(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }
    for (var option in this) {
      if (option.idLower == id.toLowerCase()) {
        return option;
      }
    }
    return null;
  }
}