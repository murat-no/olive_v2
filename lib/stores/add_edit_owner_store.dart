import 'package:mobx/mobx.dart';
import 'package:olive_v2/models/owner.dart';
import 'package:olive_v2/models/value_option.dart';
import 'package:olive_v2/services/owner_service.dart';
import 'package:olive_v2/services/location_service.dart';
import 'package:olive_v2/stores/base_store.dart';
import 'package:collection/collection.dart';
import 'package:olive_v2/config/app_config.dart';

part 'add_edit_owner_store.g.dart';

class AddEditOwnerStore = _AddEditOwnerStore with _$AddEditOwnerStore;

abstract class _AddEditOwnerStore extends BaseStore with Store {
  final OwnerService _ownerService = OwnerService();
  final LocationService _locationService = LocationService();

  @observable
  bool isInitializing = false;
  @observable
  bool isValueListsLoading = false;
  @observable
  String? valueListsErrorMessage;

  // Form alanlarına karşılık gelen Observable değişkenler (Owner modeline göre)
  @observable
  String? id;
  @observable
  String? nationalId;
  @observable
  String? firstName;
  @observable
  String? lastName;
  @observable
  String? address;
  @observable
  String? country; // Ülke key (ID) - Türkiye'nin ID'si olacak
  @observable
  String? city; // Şehir key (ID)
  @observable
  String? cityDisp; // Sadece görüntüleme için
  @observable
  String? district; // İlçe key (ID)
  @observable
  String? districtDisp; // Sadece görüntüleme için
  @observable
  String? zipCode;
  @observable
  String? email;
  @observable
  String? phone;
  @observable
  String? mobilePhone;
  @observable
  String? contactId;
  @observable
  String? contactName;
  @observable
  List<OwnerAnimalSummary>? animals;
  @observable
  DateTime? createdAt;
  @observable
  int? createdBy;
  @observable
  DateTime? updatedAt;
  @observable
  int? updatedBy;

  // Değer Listeleri
  @observable
  ObservableList<ValueOption> cityList = ObservableList<ValueOption>();
  @observable
  ObservableList<ValueOption> districtList = ObservableList<ValueOption>();

  // Seçili Değerler
  @observable
  ValueOption? selectedCityOption;
  @observable
  ValueOption? selectedDistrictOption;

  // Initialization metodu
  @action
  Future<void> initialize(Owner? ownerToEdit) async {
    isInitializing = true;
    valueListsErrorMessage = null;
    super.errorMessage = null;

    try {
      resetForm();
      country =
          kTurkeyLocationKey; // Ülkeyi sabit "Türkiye" ID'si olarak ayarla

      await fetchValueLists(); // İlk şehir listesini çekmek için çağır

      if (ownerToEdit != null) {
        loadOwnerForEdit(ownerToEdit);
        await setInitialDropdownSelections();
      }
    } catch (e) {
      print('DEBUG: AddEditOwnerStore Initialization Error: $e');
      super.errorMessage = e.toString();
    } finally {
      isInitializing = false;
    }
  }

  // Yüklü sahip verisine göre Dropdown başlangıç seçimlerini set et
  @action
  Future<void> setInitialDropdownSelections() async {
    print(
        'DEBUG: AddEditOwnerStore: setInitialDropdownSelections called. Current Owner ID: $id');
    print('DEBUG: Current city: "$city", district: "$district"');

    // ✨ KRİTİK YENİ PRINTS: Liste içeriklerini ve eşleşme durumlarını logla ✨
    print('DEBUG: cityList contains ${cityList.length} items.');
    if (cityList.isNotEmpty) {
      print(
          'DEBUG:   First city item ID: "${cityList.first.id}" (Lower: "${cityList.first.idLower}")');
      print(
          'DEBUG:   city (lowercased) found in cityList.idLower? ${cityList.any((opt) => opt.idLower == city?.toLowerCase())}');
    }

    print('DEBUG: districtList contains ${districtList.length} items.');
    if (districtList.isNotEmpty) {
      print(
          'DEBUG:   First district item ID: "${districtList.first.id}" (Lower: "${districtList.first.idLower}")');
      print(
          'DEBUG:   district (lowercased) found in districtList.idLower? ${districtList.any((opt) => opt.idLower == district?.toLowerCase())}');
    }

    // Şehir (Türkiye'nin ID'si ile bağımlı olarak çekilmeli)
    // fetchValueLists zaten çağrıldığı için cityList dolu olmalı
    selectedCityOption = cityList.firstWhereId(
        city); // city alanı zaten ID olduğu için firstWhereId ile arıyoruz
    print(
        'DEBUG: Initial City Selection: ${selectedCityOption?.displayText ?? "None"} (Key: "$city")');

    // Şehir (Türkiye'nin ID'si ile bağımlı olarak çekilmeli)
    // fetchValueLists zaten çağrıldığı için cityList dolu olmalı
    selectedCityOption = cityList.firstWhereId(
        city); // city alanı zaten ID olduğu için firstWhereId ile arıyoruz
    print(
        'DEBUG: Initial City Selection: ${selectedCityOption?.displayText ?? "None"} (Key: $city)');

    // İlçe (Şehir seçildiğinde bağımlı olarak çekilmeli)
    if (selectedCityOption?.id != null && selectedCityOption!.id!.isNotEmpty) {
      await fetchDistricts(selectedCityOption!.id!);
      selectedDistrictOption = districtList.firstWhereId(district);
      print(
          'DEBUG: Initial District Selection: ${selectedDistrictOption?.displayText ?? "None"} (Key: $district)');
    } else {
      runInAction(() {
        districtList = ObservableList();
        selectedDistrictOption = null;
      });
    }
  }

