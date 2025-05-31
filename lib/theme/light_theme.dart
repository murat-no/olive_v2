import 'package:flutter/material.dart';

// Uygulamanın açık temasını tanımlayan fonksiyon
ThemeData lightTheme() {
  // Tema renkleri
  const Color primaryColor = Color(0xFF1976D2); // Material Design Mavisi
  const Color accentColor = Color(0xFF2196F3); // Vurgu rengi (secondary)

  return ThemeData(
    brightness: Brightness.light, // Bu temanın açık tema olduğunu belirtir
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      accentColor: accentColor,
    ).copyWith(secondary: accentColor), // Material 2 için secondary ekliyoruz

    scaffoldBackgroundColor: Colors.grey[200], // Ekran arka plan rengi

    // AppBar Teması
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Input Alanları Teması (TextFormField)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      labelStyle: TextStyle(color: Colors.grey[600]),
      hintStyle: TextStyle(color: Colors.grey[500]),
      prefixIconColor: primaryColor,
    ),

    // Buton Teması (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 5.0,
      ),
    ),

    // Kart Teması
    cardTheme: CardThemeData(
       elevation: 10.0,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(15.0),
       ),
       surfaceTintColor: Colors.white, // Material 3 için kart rengi ayarı
    ),

    // Diğer temalar buraya eklenebilir (textTheme, iconTheme vb.)
  );
}