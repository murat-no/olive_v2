import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olive_v2/theme/light_theme.dart';
import 'package:olive_v2/theme/dark_theme.dart';
import 'package:olive_v2/stores/login_store.dart';
import 'package:olive_v2/stores/animal_store.dart';
import 'package:olive_v2/stores/add_edit_animal_store.dart';
import 'package:olive_v2/stores/owner_store.dart';
import 'package:olive_v2/stores/add_edit_owner_store.dart'; 
import 'package:olive_v2/screens/splash_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LoginStore>(create: (_) => LoginStore()),
        Provider<AnimalStore>(create: (_) => AnimalStore()),
        Provider<AddEditAnimalStore>(create: (_) => AddEditAnimalStore()),
        Provider<OwnerStore>(create: (_) => OwnerStore()),
        Provider<AddEditOwnerStore>(create: (_) => AddEditOwnerStore()), 
      ],
      child: MaterialApp(
        title: 'Veteriner Uygulaması',
        debugShowCheckedModeBanner: false,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.light,

        home: const SplashScreen(),
        // Rota tanımları buraya eklenebilir
      ),
    );
  }
}