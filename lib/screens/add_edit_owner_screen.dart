// lib/screens/add_edit_owner_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:olive_v2/stores/add_edit_owner_store.dart';
import 'package:olive_v2/models/owner.dart';
import 'package:olive_v2/models/value_option.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart'; // MobX'ten 'when' için bu import gerekli
import 'package:olive_v2/widgets/custom_dropdown_form_field.dart';

class AddEditOwnerScreen extends StatefulWidget {
  final Owner? ownerToEdit;

  const AddEditOwnerScreen({super.key, this.ownerToEdit});

  @override
  _AddEditOwnerScreenState createState() => _AddEditOwnerScreenState();
}

class _AddEditOwnerScreenState extends State<AddEditOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddEditOwnerStore _addEditOwnerStore;

  // Form alanları için TextEditingController'lar
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mobilePhoneController = TextEditingController();
  final TextEditingController _contactIdController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();

  // MobX Reaction'ları için Disposer listesi
  final List<ReactionDisposer> _disposers = [];

  @override
  void initState() {
    super.initState();
    print('DEBUG: AddEditOwnerScreen initState - Initializing Controllers.');

    // Controller'lar burada boş olarak başlatılıyor, MobX 'when' ile güncellenecekler.
    // Mevcut reaksiyonlar kaldırıldı, çünkü 'when' yapısı daha uygun.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addEditOwnerStore = Provider.of<AddEditOwnerStore>(context, listen: false);

    // Eğer store henüz initialize edilmediyse VEYA daha önce bir ID atanmamışsa (yeni kayıt değilse)
    // isInitializing true ise, zaten başlatılıyor demektir, tekrar başlatma.
    if (!_addEditOwnerStore.isInitializing && !(_addEditOwnerStore.id != null && _addEditOwnerStore.id!.isNotEmpty && widget.ownerToEdit == null)) {
      print('DEBUG: AddEditOwnerScreen: didChangeDependencies - Initializing store (ownerToEdit: ${widget.ownerToEdit?.fullName}).');
      _addEditOwnerStore.initialize(widget.ownerToEdit);

      // Store initialize edildikten sonra (yani isInitializing false olduğunda)
      // controller'ları güncellemek için bir MobX `when` reaksiyonu tanımlayalım.
      _disposers.add(
        when(
          (_) => !_addEditOwnerStore.isInitializing, // Koşul: isInitializing false olduğunda
          () { // Çalışacak aksiyon
            print('DEBUG: AddEditOwnerScreen MobX "when" triggered - Initializing finished, updating controllers.');
            // setState'i çağırarak tüm controller'ları tek seferde güncelle ve UI'ı yeniden çizdir.
            setState(() {
              _nationalIdController.text = _addEditOwnerStore.nationalId ?? '';
              _firstNameController.text = _addEditOwnerStore.firstName ?? '';
              _lastNameController.text = _addEditOwnerStore.lastName ?? '';
              _addressController.text = _addEditOwnerStore.address ?? '';
              _zipCodeController.text = _addEditOwnerStore.zipCode ?? '';
              _emailController.text = _addEditOwnerStore.email ?? '';
              _phoneController.text = _addEditOwnerStore.phone ?? '';
              _mobilePhoneController.text = _addEditOwnerStore.mobilePhone ?? '';
              _contactIdController.text = _addEditOwnerStore.contactId ?? '';
              _contactNameController.text = _addEditOwnerStore.contactName ?? '';
              print('DEBUG: AddEditOwnerScreen - Controllers updated via setState.');
            });
          },
        ),
      );
    } else {
      // Eğer store zaten initialize edilmişse (örn: sayfa yeniden build edildiğinde ama store değişmediyse)
      // veya zaten initializing durumundaysa, controller'ları doğrudan güncelleyebiliriz.
      // Bu kısım, sayfa açılışında `isInitializing` false iken (yeni kayıt ekranında) veya
      // initialize bitmişken (tekrar build edildiğinde) controller'ların güncellenmesini sağlar.
      print('DEBUG: AddEditOwnerScreen: didChangeDependencies - Store already initializing or initialized, updating controllers with current values.');
      _nationalIdController.text = _addEditOwnerStore.nationalId ?? '';
      _firstNameController.text = _addEditOwnerStore.firstName ?? '';
      _lastNameController.text = _addEditOwnerStore.lastName ?? '';
      _addressController.text = _addEditOwnerStore.address ?? '';
      _zipCodeController.text = _addEditOwnerStore.zipCode ?? '';
      _emailController.text = _addEditOwnerStore.email ?? '';
      _phoneController.text = _addEditOwnerStore.phone ?? '';
      _mobilePhoneController.text = _addEditOwnerStore.mobilePhone ?? '';
      _contactIdController.text = _addEditOwnerStore.contactId ?? '';
      _contactNameController.text = _addEditOwnerStore.contactName ?? '';
    }
  }

  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    _nationalIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobilePhoneController.dispose();
    _contactIdController.dispose();
    _contactNameController.dispose();

    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('DEBUG: AddEditOwnerScreen: Form validated, calling save action.');
      final success = await _addEditOwnerStore.saveOwner();

      if (success) {
        print('DEBUG: AddEditOwnerScreen: Owner saved successfully.');
        Navigator.pop(context, true);
      } else {
        print('DEBUG: AddEditOwnerScreen: Owner save failed. Error: ${_addEditOwnerStore.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Kaydetme Başarısız: ${_addEditOwnerStore.errorMessage ?? "Bilinmeyen hata."}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('DEBUG: AddEditOwnerScreen: Form validation failed.');
    }
  }

  // Read-only detay satırları için yardımcı widget
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
    final String appBarTitle = widget.ownerToEdit == null
        ? 'Yeni Sahip Ekle'
        : 'Sahip Düzenle: ${_addEditOwnerStore.firstName ?? ''} ${_addEditOwnerStore.lastName ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        actions: [
          Observer(
            builder: (_) {
              return IconButton(
                icon: (_addEditOwnerStore.isLoading || _addEditOwnerStore.isInitializing)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
                tooltip: 'Kaydet',
                onPressed: (_addEditOwnerStore.isLoading || _addEditOwnerStore.isInitializing)
                    ? null
                    : _saveForm,
              );
            },
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          // isInitializing'i ve isValueListsLoading'i kullanarak yüklenme durumunu kontrol et
          // City listesi boşsa ve yükleniyorsa, yüklenme göstergesi göster.
          if (_addEditOwnerStore.isInitializing ||
              (_addEditOwnerStore.isValueListsLoading && _addEditOwnerStore.cityList.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (_addEditOwnerStore.valueListsErrorMessage != null) {
            return Center(
              child: Text(
                'Değer listeleri yüklenemedi: ${_addEditOwnerStore.valueListsErrorMessage!}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          else if (_addEditOwnerStore.errorMessage != null && !_addEditOwnerStore.isLoading) {
            return Center(
              child: Text(
                'Kaydetme Hatası: ${_addEditOwnerStore.errorMessage!}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Form içeriği
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Kişisel Bilgiler
                  Text('Kişisel Bilgiler', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nationalIdController,
                    decoration: const InputDecoration(labelText: 'TC/Ulusal Kimlik No', border: OutlineInputBorder()),
                    onChanged: (newValue) => _addEditOwnerStore.nationalId = newValue,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen ulusal kimlik numarasını girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(labelText: 'Adı', border: OutlineInputBorder()),
                          onChanged: (newValue) => _addEditOwnerStore.firstName = newValue,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen adı girin.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(labelText: 'Soyadı', border: OutlineInputBorder()),
                          onChanged: (newValue) => _addEditOwnerStore.lastName = newValue,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen soyadı girin.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // İletişim Bilgileri
                  Text('İletişim Bilgileri', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (newValue) => _addEditOwnerStore.email = newValue,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen e-posta adresini girin.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Geçerli bir e-posta adresi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                          onChanged: (newValue) => _addEditOwnerStore.phone = newValue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _mobilePhoneController,
                          decoration: const InputDecoration(labelText: 'Cep Telefonu', border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                          onChanged: (newValue) => _addEditOwnerStore.mobilePhone = newValue,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen cep telefonu numarasını girin.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Adres Bilgileri
                  Text('Adres Bilgileri', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Adres', border: OutlineInputBorder()),
                    maxLines: 3,
                    onChanged: (newValue) => _addEditOwnerStore.address = newValue,
                  ),
                  const SizedBox(height: 16),

                  // Ülke (Sabit Türkiye)
                  TextFormField(
                    initialValue: 'Türkiye', // Sabit değer
                    decoration: const InputDecoration(labelText: 'Ülke', border: OutlineInputBorder()),
                    readOnly: true, // Kullanıcının değiştirmesini engeller
                  ),
                  const SizedBox(height: 16),

                  // Şehir Dropdown
                  Observer(builder: (_) {
                    final bool isCityDropdownEnabled =
                        !_addEditOwnerStore.isInitializing &&
                        !_addEditOwnerStore.isValueListsLoading &&
                        _addEditOwnerStore.cityList.isNotEmpty;
                    return CustomDropdownFormField(
                      labelText: 'Şehir',
                      hintText: 'Şehir seçiniz',
                      options: _addEditOwnerStore.cityList.toList(),
                      selectedValueId: _addEditOwnerStore.selectedCityOption?.id,
                      onChanged: (selectedId) {
                        final selectedOption = _addEditOwnerStore.cityList.firstWhereId(selectedId);
                        _addEditOwnerStore.setCity(selectedOption);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şehri seçin.';
                        }
                        return null;
                      },
                      isLoading: _addEditOwnerStore.isValueListsLoading,
                      isEnabled: isCityDropdownEnabled,
                    );
                  }),
                  const SizedBox(height: 16),

                  // İlçe Dropdown
                  Observer(builder: (_) {
                    final bool isDistrictDropdownEnabled =
                        _addEditOwnerStore.selectedCityOption != null &&
                        !_addEditOwnerStore.isInitializing &&
                        !_addEditOwnerStore.isValueListsLoading &&
                        _addEditOwnerStore.districtList.isNotEmpty;
                    return CustomDropdownFormField(
                      labelText: 'İlçe',
                      hintText: _addEditOwnerStore.selectedCityOption == null ? 'Şehir seçiniz' : 'İlçe seçiniz',
                      options: _addEditOwnerStore.districtList.toList(),
                      selectedValueId: _addEditOwnerStore.selectedDistrictOption?.id,
                      onChanged: (selectedId) {
                        final selectedOption = _addEditOwnerStore.districtList.firstWhereId(selectedId);
                        _addEditOwnerStore.setDistrict(selectedOption);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen ilçeyi seçin.';
                        }
                        return null;
                      },
                      isLoading: _addEditOwnerStore.isValueListsLoading,
                      isEnabled: isDistrictDropdownEnabled,
                    );
                  }),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(labelText: 'Posta Kodu', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (newValue) => _addEditOwnerStore.zipCode = newValue,
                  ),
                  const SizedBox(height: 16),

                  // Referans Kişi Bilgileri (İsteğe Bağlı)
                  Text('Referans Kişi (İsteğe Bağlı)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Referans Kişi Adı',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.person_search),
                    ),
                    readOnly: true,
                    onTap: () {
                      print('DEBUG: Referans kişi seçimi alanı tıklandı. Henüz entegre değil.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referans kişi seçimi özelliği yakında eklenecek.')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sistem Bilgileri Bölümü (Read-only)
                  Text('Sistem Bilgileri', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  Observer(
                    builder: (_) {
                      return Column(
                        children: [
                          _buildReadOnlyDetailRow('ID:', _addEditOwnerStore.id),
                          _buildReadOnlyDetailRow('Oluşturulma Tarihi:', _addEditOwnerStore.createdAt),
                          _buildReadOnlyDetailRow('Oluşturan ID:', _addEditOwnerStore.createdBy),
                          _buildReadOnlyDetailRow('Güncellenme Tarihi:', _addEditOwnerStore.updatedAt),
                          _buildReadOnlyDetailRow('Güncelleyen ID:', _addEditOwnerStore.updatedBy),
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