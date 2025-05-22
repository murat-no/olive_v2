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

  const AddEditAnimalScreen({super.key, this.animalToEdit});

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
  final TextEditingController _colorDispController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _markingsController = TextEditingController();
  final TextEditingController _exceptionsController = TextEditingController();
  final TextEditingController _trackingIDController = TextEditingController();
  final TextEditingController _tracerLocationController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController(); // Read-only
  final TextEditingController _bloodGroupController = TextEditingController();


  // MobX Reaction'ları için Disposer listesi
  final List<ReactionDisposer> _disposers = [];


  @override
  void initState() {
    super.initState();
     print('DEBUG: initState - Reaction\'lar oluşturuluyor.');

     // Controller'ları store'daki observable'lara bağlayan Reaction'ları oluştur (Form değişiklikleri için)
     _disposers.add(reaction( (_) => _addEditAnimalStore.name, (name) => _nameController.text = name ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.alternateName, (value) => _alternateNameController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.passportNumber, (value) => _passportNumberController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.color, (value) => _colorController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.colorDisp, (value) => _colorDispController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.birthDate, (value) => _birthDateController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.markings, (value) => _markingsController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.exceptions, (value) => _exceptionsController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.trackingID, (value) => _trackingIDController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.tracerLocation, (value) => _tracerLocationController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.owner, (value) => _ownerController.text = value ?? '', fireImmediately: true, ));
     _disposers.add(reaction( (_) => _addEditAnimalStore.bloodGroup, (value) => _bloodGroupController.text = value ?? '', fireImmediately: true, ));


     // Initialize işlemi bittiğinde controller'ları set etmek için yeni Reaction
     _disposers.add(reaction(
       (_) => _addEditAnimalStore.isInitializing,
       (isInitializing) {
         print('DEBUG: isInitializing Reaction - Değer değişti: $isInitializing');
         if (!isInitializing) {
            print('DEBUG: isInitializing Reaction - Initialize tamamlandı, controller\'lar set ediliyor.');
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
         }
       },
       fireImmediately: true,
     ));

  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addEditAnimalStore = Provider.of<AddEditAnimalStore>(context, listen: false);

    print('DEBUG: didChangeDependencies - Store alınıyor.');

    if (!_addEditAnimalStore.isInitializing) {
       print('DEBUG: didChangeDependencies - Store initialize ediliyor.');
      _addEditAnimalStore.initialize(widget.animalToEdit);
    } else {
       print('DEBUG: didChangeDependencies - Store zaten initialize ediliyor veya edildi.');
    }
  }


  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }

    _nameController.dispose(); _alternateNameController.dispose(); _passportNumberController.dispose();
    _colorController.dispose(); _colorDispController.dispose(); _birthDateController.dispose();
    _markingsController.dispose(); _exceptionsController.dispose(); _trackingIDController.dispose(); _tracerLocationController.dispose();
    _ownerController.dispose();
    _bloodGroupController.dispose();

    super.dispose();
  }

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

  // ✨ Read-only detay satırları için yardımcı widget (TEK TANIM) ✨
  // Bu metodun sadece bir kez tanımlandığından bu sefer EMİN OLDUM.
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
      body: Observer(
         builder: (_) {
           if (_addEditAnimalStore.isInitializing || (_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.familyList.isEmpty)) {
              return const Center(child: CircularProgressIndicator());
           }
           else if (_addEditAnimalStore.valueListsErrorMessage != null) {
              return Center(
                 child: Text(
                     'Değer listeleri yüklenemedi: ${_addEditAnimalStore.valueListsErrorMessage!}',
                     style: const TextStyle(color: Colors.red),
                     textAlign: TextAlign.center,
                 ),
             );
           }
            else if (_addEditAnimalStore.errorMessage != null && !_addEditAnimalStore.isLoading) {
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
                   // ✨ Yeniden Gruplanmış Temel Bilgiler Bölümü ✨
                   Text('Temel Bilgiler', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                   // Adı ve Doğum Tarihi
                   Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Expanded( child: TextFormField( controller: _nameController, decoration: const InputDecoration(labelText: 'Adı'), onChanged: (newValue) => _addEditAnimalStore.name = newValue, validator: (value) { if (value == null || value.isEmpty) { return 'Lütfen hayvanın adını girin.'; } return null; }, ), ),
                         const SizedBox(width: 16),
                         Expanded( child: TextFormField( controller: _birthDateController, decoration: const InputDecoration( labelText: 'Doğum Tarihi (YYYY-MM-DD)', suffixIcon: Icon(Icons.calendar_today), ), keyboardType: TextInputType.datetime, readOnly: true, onTap: () async { FocusScope.of(context).requestFocus(FocusNode()); DateTime initialDate = DateTime.now(); if (_addEditAnimalStore.birthDate != null && _addEditAnimalStore.birthDate!.isNotEmpty) { try { initialDate = DateFormat('yyyy-MM-dd').parse(_addEditAnimalStore.birthDate!); } catch (e) { initialDate = DateTime.now(); } } DateTime? selectedDate = await showDatePicker( context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime.now(), helpText: 'Doğum Tarihi Seçin', cancelText: 'İptal', confirmText: 'Tamam', ); if (selectedDate != null) { String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate); _addEditAnimalStore.birthDate = formattedDate; } }, validator: (value) { if (value == null || value.isEmpty) { return 'Lütfen doğum tarihini girin.'; } return null; }, ), ),
                      ],
                   ),
                   const SizedBox(height: 16),

                   // Alternatif Adı ve Pasaport Numarası (Ek Bilgilerden taşındı)
                   Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Expanded( child: TextFormField( controller: _alternateNameController, decoration: const InputDecoration(labelText: 'Alternatif Adı'), onChanged: (newValue) => _addEditAnimalStore.alternateName = newValue, ), ),
                         const SizedBox(width: 16),
                         Expanded( child: TextFormField( controller: _passportNumberController, decoration: const InputDecoration(labelText: 'Pasaport Numarası'), onChanged: (newValue) => _addEditAnimalStore.passportNumber = newValue, ), ),
                      ],
                   ),
                   const SizedBox(height: 16),

                    // Renk ve Renk Tanımı Alanları (Yeni Eklendi)
                     Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Expanded( child: TextFormField( controller: _colorController, decoration: const InputDecoration(labelText: 'Renk'), onChanged: (newValue) => _addEditAnimalStore.color = newValue, ), ),
                           const SizedBox(width: 16),
                           Expanded( child: TextFormField( controller: _colorDispController, decoration: const InputDecoration(labelText: 'Renk Tanımı'), onChanged: (newValue) => _addEditAnimalStore.colorDisp = newValue, ), ),
                       ],
                    ),
                   const SizedBox(height: 16),

                   // Kan Grubu
                   TextFormField( controller: _bloodGroupController, decoration: const InputDecoration(labelText: 'Kan Grubu (Blood Group)'), onChanged: (newValue) => _addEditAnimalStore.bloodGroup = newValue, ),
                   const SizedBox(height: 16),

                    // Sahip Bilgileri (Ayrı başlıktı, Temel Bilgilere taşındı)
                    Text('Sahip Bilgileri', style: Theme.of(context).textTheme.titleMedium), // Sahip Bilgileri başlığı
                    const SizedBox(height: 16),
                   TextFormField( controller: _ownerController, decoration: const InputDecoration(labelText: 'Sahip Adı'), readOnly: true, ), // Sahip Adı alanı
                   const SizedBox(height: 16),


                   // ✨ Sınıflandırma Bölümü ✨
                   Text('Sınıflandırma', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                   // Family ve Race
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Expanded( child: Observer( builder: (_) { final List<DropdownMenuItem<String>> dropdownItems = _addEditAnimalStore.familyList.map((ValueOption option) { return DropdownMenuItem<String>( value: option.id, child: Text(option.value ?? ''), ); }).toList(); final bool isFamilyDropdownEnabled = !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.familyList.isNotEmpty; return DropdownButtonFormField<String>( decoration: const InputDecoration(labelText: 'Tür (Family)'), items: dropdownItems.isEmpty && !isFamilyDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? [const DropdownMenuItem(value: "loading", child: Text("Yükleniyor..."))] : dropdownItems, value: _addEditAnimalStore.selectedFamilyOption?.id?.isNotEmpty == true ? _addEditAnimalStore.selectedFamilyOption!.id : null, onChanged: isFamilyDropdownEnabled ? (String? selectedId) { final selectedOption = _addEditAnimalStore.familyList.firstWhere( (option) => option.id == selectedId, orElse: () => ValueOption(id: '', value: '') ); _addEditAnimalStore.setFamily(selectedOption.id!.isNotEmpty ? selectedOption : null); } : null, validator: (value) { if (value == null || value.isEmpty) { return 'Lütfen hayvanın türünü seçin.'; } return null; }, hint: (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? const Text('Yükleniyor...') : const Text('Tür seçiniz'), ); } ), ),
                         const SizedBox(width: 16),
                         Expanded( child: Observer( builder: (_) { final bool isRaceDropdownEnabled = _addEditAnimalStore.selectedFamilyOption != null && !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.raceList.isNotEmpty; final List<DropdownMenuItem<String>> dropdownItems = _addEditAnimalStore.raceList.map((ValueOption option) { return DropdownMenuItem<String>( value: option.id, child: Text(option.value ?? ''), ); }).toList(); return DropdownButtonFormField<String>( decoration: const InputDecoration(labelText: 'Irk (Race)'), items: dropdownItems.isEmpty && !isRaceDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading || _addEditAnimalStore.selectedFamilyOption != null) ? [const DropdownMenuItem(value: "loading", child: Text("Yükleniyor..."))] : (dropdownItems.isEmpty && _addEditAnimalStore.selectedFamilyOption == null ? [const DropdownMenuItem(value: "disabled", child: Text("Tür seçiniz"))] : dropdownItems), value: _addEditAnimalStore.selectedRaceOption?.id?.isNotEmpty == true ? _addEditAnimalStore.selectedRaceOption!.id : null, onChanged: isRaceDropdownEnabled ? (String? selectedId) { final selectedOption = _addEditAnimalStore.raceList.firstWhere( (option) => option.id == selectedId, orElse: () => ValueOption(id: '', value: '') ); _addEditAnimalStore.setRace(selectedOption.id!.isNotEmpty ? selectedOption : null); } : null, validator: (value) { return null; }, hint: _addEditAnimalStore.selectedFamilyOption == null ? const Text('Tür seçiniz') : (_addEditAnimalStore.isValueListsLoading ? const Text('Yükleniyor...') : const Text('Irk seçiniz')), ); } ), ),
                      ],
                   ),
                   const SizedBox(height: 16),

                    // Breed ve Sex
                    Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Expanded( child: Observer( builder: (_) { final List<DropdownMenuItem<String>> dropdownItems = _addEditAnimalStore.breedList.map((ValueOption option) { return DropdownMenuItem<String>( value: option.id, child: Text(option.value ?? ''), ); }).toList(); final bool isBreedDropdownEnabled = !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.breedList.isNotEmpty; return DropdownButtonFormField<String>( decoration: const InputDecoration(labelText: 'Cins (Breed)'), items: dropdownItems.isEmpty && !isBreedDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? [const DropdownMenuItem(value: "loading", child: Text("Yükleniyor..."))] : dropdownItems, value: _addEditAnimalStore.selectedBreedOption?.id?.isNotEmpty == true ? _addEditAnimalStore.selectedBreedOption!.id : null, onChanged: isBreedDropdownEnabled ? (String? selectedId) { final selectedOption = _addEditAnimalStore.breedList.firstWhere( (option) => option.id == selectedId, orElse: () => ValueOption(id: '', value: '') ); _addEditAnimalStore.setBreed(selectedOption.id!.isNotEmpty ? selectedOption : null); } : null, validator: (value) { return null; }, hint: (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? const Text('Yükleniyor...') : const Text('Cins seçiniz'), ); } ), ),
                          const SizedBox(width: 16),
                           Expanded( child: Observer( builder: (_) { final List<DropdownMenuItem<String>> dropdownItems = _addEditAnimalStore.sexList.map((ValueOption option) { return DropdownMenuItem<String>( value: option.id, child: Text(option.value ?? ''), ); }).toList(); final bool isSexDropdownEnabled = !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.sexList.isNotEmpty; return DropdownButtonFormField<String>( decoration: const InputDecoration(labelText: 'Cinsiyet (Sex)'), items: dropdownItems.isEmpty && !isSexDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? [const DropdownMenuItem(value: "loading", child: Text("Yükleniyor..."))] : dropdownItems, value: _addEditAnimalStore.selectedSexOption?.id?.isNotEmpty == true ? _addEditAnimalStore.selectedSexOption!.id : null, onChanged: isSexDropdownEnabled ? (String? selectedId) { final selectedOption = _addEditAnimalStore.sexList.firstWhere( (option) => option.id == selectedId, orElse: () => ValueOption(id: '', value: '') ); _addEditAnimalStore.setSex(selectedOption.id!.isNotEmpty ? selectedOption : null); } : null, validator: (value) { return null; }, hint: (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? const Text('Yükleniyor...') : const Text('Cinsiyet seçiniz'), ); } ), ),
                       ],
                    ),
                   const SizedBox(height: 16),


                   // ✨ Takip Bilgileri Bölümü ✨
                   Text('Takip Bilgileri', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                    // TrackingMethod ve TrackingID
                    Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Expanded( child: Observer( builder: (_) { final List<DropdownMenuItem<String>> dropdownItems = _addEditAnimalStore.trackingMethodList.map((ValueOption option) { return DropdownMenuItem<String>( value: option.id, child: Text(option.value ?? ''), ); }).toList(); final bool isTrackingMethodDropdownEnabled = !_addEditAnimalStore.isInitializing && !_addEditAnimalStore.isValueListsLoading && _addEditAnimalStore.trackingMethodList.isNotEmpty; return DropdownButtonFormField<String>( decoration: const InputDecoration(labelText: 'Takip Metodu'), items: dropdownItems.isEmpty && !isTrackingMethodDropdownEnabled && (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? [const DropdownMenuItem(value: "loading", child: Text("Yükleniyor..."))] : dropdownItems, value: _addEditAnimalStore.selectedTrackingMethodOption?.id?.isNotEmpty == true ? _addEditAnimalStore.selectedTrackingMethodOption!.id : null, onChanged: isTrackingMethodDropdownEnabled ? (String? selectedId) { final selectedOption = _addEditAnimalStore.trackingMethodList.firstWhere( (option) => option.id == selectedId, orElse: () => ValueOption(id: '', value: '') ); _addEditAnimalStore.setTrackingMethod(selectedOption.id!.isNotEmpty ? selectedOption : null); } : null, validator: (value) { return null; }, hint: (_addEditAnimalStore.isInitializing || _addEditAnimalStore.isValueListsLoading) ? const Text('Yükleniyor...') : const Text('Takip metodu seçiniz'), ); } ), ),
                          const SizedBox(width: 16),
                          Expanded( child: TextFormField( controller: _trackingIDController, decoration: const InputDecoration(labelText: 'Takip ID'), onChanged: (newValue) => _addEditAnimalStore.trackingID = newValue, ), ),
                       ],
                    ),
                    const SizedBox(height: 16),

                    // TracerLocation
                     TextFormField( controller: _tracerLocationController, decoration: const InputDecoration(labelText: 'Takip Konumu (Tracer Location)'), onChanged: (newValue) => _addEditAnimalStore.tracerLocation = newValue, ),
                    const SizedBox(height: 16),


                   // ✨ Ek Bilgiler Bölümü ✨
                   Text('Ek Bilgiler', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 16),

                    // Markings
                     TextFormField( controller: _markingsController, decoration: const InputDecoration(labelText: 'İşaretler'), maxLines: 3, onChanged: (newValue) => _addEditAnimalStore.markings = newValue, ),
                   const SizedBox(height: 16),

                    // Exceptions
                     TextFormField( controller: _exceptionsController, decoration: const InputDecoration(labelText: 'İstisnalar'), maxLines: 3, onChanged: (newValue) => _addEditAnimalStore.exceptions = newValue, ),
                   const SizedBox(height: 16),


                    // ✨ Sistem Bilgileri Bölümü (Read-only) ✨
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

                 ],
               ),
             ),
           );
         },
      ),
    );
  }
}