  // Değer Listelerini Çekme Aksiyonu (Sadece Şehir ve İlçe için geçerli, ülke sabit)
  @action
  Future<void> fetchValueLists() async {
    if (cityList.isNotEmpty) {
      print(
          'DEBUG: AddEditOwnerStore: City lists already loaded, skipping fetch.');
      return;
    }

    isValueListsLoading = true;
    valueListsErrorMessage = null;

    final fetchedCities = await execute<List<ValueOption>>(
      () async {
        final result =
            await _locationService.fetchLocations('CITY', parentKey: country!);
        if (result == null) {
          throw Exception('Şehir listesi boş geldi.');
        }
        return result;
      },
      customErrorMessage: 'Şehir listeleri çekilirken bir hata oluştu.',
      onError: (error) {
        runInAction(() {
          valueListsErrorMessage = error;
          cityList = ObservableList();
        });
      },
      showLoading: false,
      clearErrorOnStart: false,
    );

    if (fetchedCities != null) {
      runInAction(() {
        cityList = ObservableList.of(fetchedCities);
        print(
            'DEBUG: AddEditOwnerStore: Şehir listesi çekildi (${cityList.length} kayıt) Country ID: $country.');
      });
    }
    isValueListsLoading = false;
  }

  // Bağımlı İlçe listesi çekme
  @action
  Future<void> fetchDistricts(String cityId) async {
    runInAction(() {
      districtList = ObservableList();
      selectedDistrictOption = null;
    });
    if (cityId.isEmpty || cityId == '0') {
      return;
    }

    valueListsErrorMessage = null;
    final fetchedDistricts = await execute<List<ValueOption>>(
      () async {
        final result = await _locationService.fetchLocations('DISTRICT',
            parentKey: cityId);
        if (result == null) {
          throw Exception('İlçe listesi boş geldi.');
        }
        return result;
      },
      customErrorMessage:
          'Bağımlı İlçe listesi çekilirken hata oluştu (DISTRICT/$cityId).',
      onError: (error) {
        runInAction(() {
          valueListsErrorMessage = error;
          districtList = ObservableList();
        });
      },
      showLoading: false,
      clearErrorOnStart: false,
    );
    if (fetchedDistricts != null) {
      runInAction(() {
        districtList = ObservableList.of(fetchedDistricts);
        print(
            'DEBUG: AddEditOwnerStore: İlçe listesi çekildi (${districtList.length} kayıt) City ID: $cityId.');
      });
    }
  }

  // Düzenleme için sahip verisini store'a yükleyen aksiyon
  @action
  void loadOwnerForEdit(Owner owner) {
    print(
        'DEBUG: AddEditOwnerStore: loadOwnerForEdit called for owner: ${owner.fullName} (ID: ${owner.id})');
    runInAction(() {
      id = owner.id;
      nationalId = owner.nationalId;
      firstName = owner.firstName;
      lastName = owner.lastName;
      address = owner.address;
      country = owner.country;
      city = owner.city;
      cityDisp = owner.cityDisp;
      district = owner.district;
      districtDisp = owner.districtDisp;
      zipCode = owner.zipCode;
      email = owner.email;
      phone = owner.phone;
      mobilePhone = owner.mobilePhone;
      contactId = owner.contactId;
      contactName = owner.contactName;
      animals = owner.animals;
      createdAt = owner.createdAt;
      createdBy = owner.createdBy;
      updatedAt = owner.updatedAt;
      updatedBy = owner.updatedBy;

      // ✨ KRİTİK YENİ PRINTS: Atanan alan değerlerini hemen yükledikten sonra logla ✨
      print('DEBUG: AddEditOwnerStore: Store fields assigned:');
      print('  nationalId: "$nationalId"');
      print('  firstName: "$firstName"');
      print('  lastName: "$lastName"');
      print('  address: "$address"');
      print('  zipCode: "$zipCode"');
      print('  email: "$email"');
      print('  phone: "$phone"');
      print('  mobilePhone: "$mobilePhone"');
      print('  contactId: "$contactId"');
      print('  contactName: "$contactName"');
      print('  country: "$country"'); // Özellikle kontrol et
      print('  city: "$city"'); // Özellikle kontrol et
      print('  district: "$district"'); // Özellikle kontrol et
      print(
          'DEBUG: AddEditOwnerStore: Store fields updated. Initializing status: $isInitializing');
    });
  }

