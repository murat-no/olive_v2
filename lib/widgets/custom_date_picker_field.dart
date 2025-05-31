// lib/widgets/custom_date_picker_field.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için

class CustomDatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final Function(String?) onDateSelected; // Seçilen tarihi String olarak döndürecek callback
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDatePickerField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    required this.onDateSelected,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(), // Biraz daha modern bir görünüm için
      ),
      keyboardType: TextInputType.datetime,
      readOnly: true, // Kullanıcının direkt yazmasını engeller
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode()); // Klavyeyi kapat
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(), // Başlangıç tarihi
          firstDate: firstDate ?? DateTime(1900), // En erken seçilebilecek tarih
          lastDate: lastDate ?? DateTime.now(), // En son seçilebilecek tarih
          helpText: '$labelText Seçin',
          cancelText: 'İptal',
          confirmText: 'Tamam',
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          controller.text = formattedDate; // Controller'ı güncelle
          onDateSelected(formattedDate); // Callback ile seçilen tarihi dışarıya bildir
        }
      },
      validator: validator,
    );
  }
}