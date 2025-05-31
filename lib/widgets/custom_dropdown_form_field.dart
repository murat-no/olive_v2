// lib/widgets/custom_dropdown_form_field.dart

import 'package:flutter/material.dart';
import 'package:olive_v2/models/value_option.dart';

class CustomDropdownFormField extends StatelessWidget {
  final String labelText;
  final List<ValueOption> options; // Dropdown'daki seçenekler
  final String? selectedValueId; // Seçili olan ValueOption'ın ID'si
  final String? Function(String?)? validator;
  final String hintText;
  final bool isEnabled; // Dropdown'ın aktif/pasif durumu
  final Function(String?) onChanged; // Seçim değiştiğinde tetiklenecek callback (ID döndürecek)
  final bool isLoading;

  const CustomDropdownFormField({
    super.key,
    required this.labelText,
    required this.options,
    this.selectedValueId,
    this.validator,
    required this.hintText,
    this.isEnabled = true,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> dropdownItems = options.map((ValueOption option) {
      // option.id'nin null veya boş gelmemesi gerektiğini varsayıyoruz.
      // Eğer geliyorsa, bu bir backend/veri sorunudur ve burada filtrelemek gerekir.
      // Örneğin: if (option.id == null || option.id!.isEmpty) return null;
      // Ama o zaman null olan DropdownMenuItem'leri handle etmemiz gerekir.
      // Şimdilik, valid ID'ler geldiğini varsayarak devam edelim.
      return DropdownMenuItem<String>(
        value: option.id, // ValueOption.id artık String olmalı.
        child: Text(option.displayText),
      );
    }).where((item) => item.value != null && item.value!.isNotEmpty).toList(); // ✨ KRİTİK FİLTRELEME: Null/Boş değerli item'ları kaldır ✨


    // actualValue'yu hesapla. selectedValueId'nin orijinal halini kullanacağız.
    String? actualValue = selectedValueId;

    // effectiveValue, DropdownButtonFormField'a gönderilecek olan değeri belirler.
    String? finalDropdownValue;

    if (dropdownItems.isEmpty) {
      finalDropdownValue = null;
    } else if (actualValue == null || actualValue.isEmpty) {
      finalDropdownValue = null;
    } else {
      // Seçili bir değer varsa, ama listede yoksa, yine null yap.
      // Eşleşmeyi `idLower` kullanarak yapmalıyız, çünkü DropdownMenuItem.value de artık ID.
      final bool valueExistsInOptions = options.any((option) => option.id == actualValue); // IDs must match exactly (case-sensitive from backend if not UUIDs)
      if (valueExistsInOptions) {
        finalDropdownValue = actualValue;
      } else {
        finalDropdownValue = null;
      }
    }

    final bool showLoadingHint = isLoading && options.isEmpty;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items: dropdownItems,
      value: finalDropdownValue,
      onChanged: isEnabled && !isLoading ? onChanged : null,
      validator: validator,
      hint: showLoadingHint ? const Text('Yükleniyor...') : Text(hintText),
      isDense: true,
      autofocus: false,
    );
  }
}