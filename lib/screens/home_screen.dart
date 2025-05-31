import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Store'u okumak için
import 'package:flutter_mobx/flutter_mobx.dart'; // Observer için
import 'package:olive_v2/stores/login_store.dart'; // LoginStore'u import et
import 'package:olive_v2/screens/login_screen.dart'; // Yönleneceğimiz login ekranı
import 'package:olive_v2/screens/animal_list_screen.dart'; // AnimalListScreen'ı import et
import 'package:olive_v2/screens/owner_list_screen.dart'; // ✨ YENİ: OwnerListScreen'ı import et ✨


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Çıkış işlemini yapacak metod
  void _logout(BuildContext context) async {
    final loginStore = Provider.of<LoginStore>(context, listen: false);
    await loginStore.logout();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Menü öğelerine tıklandığında çalışacak navigasyon metodu
  void _onMenuItemTap(BuildContext context, String menuItem) {
    Navigator.pop(context); // Çekmece menüyü kapat

    switch (menuItem) {
      case 'Hastalar':
        print('DEBUG: Hastalar menüsü tıklandı.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnimalListScreen()),
        );
        break;
      case 'Sahipler':
        print('DEBUG: Sahipler menüsü tıklandı.');
        // ✨ YENİ: OwnerListScreen'a yönlendirme ✨
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OwnerListScreen()),
        );
        break;
      case 'Randevular':
         print('DEBUG: Randevular menüsü tıklandı.');
         // TODO: Randevu ekranına yönlendirme yapılacak
        break;
      case 'Ayarlar':
         print('DEBUG: Ayarlar menüsü tıklandı.');
         // TODO: Ayarlar ekranına yönlendirme yapılacak
        break;
      case 'Çıkış Yap':
        _logout(context);
        break;
      default:
        print('DEBUG: Bilinmeyen menü öğesi: $menuItem');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginStore = Provider.of<LoginStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Ekran'),
        centerTitle: true,
         leading: Builder(
           builder: (BuildContext context) {
             return IconButton(
               icon: const Icon(Icons.menu),
               onPressed: () {
                 Scaffold.of(context).openDrawer();
               },
               tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
             );
           },
         ),
        actions: [
          Observer(
            builder: (_) {
              if (loginStore.currentUserName != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text(
                      loginStore.currentUserName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
             DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menü',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Observer(
                    builder: (_) => Text(
                       loginStore.currentUserName ?? '',
                       style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Hastalar'),
              onTap: () {
                _onMenuItemTap(context, 'Hastalar');
              },
            ),
             ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Sahipler'),
              onTap: () {
                _onMenuItemTap(context, 'Sahipler');
              },
            ),
             ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Randevular'),
              onTap: () {
                _onMenuItemTap(context, 'Randevular');
              },
            ),
            const Divider(),
             ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                _onMenuItemTap(context, 'Ayarlar');
              },
            ),
             ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () {
                _onMenuItemTap(context, 'Çıkış Yap');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              'Ana Ekran İçeriği',
              style: TextStyle(fontSize: 24),
            ),
             SizedBox(height: 16),
             Text(
               'Menüden bir seçenek belirleyin.',
               style: TextStyle(fontSize: 16),
             )
          ],
        ),
      ),
    );
  }
}