  // Formu resetleyen aksiyon
  @action
  void resetForm() {
    runInAction(() {
      id = null;
      nationalId = null;
      firstName = null;
      lastName = null;
      address = null;
      city = null;
      cityDisp = null;
      district = null;
      districtDisp = null;
      zipCode = null;
      email = null;
      phone = null;
      mobilePhone = null;
      contactId = null;
      contactName = null;
      animals = null;
      createdAt = null;
      createdBy = null;
      updatedAt = null;
      updatedBy = null;

      selectedCityOption = null;
      selectedDistrictOption = null;

      super.errorMessage = null;
      super.isLoading = false;
      isValueListsLoading = false;
      valueListsErrorMessage = null;
    });
    country = kTurkeyLocationKey; // Resetlerken ülkeyi tekrar Türkiye'ye ayarla
  }

  // Kaydetme Aksiyonu
  @action
  Future<bool> saveOwner() async {
    final savedOwner = await execute<Owner>(
      () async {
        final ownerToSave = Owner(
          id: id,
          nationalId: nationalId,
          firstName: firstName,
          lastName: lastName,
          address: address,
          country: country,
          city: selectedCityOption?.id ?? city,
          district: selectedDistrictOption?.id ?? district,
          zipCode: zipCode,
          email: email,
          phone: phone,
          mobilePhone: mobilePhone,
          contactId: contactId,
          createdAt: null,
          createdBy: null,
          updatedAt: null,
          updatedBy: null,
          animals: null,
        );
        print(
            'DEBUG: AddEditOwnerStore saveOwner - Created Owner object (after toJson): ${ownerToSave.toJson()}');

        final result = await _ownerService.saveOrUpdateOwner(ownerToSave);
        if (result == null) {
          throw Exception(
              'Kaydetme işlemi başarılı ancak kaydedilen sahip bilgisi yanıtta dönmedi.');
        }
        return result;
      },
      customErrorMessage: 'Sahip kaydedilirken/güncellenirken bir hata oluştu.',
      showLoading: true,
      clearErrorOnStart: true,
    );

    if (savedOwner != null) {
      runInAction(() {
        id = savedOwner.id;
        nationalId = savedOwner.nationalId;
        firstName = savedOwner.firstName;
        lastName = savedOwner.lastName;
        address = savedOwner.address;
        country = savedOwner.country;
        city = savedOwner.city;
        cityDisp = savedOwner.cityDisp;
        district = savedOwner.district;
        districtDisp = savedOwner.districtDisp;
        zipCode = savedOwner.zipCode;
        email = savedOwner.email;
        phone = savedOwner.phone;
        mobilePhone = savedOwner.mobilePhone;
        contactId = savedOwner.contactId;
        contactName = savedOwner.contactName;
        animals = savedOwner.animals;
        createdAt = savedOwner.createdAt;
        createdBy = savedOwner.createdBy;
        updatedAt = savedOwner.updatedAt;
        updatedBy = savedOwner.updatedBy;
        setInitialDropdownSelections();
        print(
            'DEBUG: AddEditOwnerStore: Sahip başarıyla kaydedildi/güncellendi (Store güncellendi).');
      });
      return true;
    } else {
      print(
          'DEBUG: AddEditOwnerStore: Kaydetme/güncelleme başarısız veya obje yanıt dönmedi.');
      return false;
    }
  }

  // Aksiyonlar: Dropdown seçimlerini yönetme
  @action
  void setCity(ValueOption? option) {
    runInAction(() {
      selectedCityOption = option;
      city = option?.id;
      cityDisp = option?.displayText; // UI için displayText
      districtList = ObservableList();
      selectedDistrictOption = null;
    });
    fetchDistricts(option?.id ?? '');
  }

  @action
  void setDistrict(ValueOption? option) {
    runInAction(() {
      selectedDistrictOption = option;
      district = option?.id;
      districtDisp = option?.displayText; // UI için displayText
    });
  }

  // TODO: Form validasyon mantığı
}

extension ValueOptionListExtension on List<ValueOption> {
  // Bu extension'lar artık ValueOption.idLower ve ValueOption.valueLower'ı kullanacak
  ValueOption? firstWhereValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return firstWhereOrNull(
        (option) => option.valueLower == value.toLowerCase());
  }

  ValueOption? firstWhereId(String? id) {
    if (id == null || id.isEmpty) return null;
    return firstWhereOrNull((option) => option.idLower == id.toLowerCase());
  }
}
