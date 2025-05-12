import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:olive_v2/stores/add_edit_animal_store.dart';
import 'package:olive_v2/models/animal.dart';
import 'package:olive_v2/models/value_option.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';


class AddEditAnimalScreen extends StatefulWidget {
  final Animal? animalToEdit;

  const AddEditAnimalScreen({Key? key, this.animalToEdit}) : super(key: key);

  @override
  _AddEditAnimalScreenState createState() => _AddEditAnimalScreenState();
}

class _AddEditAnimalScreenState extends State<AddEditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddEditAnimalStore _addEditAnimalStore;

  // Form alanları için TextEditingController'lar
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _alternateNameController = TextEditingController();
  final TextEditingController _passportNumberController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _markingsController = TextEditingController();
  final TextEditingController _exceptionsController = TextEditingController();
  final TextEditingController _trackingIDController = TextEditingController();
  final TextEditingController _tracerLocationController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController(); // Read-only
  final TextEditingController _bloodGroupController = TextEditingController();


  // MobX Reaction'ları için Disposer listesi
  List<ReactionDisposer> _disposers = [];


  @override
  void initState() {
    super.initState();
     // ✨ initState sadece reaction'ları oluşturur ve store'u alır ✨
     // Initialize çağrısı didChangeDependencies'te yapılacak.
     _addEditAnimalStore = Provider.of<AddEditAnimalStore>(context, listen: false);

     print('DEBUG: initState - Reaction\'lar oluşturuluyor.');

     // Controller'ları store'daki observable'lara bağlayan Reaction'ları oluştur (Form değişiklikleri için)
     _disposers.add(reaction( (_) => _addEditAnimalStore.name, (name) => _nameController.text = name ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.alternateName, (value) => _alternateNameController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.passportNumber, (value) => _passportNumberController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.color, (value) => _colorController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.birthDate, (value) => _birthDateController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.markings, (value) => _markingsController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.exceptions, (value) => _exceptionsController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.trackingID, (value) => _trackingIDController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.tracerLocation, (value) => _tracerLocationController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.owner, (value) => _ownerController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.bloodGroup, (value) => _bloodGroupController.text = value ?? '', fireImmediately: true, ));


     // ✨ Initialize işlemi bittiğinde controller'ları set etmek için yeni Reaction ✨
     _disposers.add(reaction(
       (_) => _addEditAnimalStore.isInitializing, // isInitializing observable'ı değiştiğinde izle
       (isInitializing) {
         print('DEBUG: isInitializing Reaction - Değer değişti: $isInitializing');
         // Eğer initialize işlemi tamamlandıysa (false olduysa)
         if (!isInitializing) {
            print('DEBUG: isInitializing Reaction - Initialize tamamlandı, controller\'lar set ediliyor.');
            // Store'daki güncel değerlerle controller'ları set et
            _nameController.text = _addEditAnimalStore.name ?? '';
            _alternateNameController.text = _addEditAnimalStore.alternateName ?? '';
            _passportNumberController.text = _addEditAnimalStore.passportNumber ?? '';
            _colorController.text = _addEditAnimalStore.color ?? '';
            _birthDateController.text = _addEditAnimalStore.birthDate ?? '';
            _markingsController.text = _addEditAnimalStore.markings ?? '';
            _exceptionsController.text = _addEditAnimalStore.exceptions ?? '';
            _trackingIDController.text = _addEditAnimalStore.trackingID ?? '';
            _tracerLocationController.text = _addEditAnimalStore.tracerLocation ?? '';
            _ownerController.text = _addEditAnimalStore.owner ?? '';
            _bloodGroupController.text = _addEditAnimalStore.bloodGroup ?? '';
         }
       },
       fireImmediately: true, // Başlangıçta isInitializing durumuna göre bir kez çalıştır
     ));

  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✨ Store'u burada al ve initialize aksiyonunu tetikle ✨
    _addEditAnimalStore = Provider.of<AddEditAnimalStore>(context, listen: false); // Provider burada alınmalı

    print('DEBUG: didChangeDependencies - Store alınıyor.');

    // Store henüz initialize edilmediyse initialize aksiyonunu çağır
    // isInitializing bayrağı, initialize'ın sadece bir kez çalışmasını sağlar.
    if (!_addEditAnimalStore.isInitializing) {
       print('DEBUG: didChangeDependencies - Store initialize ediliyor.');
      _addEditAnimalStore.initialize(widget.animalToEdit);
    } else {
       print('DEBUG: didChangeDependencies - Store zaten initialize ediliyor veya edildi.');
    }
  }


  @override
  void dispose() {
    // Reaction Disposer'ları temizle
    for (final d in _disposers) {
      d();
    }

    // Controller'ları temizle
    _nameController.dispose(); _alternateNameController.dispose(); _passportNumberController.dispose();
    _colorController.dispose(); _birthDateController.dispose(); _markingsController.dispose();
    _exceptionsController.dispose(); _trackingIDController.dispose(); _tracerLocationController.dispose();
    _ownerController.dispose();
    _bloodGroupController.dispose();

    super.dispose();
  }

  // Form kaydedildiğinde çağrılacak metod (Aynı kalacak)
  void _saveForm() async { /* ... aynı kod ... */
    if (_formKey.currentState?.validate() ?? false) {
      print('DEBUG: Form valide edildi, kaydetme aksiyonu çağrılıyor.');
      final success = await _addEditAnimalStore.saveAnimal();
      if (success) {
        print('DEBUG: Hayvan başarıyla kaydedildi.');
        Navigator.pop(context, true);
      } else {
        print('DEBUG: Hayvan kaydetme başarısız oldu. Hata: ${_addEditAnimalStore.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Kaydetme Başarısız: ${_addEditAnimalStore.errorMessage ?? "Bilinmeyen hata."}'),
             backgroundColor: Colors.red,
           ),
        );
      }
    } else {
       print('DEBUG: Form validasyonu başarısız.');
    }
  }

  // ✨ Read-only detay satırları için yardımcı widget (Tek tanım) ✨
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
            SizedBox( width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), ),
            Expanded( child: Text(displayValue), ),
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
          // Kaydet butonu
          Observer(
            builder: (_) {
              return IconButton(
                icon: (_addEditAnimalStore.isLoading || _addEditAnimalStore.isInitializing)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
                tooltip: 'Kaydet',
                onPressed: (_addEditAnimalStore.isLoading || _addEditAnimalStore.isInitializing) ? null : _saveForm,
              );
            },
          ),
        ],
      ),
      body: Observer( // Store'daki durumları dinle
         builder: (_) {
           // Genel yüklenme (initialize) veya değer listeleri yüklenme durumunda
           if (_addEditAnimalStore.isInitializing || (_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.familyList.isEmpty)) {
              return const Center(child: CircularProgressIndicator());
           }
           // Değer listeleri hata durumunda
           else if (_addEditAnimalStore.valueListsErrorMessage != null) {
              return Center(
                 child: Text(
                     'Değer listeleri yüklenemedi: ${_addEditAnimalStore.valueListsErrorMessage!}',
                     style: const TextStyle(color: Colors.red),
                     textAlign: TextAlign.center,
                 ),
             );
           }
           // Kaydetme hatası varsa (değer listeleri yüklenmişse)
            else if (_addEditAnimalStore.errorMessage != null && !_addEditAnimalStore.isLoading) {
             return Center(
                 child: Text(
                     'Kaydetme Hatası: ${_addEditAnimalStore.errorMessage!}',
                     style: const TextStyle(color: Colors.red),
                     textAlign: TextAlign.center,
                 ),
             );
           }

           // Normal formu göster (Yüklenme veya hata yoksa)
           return Padding(
             padding: const EdgeInsets.all(16.0),
             child: Form(
               key: _formKey,
               child: ListView(
                 children: [
                   // ✨ Form Alanları ✨

                   Text('Temel Bilgiler', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                   // Adı (name) - TextFormField
                   TextFormField(
                     controller: _nameController,
                     decoration: const InputDecoration(labelText: 'Adı'),
                     onChanged: (newValue) => _addEditAnimalStore.name = newValue,
                     validator: (value) {
                       if (value == null || value.isEmpty) {
                         return 'Lütfen hayvanın adını girin.';
                       }
                       return null;
                     },
                   ),
                   const SizedBox(height: 16),

                   // Doğum Tarihi (birth_date) - TextFormField (DatePicker bağlı)
                   TextFormField(
                     controller: _birthDateController,
                     decoration: const InputDecoration(
                         labelText: 'Doğum Tarihi (YYYY-MM-DD)',
                         suffixIcon: Icon(Icons.calendar_today),
                     ),
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                      onTap: () async {
                         print('DEBUG: Doğum tarihi alanı tıklandı, DatePicker açılıyor.');
                         FocusScope.of(context).requestFocus(new FocusNode());

                         DateTime initialDate = DateTime.now();
                         if (_addEditAnimalStore.birthDate != null && _addEditAnimalStore.birthDate!.isNotEmpty) {
                           try {
                             initialDate = DateFormat('yyyy-MM-dd').parse(_addEditAnimalStore.birthDate!);
                           } catch (e) {
                             print('DEBUG: Doğum tarihi format hatası: $e');
                             initialDate = DateTime.now();
                           }
                         }

                         DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            helpText: 'Doğum Tarihi Seçin',
                            cancelText: 'İptal',
                            confirmText: 'Tamam',
                            // locale: const Locale('tr', 'TR'),
                         );

                         if (selectedDate != null) {
                            String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                            _addEditAnimalStore.birthDate = formattedDate;
                            print('DEBUG: Doğum tarihi seçildi: $formattedDate');
                         }
                      },
                      validator: (value) {
                         if (value == null || value.isEmpty) {
                           return 'Lütfen doğum tarihini girin.';
                         }
                         return null;
                      },
                   ),
                   const SizedBox(height: 16),


                   // DropdownButtonFormField'lar ve Blood Group TextFormField

                   Text('Sınıflandırma', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                   // Family (Tür) - DropdownButtonFormField
                   Observer(
                      builder: (_) {
                         final List<DropdownMenuItem<String>> dropdownItems =
                             _addEditAnimalStore.familyList.map((ValueOption option) {
                           return DropdownMenuItem<String>(
                             value: option.id,
                             child: Text(option.value ?? ''),
                           );
                         }).toList();

                         final bool isFamilyDropdownEnabled = !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.familyList.isNotEmpty;

                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Tür (Family)'),
                          items: dropdownItems.isEmpty && !isFamilyDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading)
                              ? [const DropdownMenuItem(child: Text("Yükleniyor..."), value: "loading")]
                              : dropdownItems,
                          value: _addEditAnimalStore.selectedFamilyOption?.id?.isNotEmpty == true
                               ? _addEditAnimalStore.selectedFamilyOption!.id
                               : null,
                           onChanged: isFamilyDropdownEnabled ? (String? selectedId) {
                             print('DEBUG: Family selected ID: $selectedId');
                             final selectedOption = _addEditAnimalStore.familyList.firstWhere(
                                 (option) => option.id == selectedId,
                                 orElse: () => ValueOption(id: '', value: '')
                              );
                             _addEditAnimalStore.setFamily(selectedOption.id!.isNotEmpty ? selectedOption : null);
                           } : null,
                           validator: (value) {
                             if (_addEditAnimalStore.selectedFamilyOption == null) {
                                return 'Lütfen hayvanın türünü seçin.';
                             }
                              return null;
                           },
                           hint: (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading)
                                ? const Text('Yükleniyor...')
                                : const Text('Tür seçiniz'),
                        );
                      }
                   ),
                   const SizedBox(height: 16),

                    // Race (Irk) - DropdownButtonFormField (Family seçimine bağlı)
                    Observer(
                      builder: (_) {
                         final bool isRaceDropdownEnabled = _addEditAnimalStore.selectedFamilyOption != null && !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.raceList.isNotEmpty;

                         final List<DropdownMenuItem<String>> dropdownItems =
                             _addEditAnimalStore.raceList.map((ValueOption option) {
                           return DropdownMenuItem<String>(
                             value: option.id,
                             child: Text(option.value ?? ''),
                           );
                         }).toList();

                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Irk (Race)'),
                           items: dropdownItems.isEmpty && !isRaceDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading || _addEditAnimalStore.selectedFamilyOption != null)
                              ? [const DropdownMenuItem(child: Text("Yükleniyor..."), value: "loading")]
                               : (dropdownItems.isEmpty && _addEditAnimalStore.selectedFamilyOption == null
                                 ? [const DropdownMenuItem(child: Text("Tür seçiniz"), value: "disabled")]
                                 : dropdownItems),

                           value: _addEditAnimalStore.selectedRaceOption?.id?.isNotEmpty == true
                               ? _addEditAnimalStore.selectedRaceOption!.id
                               : null,
                           onChanged: isRaceDropdownEnabled ? (String? selectedId) {
                             print('DEBUG: Race selected ID: $selectedId');
                             final selectedOption = _addEditAnimalStore.raceList.firstWhere(
                                 (option) => option.id == selectedId,
                                 orElse: () => ValueOption(id: '', value: '')
                              );
                              _addEditAnimalStore.setRace(selectedOption.id!.isNotEmpty ? selectedOption : null);
                           } : null,
                            validator: (value) {
                             // TODO: Zorunlu alan validasyonu
                              return null;
                           },
                           hint: _addEditAnimalStore.selectedFamilyOption == null
                               ? const Text('Tür seçiniz')
                               : (_addEditAnimalStore.isValueListsLoading ? const Text('Yükleniyor...')
                                  : const Text('Irk seçiniz')),
                        );
                      }
                   ),
                   const SizedBox(height: 16),

                    // Breed (Cins) - DropdownButtonFormField
                     Observer(
                      builder: (_) {
                         final List<DropdownMenuItem<String>> dropdownItems =
                             _addEditAnimalStore.breedList.map((ValueOption option) {
                           return DropdownMenuItem<String>(
                             value: option.id,
                             child: Text(option.value ?? ''),
                           );
                         }).toList();

                         final bool isBreedDropdownEnabled = !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.breedList.isNotEmpty;

                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Cins (Breed)'),
                           items: dropdownItems.isEmpty && !isBreedDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading)
                              ? [const DropdownMenuItem(child: Text("Yükleniyor..."), value: "loading")]
                              : dropdownItems,
                           value: _addEditAnimalStore.selectedBreedOption?.id?.isNotEmpty == true
                               ? _addEditAnimalStore.selectedBreedOption!.id
                               : null,
                           onChanged: isBreedDropdownEnabled ? (String? selectedId) {
                             print('DEBUG: Breed selected ID: $selectedId');
                              final selectedOption = _addEditAnimalStore.breedList.firstWhere(
                                 (option) => option.id == selectedId,
                                 orElse: () => ValueOption(id: '', value: '')
                              );
                             _addEditAnimalStore.setBreed(selectedOption.id!.isNotEmpty ? selectedOption : null);
                           } : null,
                            validator: (value) {
                             // TODO: Zorunlu alan validasyonu
                              return null;
                           },
                            hint: (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? const Text('Yükleniyor...') : const Text('Cins seçiniz'),
                        );
                      }
                   ),
                   const SizedBox(height: 16),

                   // Sex (Cinsiyet) - DropdownButtonFormField
                    Observer(
                      builder: (_) {
                         final List<DropdownMenuItem<String>> dropdownItems =
                             _addEditAnimalStore.sexList.map((ValueOption option) {
                           return DropdownMenuItem<String>(
                             value: option.id,
                             child: Text(option.value ?? ''),
                           );
                         }).toList();

                          final bool isSexDropdownEnabled = !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.sexList.isNotEmpty;

                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Cinsiyet (Sex)'),
                           items: dropdownItems.isEmpty && !isSexDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading)
                              ? [const DropdownMenuItem(child: Text("Yükleniyor..."), value: "loading")]
                              : dropdownItems,
                           value: _addEditAnimalStore.selectedSexOption?.id?.isNotEmpty == true
                               ? _addEditAnimalStore.selectedSexOption!.id
                               : null,
                           onChanged: isSexDropdownEnabled ? (String? selectedId) {
                             print('DEBUG: Sex selected ID: $selectedId');
                              final selectedOption = _addEditAnimalStore.sexList.firstWhere(
                                 (option) => option.id == selectedId,
                                 orElse: () => ValueOption(id: '', value: '')
                              );
                             _addEditAnimalStore.setSex(selectedOption.id!.isNotEmpty ? selectedOption : null);
                           } : null,
                            validator: (value) {
                             // TODO: Zorunlu alan validasyonu
                              return null;
                           },
                             hint: (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? const Text('Yükleniyor...') : const Text('Cinsiyet seçiniz'),
                        );
                      }
                   ),
                   const SizedBox(height: 16),

                   // BloodGroup (Kan Grubu) - TextFormField
                    TextFormField(
                       controller: _bloodGroupController,
                       decoration: const InputDecoration(labelText: 'Kan Grubu (Blood Group)'),
                       onChanged: (newValue) => _addEditAnimalStore.bloodGroup = newValue,
                       // TODO: Validator
                    ),
                   const SizedBox(height: 16),

                   Text('Takip Bilgileri', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                    // TrackingMethod (Takip Metodu) - DropdownButtonFormField
                    Observer(
                      builder: (_) {
                         final List<DropdownMenuItem<String>> dropdownItems =
                             _addEditAnimalStore.trackingMethodList.map((ValueOption option) {
                           return DropdownMenuItem<String>(
                             value: option.id,
                             child: Text(option.value ?? ''),
                           );
                         }).toList();

                          final bool isTrackingMethodDropdownEnabled = !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.trackingMethodList.isNotEmpty;


                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Takip Metodu'),
                           items: dropdownItems.isEmpty && !isTrackingMethodDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading)
                              ? [const DropdownMenuItem(child: Text("Yükleniyor..."), value: "loading")]
                              : dropdownItems,
                           value: _addEditAnimalStore.selectedTrackingMethodOption?.id?.isNotEmpty == true
                               ? _addEditAnimalStore.selectedTrackingMethodOption!.id
                               : null,
                           onChanged: isTrackingMethodDropdownEnabled ? (String? selectedId) {
                             print('DEBUG: TrackingMethod selected ID: $selectedId');
                              final selectedOption = _addEditAnimalStore.trackingMethodList.firstWhere(
                                 (option) => option.id == selectedId,
                                 orElse: () => ValueOption(id: '', value: '')
                              );
                             _addEditAnimalStore.setTrackingMethod(selectedOption.id!.isNotEmpty ? selectedOption : null);
                           } : null,
                            validator: (value) {
                             // TODO: Zorunlu alan validasyonu
                              return null;
                           },
                             hint: (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? const Text('Yükleniyor...') : const Text('Takip metodu seçiniz'),
                        );
                      }
                   ),
                   const SizedBox(height: 16),

                    // TrackingID - TextFormField
                    TextFormField(
                       controller: _trackingIDController,
                       decoration: const InputDecoration(labelText: 'Takip ID'),
                        onChanged: (newValue) => _addEditAnimalStore.trackingID = newValue,
                    // TODO: Validator
                   ),
                   const SizedBox(height: 16),

                    // TracerLocation - TextFormField
                     TextFormField(
                        controller: _tracerLocationController,
                        decoration: const InputDecoration(labelText: 'Takip Konumu (Tracer Location)'),
                         onChanged: (newValue) => _addEditAnimalStore.tracerLocation = newValue,
                        // TODO: Validator
                    ),
                    const SizedBox(height: 16),


                   Text('Ek Bilgiler', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                   // AlternateName - TextFormField
                   TextFormField(
                       controller: _alternateNameController,
                       decoration: const InputDecoration(labelText: 'Alternatif Adı'),
                        onChanged: (newValue) => _addEditAnimalStore.alternateName = newValue,
                        // TODO: Validator
                   ),
                   const SizedBox(height: 16),

                    // PassportNumber - TextFormField
                    TextFormField(
                       controller: _passportNumberController,
                       decoration: const InputDecoration(labelText: 'Pasaport Numarası'),
                        onChanged: (newValue) => _addEditAnimalStore.passportNumber = newValue,
                        // TODO: Validator
                   ),
                   const SizedBox(height: 16),

                    // Markings - TextFormField
                     TextFormField(
                        controller: _markingsController,
                       decoration: const InputDecoration(labelText: 'İşaretler'),
                        maxLines: 3,
                         onChanged: (newValue) => _addEditAnimalStore.markings = newValue,
                         // TODO: Validator
                   ),
                   const SizedBox(height: 16),

                    // Exceptions - TextFormField
                     TextFormField(
                        controller: _exceptionsController,
                       decoration: const InputDecoration(labelText: 'İstisnalar'),
                        maxLines: 3,
                         onChanged: (newValue) => _addEditAnimalStore.exceptions = newValue,
                         // TODO: Validator
                   ),
                   const SizedBox(height: 16),


                   // Sahip bilgileri (Okunur alanlar)
                   Text('Sahip Bilgileri', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                   // Owner (Sahip Adı) - TextFormField (Read-only)
                   TextFormField(
                        controller: _ownerController,
                       decoration: const InputDecoration(labelText: 'Sahip Adı'),
                        readOnly: true,
                       // TODO: Sahip seçimi için Owner listesi/ekranına navigasyon ve sonuç işleme
                   ),
                   const SizedBox(height: 16),

                    // Sistem Bilgileri (Read-only)
                     Text('Sistem Bilgileri', style: Theme.of(context).textTheme.titleMedium),
                     const SizedBox(height: 16),

                     Observer(
                       builder: (_) {
                         return Column(
                           children: [
                             _buildReadOnlyDetailRow('ID:', _addEditAnimalStore.id),
                             _buildReadOnlyDetailRow('Oluşturulma Tarihi:', _addEditAnimalStore.createdAt),
                              _buildReadOnlyDetailRow('Oluşturan ID:', _addEditAnimalStore.createdBy),
                             _buildReadOnlyDetailRow('Güncellenme Tarihi:', _addEditAnimalStore.updatedAt),
                              _buildReadOnlyDetailRow('Güncelleyen ID:', _addEditAnimalStore.updatedBy),
                           ],
                         );
                       },
                     ),
                     const SizedBox(height: 16),


                   // TODO: Medikal Kayıtlar ve Randevular linkleri eklenebilir

                 ],
               ),
             ),
           );
         },
      ),
    );
  }
}