import 'package:flutter/material.dart';

// Uygulamanın koyu temasını tanımlayan fonksiyon
ThemeData darkTheme() {
   // Koyu Tema Renkleri
  const Color primaryColorDark = Color(0xFF90CAF9); // Açık mavi (koyu tema için birincil)
  const Color accentColorDark = Color(0xFF64B5F6); // Vurgu rengi (secondary)
  const Color backgroundDark = Color(0xFF121212); // Koyu tema arka planı
  const Color surfaceDark = Color(0xFF1E1E1E); // Koyu tema yüzey rengi (kartlar, dialoglar vb.)

  return ThemeData(
    brightness: Brightness.dark, // Bu temanın koyu tema olduğunu belirtir
    primaryColor: primaryColorDark,
     colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blueGrey, // Koyu tema için farklı bir swatch
        accentColor: accentColorDark,
        brightness: Brightness.dark, // ColorScheme'ın koyu olduğunu belirtir
     ).copyWith(
       secondary: accentColorDark,
       surface: surfaceDark,
     ),

    scaffoldBackgroundColor: backgroundDark, // Ekran arka plan rengi

    // AppBar Teması
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark, // Koyu yüzey rengi
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
        borderSide: BorderSide(color: Colors.grey[700]!), // Koyu gri kenarlık
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColorDark, width: 2.0), // Açık mavi ve kalın
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      labelStyle: TextStyle(color: Colors.grey[400]), // Açık gri label
      hintStyle: TextStyle(color: Colors.grey[500]),
      prefixIconColor: primaryColorDark,
    ),

    // Buton Teması (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDark, // Açık mavi buton
        foregroundColor: Colors.black87, // Koyu yazı rengi
         padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 5.0,
      ),
    ),

     // Kart Teması
    cardTheme: CardTheme(
       elevation: 10.0,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(15.0),
       ),
       color: surfaceDark, // Kart rengi yüzey rengi ile aynı
       surfaceTintColor: surfaceDark, // Material 3 için kart rengi ayarı
    ),

     // Text Teması (metin renkleri otomatik olarak brightness.dark'a göre ayarlanır,
     // ancak belirli stilleri özelleştirebilirsiniz)
     textTheme: const TextTheme(
        titleLarge: TextStyle(color: primaryColorDark), // Başlıklar için açık mavi
        // bodyMedium: TextStyle(color: Colors.white70), // Vb.
     ),

    // Diğer temalar buraya eklenebilir
  );
}