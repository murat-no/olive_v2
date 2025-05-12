import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Store'u okumak için
import 'package:flutter_mobx/flutter_mobx.dart'; // Observer için
import 'package:olive_v2/stores/login_store.dart'; // LoginStore'u import et
import 'package:olive_v2/screens/login_screen.dart'; // Yönleneceğimiz login ekranı
import 'package:olive_v2/screens/animal_list_screen.dart'; // AnimalListScreen'ı import et


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Çıkış işlemini yapacak metod
  void _logout(BuildContext context) async {
    // Provider aracılığıyla LoginStore'a eriş
    final loginStore = Provider.of<LoginStore>(context, listen: false);

    // LoginStore'daki logout aksiyonunu çağır
    await loginStore.logout();

    // Token silindikten sonra login ekranına yönlendir
    // pushReplacement kullanarak geri dönülmesini engelle
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Menü öğelerine tıklandığında çalışacak navigasyon metodu
  void _onMenuItemTap(BuildContext context, String menuItem) {
    // Çekmece menüyü kapat
    Navigator.pop(context);

    // Tıklanan menü öğesine göre yönlendirme yap
    switch (menuItem) {
      case 'Hastalar':
        print('DEBUG: Hastalar menüsü tıklandı.');
        // AnimalListScreen'a yönlendirme
        Navigator.push( // Login ekranına dönülmemesi için pushReplacement
          context,
          MaterialPageRoute(builder: (context) => const AnimalListScreen()),
        );
        break;
      case 'Sahipler':
        print('DEBUG: Sahipler menüsü tıklandı.');
        // TODO: Sahip Listesi ekranına yönlendirme yapılacak
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OwnerListScreen()));
        break;
      case 'Randevular':
         print('DEBUG: Randevular menüsü tıklandı.');
         // TODO: Randevu ekranına yönlendirme yapılacak
         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppointmentScreen()));
        break;
      case 'Ayarlar':
         print('DEBUG: Ayarlar menüsü tıklandı.');
         // TODO: Ayarlar ekranına yönlendirme yapılacak
         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        break;
      case 'Çıkış Yap':
        _logout(context); // Logout metodunu çağır
        break;
      default:
        print('DEBUG: Bilinmeyen menü öğesi: $menuItem');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // LoginStore'u dinlemek için Observer içinde kullanıyoruz veya context.watch kullanabiliriz.
    // AppBar içindeki Observer zaten store'u dinleyecek.
    final loginStore = Provider.of<LoginStore>(context); // Observer içinde kullanmak için, listen default true

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Ekran'),
        centerTitle: true,
         // AppBar'a menü ikonunu otomatik ekler, drawer tanımlıysa
         leading: Builder( // Drawer'ı açmak için Builder kullanıyoruz (context sağlamak için)
           builder: (BuildContext context) {
             return IconButton(
               icon: const Icon(Icons.menu),
               onPressed: () {
                 Scaffold.of(context).openDrawer(); // Çekmece menüyü aç
               },
               tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
             );
           },
         ),
        actions: [
          // Kullanıcı Adını Gösteren Observer Widget'ı
          Observer( // loginStore.currentUserName değişimini dinler
            builder: (_) {
              // loginStore.currentUserName null değilse kullanıcı adını göster
              if (loginStore.currentUserName != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Kenarlardan boşluk
                  child: Center( // Metni dikeyde ortala
                    child: Text(
                      loginStore.currentUserName!, // null olmadığını biliyoruz burada
                      style: const TextStyle(
                        color: Colors.white, // AppBar yazı rengiyle uyumlu
                        fontSize: 16,
                        // fontWeight: FontWeight.bold, // İsteğe bağlı kalınlık
                      ),
                    ),
                  ),
                );
              }
              // Kullanıcı adı yoksa (logout sonrası veya başlangıçta) hiçbir şey gösterme
              return const SizedBox.shrink();
            },
          ),
          // Çıkış butonu artık menüde
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   tooltip: 'Çıkış Yap',
          //   onPressed: () => _logout(context),
          // ),
        ],
      ),
      // Çekmece Menü (Drawer) Tanımı
      drawer: Drawer(
        child: ListView( // Menü öğelerini listelemek için ListView kullan
          padding: EdgeInsets.zero, // Padding'i sıfırla
          children: <Widget>[
             DrawerHeader( // Menü başlığı (isteğe bağlı)
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: Uygulama logosu veya kullanıcının profil fotoğrafı
                  // CircleAvatar(radius: 30, child: Icon(Icons.person)),
                   // SizedBox(height: 8),
                  const Text(
                    'Menü', // Menü başlığı
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  // Kullanıcı adını menü başlığında da göstermek isterseniz
                  Observer( // loginStore.currentUserName değişimini dinler
                    builder: (_) => Text(
                       loginStore.currentUserName ?? '', // Kullanıcı adını göster (null ise boş string)
                       style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            ListTile( // Menü öğesi: Hastalar
              leading: const Icon(Icons.pets),
              title: const Text('Hastalar'),
              onTap: () {
                _onMenuItemTap(context, 'Hastalar'); // Tıklanınca metodu çağır
              },
            ),
             ListTile( // Menü öğesi: Sahipler
              leading: const Icon(Icons.people),
              title: const Text('Sahipler'),
              onTap: () {
                _onMenuItemTap(context, 'Sahipler');
              },
            ),
             ListTile( // Menü öğesi: Randevular
              leading: const Icon(Icons.calendar_today),
              title: const Text('Randevular'),
              onTap: () {
                _onMenuItemTap(context, 'Randevular');
              },
            ),
            const Divider(), // Ayırıcı çizgi
             ListTile( // Menü öğesi: Ayarlar
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                _onMenuItemTap(context, 'Ayarlar');
              },
            ),
             ListTile( // Menü öğesi: Çıkış Yap
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () {
                _onMenuItemTap(context, 'Çıkış Yap'); // Logout işlemini çağır
              },
            ),
            // Diğer menü öğeleri buraya eklenebilir
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              'Ana Ekran İçeriği', // Artık burası sadece ana ekran içeriği
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