import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olive_v2/stores/login_store.dart';
import 'package:olive_v2/screens/login_screen.dart';
import 'package:olive_v2/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() async {
    // Splash ekranın görünmesi için kısa bir gecikme ekle
    await Future.delayed(const Duration(seconds: 1)); // 1 saniye bekle

    final loginStore = Provider.of<LoginStore>(context, listen: false);

    try {
      print('DEBUG: Saklı token okunuyor...'); // Debug mesajı
      final storedToken = await loginStore.getStoredToken();
      print('DEBUG: Okunan token değeri: $storedToken'); // Debug mesajı

      if (storedToken != null) {
        print('DEBUG: Saklı token bulundu. Ana ekrana yönlendiriliyor.');
        // TODO: Token geçerliliğini kontrol etmek için backend'e bir istek atılabilir.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        print('DEBUG: Saklı token bulunamadı. Login ekranına yönlendiriliyor.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('DEBUG: Token kontrolü sırasında hata: $e'); // Debug mesajı
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo Widget'ı
            Image.asset(
              'images/olive_the_cat_logo.png',
              width: 150,
            ),
            const SizedBox(height: 24),

            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            const Text('Yükleniyor...'),
          ],
        ),
      ),
    );
  }
}