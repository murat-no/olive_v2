// lib/screens/add_edit_animal_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:olive_v2/stores/add_edit_animal_store.dart';
import 'package:olive_v2/models/animal.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:olive_v2/widgets/custom_date_picker_field.dart';
import 'package:olive_v2/widgets/custom_dropdown_form_field.dart';
import 'package:olive_v2/screens/owner_selection_screen.dart';
import 'package:olive_v2/models/owner.dart';

class AddEditAnimalScreen extends StatefulWidget {
  final Animal? animalToEdit;

  const AddEditAnimalScreen({super.key, this.animalToEdit});

  @override
  _AddEditAnimalScreenState createState() => _AddEditAnimalScreenState();
}

class _AddEditAnimalScreenState extends State<AddEditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddEditAnimalStore _addEditAnimalStore;

  late TextEditingController _nameController;
  late TextEditingController _alternateNameController;
  late TextEditingController _passportNumberController;
  late TextEditingController _colorController;
  late TextEditingController _colorDispController;
  late TextEditingController _birthDateController;
  late TextEditingController _markingsController;
  late TextEditingController _exceptionsController;
  late TextEditingController _trackingIDController;
  late TextEditingController _tracerLocationController;
  late TextEditingController _ownerController;
  late TextEditingController _bloodGroupController;

  // MobX Reaction'ları için Disposer listesi (artık sadece tek bir 'when' için kullanılabilir)
  final List<ReactionDisposer> _disposers = [];


  @override
  void initState() {
    super.initState();
    print('DEBUG: AddEditAnimalScreen initState - Initializing Controllers.');

    // Controllers boş olarak başlatılacak.
    _nameController = TextEditingController();
    _alternateNameController = TextEditingController();
    _passportNumberController = TextEditingController();
    _colorController = TextEditingController();
    _colorDispController = TextEditingController();
    _birthDateController = TextEditingController();
    _markingsController = TextEditingController();
    _exceptionsController = TextEditingController();
    _trackingIDController = TextEditingController();
    _tracerLocationController = TextEditingController();
    _ownerController = TextEditingController();
    _bloodGroupController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // listen: false olarak alıyoruz, çünkü bu metod içinde sadece store'u alıp initialize edeceğiz.
    // UI güncellemeleri Observer widget'ları tarafından yönetilecek.
    _addEditAnimalStore = Provider.of<AddEditAnimalStore>(context, listen: false);

    // Eğer store henüz initialize edilmediyse veya initialization bitmediyse, başlat.
    // isInitializing true ise, zaten başlatılıyor demektir, tekrar başlatma.
    if (!_addEditAnimalStore.isInitializing && !(_addEditAnimalStore.id != null && _addEditAnimalStore.id!.isNotEmpty)) {
      print('DEBUG: AddEditAnimalScreen didChangeDependencies - Initializing store (animalToEdit: ${widget.animalToEdit?.name}).');
      _addEditAnimalStore.initialize(widget.animalToEdit);

      // Store initialize edildikten sonra (yani isInitializing false olduğunda)
      // controller'ları güncellemek için bir MobX `when` reaksiyonu tanımlayalım.
      _disposers.add(
        when(
          (_) => !_addEditAnimalStore.isInitializing, // Koşul: isInitializing false olduğunda
          () { // Çalışacak aksiyon
            print('DEBUG: AddEditAnimalScreen MobX "when" triggered - Initializing finished, updating controllers.');
            // setState'i dışarıya alıp, sadece bir kez tetikleyerek tüm atamaları yapabiliriz
            setState(() {
              _nameController.text = _addEditAnimalStore.name ?? '';
              _alternateNameController.text = _addEditAnimalStore.alternateName ?? '';
              _passportNumberController.text = _addEditAnimalStore.passportNumber ?? '';
              _colorController.text = _addEditAnimalStore.color ?? '';
              _colorDispController.text = _addEditAnimalStore.colorDisp ?? '';
              _birthDateController.text = _addEditAnimalStore.birthDate ?? '';
              _markingsController.text = _addEditAnimalStore.markings ?? '';
              _exceptionsController.text = _addEditAnimalStore.exceptions ?? '';
              _trackingIDController.text = _addEditAnimalStore.trackingID ?? '';
              _tracerLocationController.text = _addEditAnimalStore.tracerLocation ?? '';
              _ownerController.text = _addEditAnimalStore.owner ?? '';
              _bloodGroupController.text = _addEditAnimalStore.bloodGroup ?? '';
               print('DEBUG: AddEditAnimalScreen - Controllers updated via setState.');
            });
          },
          // isInitializing'in ilk durumu zaten false ise bu reaksiyon tetiklenmeyecektir.
          // Ancak initialize çağrısı bu durumda (edit modunda) zaten isInitializing'i true yapıp sonra false'a çekeceği için çalışır.
        ),
      );
    } else {
      // Eğer store zaten initialize edilmişse (örn: sayfa yeniden build edildiğinde ama store değişmediyse)
      // veya zaten initializing durumundaysa, controller'ları doğrudan güncelleyebiliriz.
      // Bu kısım, sayfa açılışında `isInitializing` false iken (yeni kayıt ekranında) veya
      // initialize bitmişken (tekrar build edildiğinde) controller'ların güncellenmesini sağlar.
      // `loadAnimalForEdit` metodu bittikten sonra bu kısım çalışmaz, çünkü o MobX reaksiyonu tetikler.
      print('DEBUG: AddEditAnimalScreen didChangeDependencies - Store already initializing or initialized, updating controllers with current values.');
      _nameController.text = _addEditAnimalStore.name ?? '';
      _alternateNameController.text =_addEditAnimalStore.alternateName ?? '';
      _passportNumberController.text = _addEditAnimalStore.passportNumber ?? '';
      _colorController.text = _addEditAnimalStore.color ?? '';
      _colorDispController.text = _addEditAnimalStore.colorDisp ?? '';
      _birthDateController.text = _addEditAnimalStore.birthDate ?? '';
      _markingsController.text = _addEditAnimalStore.markings ?? '';
      _exceptionsController.text = _addEditAnimalStore.exceptions ?? '';
      _trackingIDController.text = _addEditAnimalStore.trackingID ?? '';
      _tracerLocationController.text = _addEditAnimalStore.tracerLocation ?? '';
      _ownerController.text = _addEditAnimalStore.owner ?? '';
      _bloodGroupController.text = _addEditAnimalStore.bloodGroup ?? '';
    }
  }

  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    // Controller'ları dispose et
    _nameController.dispose();
    _alternateNameController.dispose();
    _passportNumberController.dispose();
    _colorController.dispose();
    _colorDispController.dispose();
    _birthDateController.dispose();
    _markingsController.dispose();
    _exceptionsController.dispose();
    _trackingIDController.dispose();
    _tracerLocationController.dispose();
    _ownerController.dispose();
    _bloodGroupController.dispose();

    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('DEBUG: AddEditAnimalScreen: Form validated, calling save action.');
      final success = await _addEditAnimalStore.saveAnimal();

      if (success) {
        print('DEBUG: Animal saved successfully.');
        Navigator.pop(context, true);
      } else {
        print(
            'DEBUG: Animal save failed. Error: ${_addEditAnimalStore.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Kaydetme Başarısız: ${_addEditAnimalStore.errorMessage ?? "Bilinmeyen hata."}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('DEBUG: Form validation failed.');
    }
  }

  Widget _buildReadOnlyDetailRow(String label, dynamic value) {
    String? displayValue;
    if (value is String) {
      displayValue = value.isNotEmpty ? value : null;
    } else if (value != null) {
      if (value is DateTime) {
        displayValue = DateFormat('yyyy-MM-dd HH:mm').format(value);
      } else {
        displayValue = value.toString();
      }
    }
    if (displayValue != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text(displayValue),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = widget.animalToEdit == null
        ? 'Yeni Hayvan Ekle'
        : 'Hayvan Düzenle: ${_addEditAnimalStore.name ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        actions: [
          Observer(
            builder: (_) {
              return IconButton(
                icon: (_addEditAnimalStore.isLoading ||
                        _addEditAnimalStore.isInitializing)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
                tooltip: 'Kaydet',
                onPressed: (_addEditAnimalStore.isLoading ||
                        _addEditAnimalStore.isInitializing)
                    ? null
                    : _saveForm,
              );
            },
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (_addEditAnimalStore.isInitializing ||
              (_addEditAnimalStore.isValueListsLoading &&
                  _addEditAnimalStore.familyList.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          } else if (_addEditAnimalStore.valueListsErrorMessage != null) {
            return Center(
              child: Text(
                'Değer listeleri yüklenemedi: ${_addEditAnimalStore.valueListsErrorMessage!}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (_addEditAnimalStore.errorMessage != null &&
              !_addEditAnimalStore.isLoading) {
            return Center(
              child: Text(
                'Kaydetme Hatası: ${_addEditAnimalStore.errorMessage!}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Temel Bilgiler Bölümü
                  Text('Temel Bilgiler',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Adı', border: OutlineInputBorder()),
                          onChanged: (newValue) =>
                              _addEditAnimalStore.name = newValue,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen hayvanın adını girin.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomDatePickerField(
                          controller: _birthDateController,
                          labelText: 'Doğum Tarihi',
                          onDateSelected: (formattedDate) {
                            _addEditAnimalStore.birthDate = formattedDate;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen doğum tarihini girin.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _alternateNameController,
                          decoration: const InputDecoration(
                              labelText: 'Alternatif Adı',
                              border: OutlineInputBorder()),
                          onChanged: (newValue) =>
                              _addEditAnimalStore.alternateName = newValue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _passportNumberController,
                          decoration: const InputDecoration(
                              labelText: 'Pasaport Numarası',
                              border: OutlineInputBorder()),
                          onChanged: (newValue) =>
                              _addEditAnimalStore.passportNumber = newValue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _colorController,
                          decoration: const InputDecoration(
                              labelText: 'Renk', border: OutlineInputBorder()),
                          onChanged: (newValue) =>
                              _addEditAnimalStore.color = newValue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller:
                              _colorDispController, // colorDisp hala varsa
                          decoration: const InputDecoration(
                              labelText: 'Renk Tanımı',
                              border: OutlineInputBorder()),
                          onChanged: (newValue) =>
                              _addEditAnimalStore.colorDisp = newValue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _bloodGroupController,
                    decoration: const InputDecoration(
                        labelText: 'Kan Grubu (Blood Group)',
                        border: OutlineInputBorder()),
                    onChanged: (newValue) =>
                        _addEditAnimalStore.bloodGroup = newValue,
                  ),
                  const SizedBox(height: 16),

                  Text('Sahip Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ownerController,
                    decoration: const InputDecoration(
                      labelText: 'Sahip Adı',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.person_search),
                    ),
                    readOnly: true,
                    onTap: () async {
                      print(
                          'DEBUG: AddEditAnimalScreen: Sahip Seçim Alanına tıklandı, OwnerSelectionScreen açılıyor.');
                      final selectedOwner = await Navigator.push<Owner>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OwnerSelectionScreen()),
                      );

                      if (selectedOwner != null) {
                        print(
                            'DEBUG: AddEditAnimalScreen: OwnerSelectionScreen\'dan seçilen sahip: ${selectedOwner.fullName}, ID: ${selectedOwner.id}');
                        _addEditAnimalStore.owner = selectedOwner.fullName;
                        _addEditAnimalStore.ownerId = selectedOwner.id;
                        print(
                            'DEBUG: AddEditAnimalStore: Owner info updated in store. Current owner: "${_addEditAnimalStore.owner}" (ID: "${_addEditAnimalStore.ownerId}")');
                        _ownerController.text = _addEditAnimalStore.owner ??
                            ''; // Controller'ı manuel olarak güncelle
                      } else {
                        print(
                            'DEBUG: AddEditAnimalScreen: Sahip seçimi iptal edildi veya sahip seçilmedi.');
                        _addEditAnimalStore.owner = null;
                        _addEditAnimalStore.ownerId = null;
                        _ownerController.text =
                            ''; // Controller'ı manuel olarak temizle
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Sınıflandırma Bölümü
                  Text('Sınıflandırma',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Observer(builder: (_) {
                          return CustomDropdownFormField(
                            labelText: 'Tür (Family)',
                            hintText: 'Tür seçiniz',
                            options: _addEditAnimalStore.familyList.toList(),
                            selectedValueId:
                                _addEditAnimalStore.selectedFamilyOption?.id,
                            onChanged: (selectedId) {
                              final selectedOption = _addEditAnimalStore
                                  .familyList
                                  .firstWhereId(selectedId);
                              _addEditAnimalStore.setFamily(selectedOption);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen hayvanın türünü seçin.';
                              }
                              return null;
                            },
                            isLoading: _addEditAnimalStore.isValueListsLoading,
                            isEnabled: !_addEditAnimalStore.isInitializing &&
                                !_addEditAnimalStore.isValueListsLoading &&
                                _addEditAnimalStore.familyList.isNotEmpty,
                          );
                        }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Observer(builder: (_) {
                          return CustomDropdownFormField(
                            labelText: 'Irk (Race)',
                            hintText:
                                _addEditAnimalStore.selectedFamilyOption == null
                                    ? 'Tür seçiniz'
                                    : 'Irk seçiniz',
                            options: _addEditAnimalStore.raceList.toList(),
                            selectedValueId:
                                _addEditAnimalStore.selectedRaceOption?.id,
                            onChanged: (selectedId) {
                              final selectedOption = _addEditAnimalStore
                                  .raceList
                                  .firstWhereId(selectedId);
                              _addEditAnimalStore.setRace(selectedOption);
                            },
                            isLoading: _addEditAnimalStore.isValueListsLoading,
                            isEnabled:
                                _addEditAnimalStore.selectedFamilyOption !=
                                        null &&
                                    !_addEditAnimalStore.isInitializing &&
                                    !_addEditAnimalStore.isValueListsLoading &&
                                    _addEditAnimalStore.raceList.isNotEmpty,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Observer(builder: (_) {
                          return CustomDropdownFormField(
                            labelText: 'Cins (Breed)',
                            hintText: 'Cins seçiniz',
                            options: _addEditAnimalStore.breedList.toList(),
                            selectedValueId:
                                _addEditAnimalStore.selectedBreedOption?.id,
                            onChanged: (selectedId) {
                              final selectedOption = _addEditAnimalStore
                                  .breedList
                                  .firstWhereId(selectedId);
                              _addEditAnimalStore.setBreed(selectedOption);
                            },
                            isLoading: _addEditAnimalStore.isValueListsLoading,
                            isEnabled: !_addEditAnimalStore.isInitializing &&
                                !_addEditAnimalStore.isValueListsLoading &&
                                _addEditAnimalStore.breedList.isNotEmpty,
                          );
                        }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Observer(builder: (_) {
                          return CustomDropdownFormField(
                            labelText: 'Cinsiyet (Sex)',
                            hintText: 'Cinsiyet seçiniz',
                            options: _addEditAnimalStore.sexList.toList(),
                            selectedValueId:
                                _addEditAnimalStore.selectedSexOption?.id,
                            onChanged: (selectedId) {
                              final selectedOption = _addEditAnimalStore.sexList
                                  .firstWhereId(selectedId);
                              _addEditAnimalStore.setSex(selectedOption);
                            },
                            isLoading: _addEditAnimalStore.isValueListsLoading,
                            isEnabled: !_addEditAnimalStore.isInitializing &&
                                !_addEditAnimalStore.isValueListsLoading &&
                                _addEditAnimalStore.sexList.isNotEmpty,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Takip Bilgileri Bölümü
                  Text('Takip Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Observer(builder: (_) {
                          return CustomDropdownFormField(
                            labelText: 'Takip Metodu',
                            hintText: 'Takip metodu seçiniz',
                            options:
                                _addEditAnimalStore.trackingMethodList.toList(),
                            selectedValueId: _addEditAnimalStore
                                .selectedTrackingMethodOption?.id,
                            onChanged: (selectedId) {
                              final selectedOption = _addEditAnimalStore
                                  .trackingMethodList
                                  .firstWhereId(selectedId);
                              _addEditAnimalStore
                                  .setTrackingMethod(selectedOption);
                            },
                            isLoading: _addEditAnimalStore.isValueListsLoading,
                            isEnabled: !_addEditAnimalStore.isInitializing &&
                                !_addEditAnimalStore.isValueListsLoading &&
                                _addEditAnimalStore
                                    .trackingMethodList.isNotEmpty,
                          );
                        }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _trackingIDController,
                          decoration: const InputDecoration(
                              labelText: 'Takip ID',
                              border: OutlineInputBorder()),
                          onChanged: (newValue) =>
                              _addEditAnimalStore.trackingID = newValue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _tracerLocationController,
                    decoration: const InputDecoration(
                        labelText: 'Takip Konumu (Tracer Location)',
                        border: OutlineInputBorder()),
                    onChanged: (newValue) =>
                        _addEditAnimalStore.tracerLocation = newValue,
                  ),
                  const SizedBox(height: 16),

                  // Ek Bilgiler Bölümü
                  Text('Ek Bilgiler',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _markingsController,
                    decoration: const InputDecoration(
                        labelText: 'İşaretler', border: OutlineInputBorder()),
                    maxLines: 3,
                    onChanged: (newValue) =>
                        _addEditAnimalStore.markings = newValue,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _exceptionsController,
                    decoration: const InputDecoration(
                        labelText: 'İstisnalar', border: OutlineInputBorder()),
                    maxLines: 3,
                    onChanged: (newValue) =>
                        _addEditAnimalStore.exceptions = newValue,
                  ),
                  const SizedBox(height: 16),

                  // Sistem Bilgileri Bölümü (Read-only)
                  Text('Sistem Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  Observer(
                    builder: (_) {
                      return Column(
                        children: [
                          _buildReadOnlyDetailRow(
                              'ID:', _addEditAnimalStore.id),
                          _buildReadOnlyDetailRow('Oluşturulma Tarihi:',
                              _addEditAnimalStore.createdAt),
                          _buildReadOnlyDetailRow(
                              'Oluşturan ID:', _addEditAnimalStore.createdBy),
                          _buildReadOnlyDetailRow('Güncellenme Tarihi:',
                              _addEditAnimalStore.updatedAt),
                          _buildReadOnlyDetailRow(
                              'Güncelleyen ID:', _addEditAnimalStore.updatedBy),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
