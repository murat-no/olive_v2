import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart'; // Observer widget'ı için
import 'package:provider/provider.dart'; // Store'u okumak için
import 'package:olive_v2/stores/login_store.dart'; // LoginStore'u import et
import 'package:olive_v2/screens/home_screen.dart'; // Yönleneceğimiz ana ekranı import et

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late LoginStore _loginStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Widget ağacından LoginStore instance'ını alıyoruz.
    // listen: false demek, build metodunda bu store'daki değişiklikleri dinleme, sadece instance'ı al demek.
    _loginStore = Provider.of<LoginStore>(context, listen: false);

    // OPTIONAL: Uygulama her açıldığında token var mı kontrol etme (Oturum Açık Kontrolü)
    // Bu kısım genellikle uygulamanın başlangıç widget'ında (main.dart veya wrapper widget) yapılır.
    // Ancak burada da başlatılabilir. İleride bu mantığı daha merkezi bir yere taşıyabiliriz.
    // _checkStoredTokenAndNavigate();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    // MobX store'ları genellikle Provider tarafından veya uygulama ömrü boyunca yönetilir,
    // manuel dispose etmeye gerek kalmaz burada.
    super.dispose();
  }

  // Login butonuna basıldığında çalışacak async metod
  void _login() async {
    // Form geçerli mi kontrol et
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        // MobX store'undaki login aksiyonunu çağır ve işlemin bitmesini bekle.
        // Bu metod, API çağrısı yapar, tokenı saklar ve başarılı olursa hata fırlatmaz.
        final loginResponse = await _loginStore.login(username, password);

        // Eğer await _loginStore.login(username, password) satırı hata fırlatmadan tamamlandıysa,
        // login işlemi başarılı olmuş demektir.
        print('Login başarılı! Backend yanıtı error: ${loginResponse.error}, mesaj: ${loginResponse.message}');

        // Başarılı giriş sonrası Ana Ekrana yönlendirme yap.
        // pushReplacement kullanmak, kullanıcının geri butonuyla login ekranına dönmesini engeller.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

      } catch (e) {
        // _loginStore.login metodundan fırlatılan herhangi bir hata (ağ hatası,
        // backend'in error: true döndürmesi, tokenın null gelmesi vb.) burada yakalanır.
        // Hata mesajı zaten _loginStore.errorMessage observable'ına yazılmıştır.
        // Observer widget'ı bu değişikliği algılayıp hata mesajını UI'da gösterecektir.
        print('UI Katmanında Login İşlemi Hata Yakaladı: $e');
        // UI'da ek bir şey yapmaya gerek yok, MobX durumu yönetiyor.
      }
    }
  }

  // OPTIONAL: Uygulama başlangıcında token kontrolü ve navigasyon (daha sonra eklenebilir)
  /*
  void _checkStoredTokenAndNavigate() async {
    final token = await _loginStore.getStoredToken();
    if (token != null) {
      print('Saklı token bulundu, otomatik giriş deneniyor...');
      // TODO: Token geçerliliğini kontrol etmek için backend'e bir istek atılabilir (_loginStore.checkToken(token)).
      // Eğer token geçerliyse
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      // Token geçerli değilse, kullanıcı login ekranında kalır.
    }
  }
  */


  @override
  Widget build(BuildContext context) {
    // Tema renkleri temadan geliyor (main.dart'ta tanımladık)
    final Color primaryColor = Theme.of(context).primaryColor;
    // Final Color accentColor = Theme.of(context).colorScheme.secondary; // Eğer gerekirse

    return Scaffold(
      // Scaffold background rengi temadan geliyor (scaffoldBackgroundColor)
      appBar: AppBar(
        title: const Text('Veteriner Uygulaması - Giriş'),
        // AppBar stili (background, foreground, textStyle) temadan geliyor
      ),
      body: Center(
        child: Card(
          // Card stili (elevation, shape, color) temadan geliyor
          child: Container(
            width: 400, // Web için form genişliğini sınırla
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Kolon içeriği kadar yer kaplasın
                crossAxisAlignment: CrossAxisAlignment.stretch, // Yatayda genişlesin
                children: <Widget>[
                   Text(
                    'Hoş Geldiniz!',
                     textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor), // Temadaki başlık stilini al, rengi özelleştir
                   ),
                  const SizedBox(height: 30.0), // Boşluk

                  TextFormField(
                    controller: _usernameController,
                    // InputDecoration stili temadan geliyor (border, focusedBorder, contentPadding, labelStyle, prefixIconColor)
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      prefixIcon: Icon(Icons.person),
                       // Temadan gelen stilleri override etmek isterseniz buraya ekleyebilirsiniz
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen kullanıcı adınızı girin';
                      }
                      // TODO: Daha detaylı kullanıcı adı formatı doğrulama eklenebilir.
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0), // Boşluk

                  TextFormField(
                    controller: _passwordController,
                    // InputDecoration stili temadan geliyor
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: Icon(Icons.lock),
                       // Temadan gelen stilleri override etmek isterseniz buraya ekleyebilirsiniz
                    ),
                    obscureText: true, // Şifreyi gizle
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen şifrenizi girin';
                      }
                       // TODO: Minimum şifre uzunluğu veya karmaşıklığı doğrulama eklenebilir.
                      return null;
                    },
                  ),
                   const SizedBox(height: 30.0), // Boşluk

                   // MobX durum değişikliklerini dinleyen ve UI'ı güncelleyen Observer widget'ı
                   Observer(
                     builder: (_) {
                       // Store'daki isLoading durumu true ise yüklenme göstergesi göster
                       if (_loginStore.isLoading) {
                         return Center(child: CircularProgressIndicator(color: primaryColor));
                       }
                       // Store'da errorMessage null değilse hata mesajını göster
                       else if (_loginStore.errorMessage != null) {
                         return Column( // Hata mesajı ve belki retry butonu için kolon
                           children: [
                             Text(
                               _loginStore.errorMessage!, // null değilse göster
                               style: const TextStyle(color: Colors.red, fontSize: 14),
                               textAlign: TextAlign.center,
                             ),
                             // TODO: Hata durumunda yeniden deneme butonu eklenebilir
                             /*
                             TextButton(
                               onPressed: () {
                                 // Hata mesajını temizleyip tekrar login denemesi
                                 _loginStore.errorMessage = null; // Hata mesajını temizle
                                 // _login(); // Tekrar login fonksiyonunu çağır
                               },
                               child: const Text('Tekrar Dene'),
                             )
                             */
                           ],
                         );
                       }
                       // Ne yükleniyor ne de hata varsa boş bir widget döndür
                       return const SizedBox.shrink(); // Hiçbir şey gösterme
                     },
                   ),

                    // Hata mesajı/yükleniyor alanı ile buton arasına boşluk
                   const SizedBox(height: 20.0),


                  ElevatedButton(
                    // Eğer store yükleniyor durumundaysa butonu devre dışı bırak (null)
                    onPressed: _loginStore.isLoading ? null : _login,
                    // Buton stili temadan geliyor (backgroundColor, foregroundColor, padding, textStyle, shape, elevation)
                    child: const Text('Giriş Yap'),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}